import Foundation
import ZIPFoundation

struct EPUBTextExtractor: EPUBTextExtracting {
    let limits: ReaderResourceLimits

    init(limits: ReaderResourceLimits = .default) {
        self.limits = limits
    }

    func extractText(from url: URL) throws -> String {
        let container = try EPUBContainer(url: url)
        let budget = EPUBImportBudget(limits: limits)

        let packagePath = try packagePath(in: container, budget: budget)
        let packageData = try data(for: packagePath, in: container, budget: budget)
        let package = try parsePackage(packageData)
        guard package.spine.count <= limits.maxEPUBSpineItems else {
            throw DocumentImportError.resourceLimitExceeded
        }

        var chapters: [String] = []
        var extractedCharacters = 0
        for itemID in package.spine {
            guard let href = package.manifest[itemID] else {
                continue
            }
            let path = resolve(href, relativeTo: packagePath)
            let chapter = try chapterText(at: path, in: container, budget: budget)
            guard chapter.count <= limits.maxExtractedCharacters - extractedCharacters else {
                throw DocumentImportError.resourceLimitExceeded
            }
            extractedCharacters += chapter.count
            chapters.append(chapter)
        }
        let text = chapters.joined(separator: " ")

        guard !DocumentImportService.normalizeText(text).isEmpty else {
            throw DocumentImportError.emptyExtractedText
        }

        return text
    }

    private func packagePath(
        in container: EPUBContainer,
        budget: EPUBImportBudget
    ) throws -> String {
        let containerData = try data(
            for: "META-INF/container.xml",
            in: container,
            budget: budget
        )
        let delegate = ContainerXMLDelegate()
        try parse(containerData, with: delegate)

        guard let path = delegate.rootfilePath, !path.isEmpty else {
            throw DocumentImportError.epubParseFailed
        }

        return path
    }

    private func parsePackage(_ data: Data) throws -> PackageDocument {
        let delegate = PackageXMLDelegate(limits: limits)
        try parse(data, with: delegate)

        guard !delegate.spine.isEmpty else {
            throw DocumentImportError.epubParseFailed
        }

        return PackageDocument(manifest: delegate.manifest, spine: delegate.spine)
    }

    private func chapterText(
        at path: String,
        in container: EPUBContainer,
        budget: EPUBImportBudget
    ) throws -> String {
        let chapterData = try data(for: path, in: container, budget: budget)
        let delegate = XHTMLTextDelegate(limits: limits)
        try parse(chapterData, with: delegate)
        return delegate.text
    }

    private func data(
        for path: String,
        in container: EPUBContainer,
        budget: EPUBImportBudget
    ) throws -> Data {
        try container.data(for: normalizedResourcePath(path), budget: budget)
    }

    private func parse(_ data: Data, with delegate: XMLParserDelegate) throws {
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        parser.shouldResolveExternalEntities = false

        guard parser.parse() else {
            if let limitedDelegate = delegate as? ResourceLimitedXMLDelegate,
               limitedDelegate.didExceedResourceLimit {
                throw DocumentImportError.resourceLimitExceeded
            }
            throw DocumentImportError.epubParseFailed
        }
    }

    private func resolve(_ href: String, relativeTo packagePath: String) -> String {
        let packageDirectory = (packagePath as NSString).deletingLastPathComponent
        let cleanHref = normalizedResourcePath(href)

        guard !packageDirectory.isEmpty else {
            return cleanHref
        }

        return normalizedResourcePath("\(packageDirectory)/\(cleanHref)")
    }

    private func normalizedResourcePath(_ path: String) -> String {
        let withoutFragment = String(path.split(
            separator: "#",
            maxSplits: 1,
            omittingEmptySubsequences: false
        ).first ?? "")
        let withoutQuery = String(withoutFragment.split(
            separator: "?",
            maxSplits: 1,
            omittingEmptySubsequences: false
        ).first ?? "")
        let decoded = withoutQuery.removingPercentEncoding ?? withoutQuery
        let standardized = (decoded as NSString).standardizingPath
        return standardized.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }
}

private enum EPUBContainer {
    case archive(Archive)
    case directory(URL)

    init(url: URL) throws {
        var isDirectory = ObjCBool(false)
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory),
           isDirectory.boolValue {
            self = .directory(url.standardizedFileURL)
            return
        }

        do {
            self = .archive(try Archive(url: url, accessMode: .read))
        } catch {
            throw DocumentImportError.epubParseFailed
        }
    }

    func data(for path: String, budget: EPUBImportBudget) throws -> Data {
        switch self {
        case .archive(let archive):
            return try archiveData(for: path, in: archive, budget: budget)
        case .directory(let rootURL):
            return try directoryData(for: path, in: rootURL, budget: budget)
        }
    }

    private func archiveData(
        for path: String,
        in archive: Archive,
        budget: EPUBImportBudget
    ) throws -> Data {
        guard let entry = archive[path] else {
            throw DocumentImportError.epubParseFailed
        }
        guard let uncompressedSize = Int(exactly: entry.uncompressedSize) else {
            throw DocumentImportError.resourceLimitExceeded
        }
        try budget.reserve(resourceBytes: uncompressedSize)

        var data = Data()
        do {
            _ = try archive.extract(entry) { chunk in
                try budget.consumeObservedChunk(chunk.count)
                data.append(chunk)
            }
        } catch let error as DocumentImportError {
            throw error
        } catch {
            throw DocumentImportError.epubParseFailed
        }
        return data
    }

    private func directoryData(
        for path: String,
        in rootURL: URL,
        budget: EPUBImportBudget
    ) throws -> Data {
        let root = rootURL.resolvingSymlinksInPath().standardizedFileURL
        let fileURL = root
            .appendingPathComponent(path)
            .resolvingSymlinksInPath()
            .standardizedFileURL
        let rootPath = root.path
        let filePath = fileURL.path

        guard filePath == rootPath || filePath.hasPrefix(rootPath + "/") else {
            throw DocumentImportError.epubParseFailed
        }

        do {
            let values = try fileURL.resourceValues(forKeys: [.fileSizeKey])
            guard let fileSize = values.fileSize else {
                throw DocumentImportError.epubParseFailed
            }
            try budget.reserve(resourceBytes: fileSize)
            let fileHandle = try FileHandle(forReadingFrom: fileURL)
            defer { try? fileHandle.close() }

            var data = Data()
            while let chunk = try fileHandle.read(upToCount: 64 * 1_024),
                  !chunk.isEmpty {
                try budget.consumeObservedChunk(chunk.count)
                data.append(chunk)
            }
            try budget.validateObservedResourceBytes(data.count)
            return data
        } catch let error as DocumentImportError {
            throw error
        } catch {
            throw DocumentImportError.epubParseFailed
        }
    }
}

private final class EPUBImportBudget {
    private let limits: ReaderResourceLimits
    private var totalReservedBytes = 0
    private var currentReservedBytes = 0
    private var currentObservedBytes = 0

    init(limits: ReaderResourceLimits) {
        self.limits = limits
    }

    func reserve(resourceBytes: Int) throws {
        guard resourceBytes >= 0,
              resourceBytes <= limits.maxEPUBResourceBytes,
              resourceBytes <= limits.maxEPUBTotalBytes - totalReservedBytes else {
            throw DocumentImportError.resourceLimitExceeded
        }
        totalReservedBytes += resourceBytes
        currentReservedBytes = resourceBytes
        currentObservedBytes = 0
    }

    func consumeObservedChunk(_ count: Int) throws {
        guard count >= 0,
              count <= currentReservedBytes - currentObservedBytes else {
            throw DocumentImportError.resourceLimitExceeded
        }
        currentObservedBytes += count
    }

    func validateObservedResourceBytes(_ count: Int) throws {
        guard count == currentReservedBytes else {
            throw DocumentImportError.resourceLimitExceeded
        }
    }
}

private struct PackageDocument {
    let manifest: [String: String]
    let spine: [String]
}

private protocol ResourceLimitedXMLDelegate: XMLParserDelegate {
    var didExceedResourceLimit: Bool { get }
}

private final class ContainerXMLDelegate: NSObject, XMLParserDelegate {
    private(set) var rootfilePath: String?

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        if elementName == "rootfile" {
            rootfilePath = attributeDict["full-path"]
        }
    }
}

private final class PackageXMLDelegate: NSObject, ResourceLimitedXMLDelegate {
    private let limits: ReaderResourceLimits
    private(set) var manifest: [String: String] = [:]
    private(set) var spine: [String] = []
    private(set) var didExceedResourceLimit = false

    init(limits: ReaderResourceLimits) {
        self.limits = limits
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        switch elementName {
        case "item":
            if let id = attributeDict["id"], let href = attributeDict["href"] {
                manifest[id] = href
            }
        case "itemref":
            if let idref = attributeDict["idref"] {
                guard spine.count < limits.maxEPUBSpineItems else {
                    didExceedResourceLimit = true
                    parser.abortParsing()
                    return
                }
                spine.append(idref)
            }
        default:
            break
        }
    }
}

private final class XHTMLTextDelegate: NSObject, ResourceLimitedXMLDelegate {
    private let limits: ReaderResourceLimits
    private var parts: [String] = []
    private var characterCount = 0
    private var textSegmentCount = 0
    private(set) var didExceedResourceLimit = false

    init(limits: ReaderResourceLimits) {
        self.limits = limits
    }

    var text: String {
        parts.joined(separator: " ")
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard textSegmentCount < limits.maxEPUBTextSegments,
              string.count <= limits.maxExtractedCharacters - characterCount else {
            didExceedResourceLimit = true
            parser.abortParsing()
            return
        }
        textSegmentCount += 1
        characterCount += string.count
        let normalized = DocumentImportService.normalizeText(string)
        if !normalized.isEmpty {
            parts.append(normalized)
        }
    }
}
