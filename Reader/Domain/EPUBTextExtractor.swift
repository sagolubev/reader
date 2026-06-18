import Foundation
import ZIPFoundation

struct EPUBTextExtractor: EPUBTextExtracting {
    func extractText(from url: URL) throws -> String {
        let container = try EPUBContainer(url: url)

        let packagePath = try packagePath(in: container)
        let packageData = try data(for: packagePath, in: container)
        let package = try parsePackage(packageData)

        let text = try package.spine
            .compactMap { package.manifest[$0] }
            .map { resolve($0, relativeTo: packagePath) }
            .map { try chapterText(at: $0, in: container) }
            .joined(separator: " ")

        guard !DocumentImportService.normalizeText(text).isEmpty else {
            throw DocumentImportError.emptyExtractedText
        }

        return text
    }

    private func packagePath(in container: EPUBContainer) throws -> String {
        let containerData = try data(for: "META-INF/container.xml", in: container)
        let delegate = ContainerXMLDelegate()
        try parse(containerData, with: delegate)

        guard let path = delegate.rootfilePath, !path.isEmpty else {
            throw DocumentImportError.epubParseFailed
        }

        return path
    }

    private func parsePackage(_ data: Data) throws -> PackageDocument {
        let delegate = PackageXMLDelegate()
        try parse(data, with: delegate)

        guard !delegate.spine.isEmpty else {
            throw DocumentImportError.epubParseFailed
        }

        return PackageDocument(manifest: delegate.manifest, spine: delegate.spine)
    }

    private func chapterText(at path: String, in container: EPUBContainer) throws -> String {
        let chapterData = try data(for: path, in: container)
        let delegate = XHTMLTextDelegate()
        try parse(chapterData, with: delegate)
        return delegate.text
    }

    private func data(for path: String, in container: EPUBContainer) throws -> Data {
        try container.data(for: normalizedResourcePath(path))
    }

    private func parse(_ data: Data, with delegate: XMLParserDelegate) throws {
        let parser = XMLParser(data: data)
        parser.delegate = delegate

        guard parser.parse() else {
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

    func data(for path: String) throws -> Data {
        switch self {
        case .archive(let archive):
            return try archiveData(for: path, in: archive)
        case .directory(let rootURL):
            return try directoryData(for: path, in: rootURL)
        }
    }

    private func archiveData(for path: String, in archive: Archive) throws -> Data {
        guard let entry = archive[path] else {
            throw DocumentImportError.epubParseFailed
        }

        var data = Data()
        do {
            _ = try archive.extract(entry) { chunk in
                data.append(chunk)
            }
        } catch {
            throw DocumentImportError.epubParseFailed
        }
        return data
    }

    private func directoryData(for path: String, in rootURL: URL) throws -> Data {
        let root = rootURL.standardizedFileURL
        let fileURL = root.appendingPathComponent(path).standardizedFileURL
        let rootPath = root.path
        let filePath = fileURL.path

        guard filePath == rootPath || filePath.hasPrefix(rootPath + "/") else {
            throw DocumentImportError.epubParseFailed
        }

        do {
            return try Data(contentsOf: fileURL)
        } catch {
            throw DocumentImportError.epubParseFailed
        }
    }
}

private struct PackageDocument {
    let manifest: [String: String]
    let spine: [String]
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

private final class PackageXMLDelegate: NSObject, XMLParserDelegate {
    private(set) var manifest: [String: String] = [:]
    private(set) var spine: [String] = []

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
                spine.append(idref)
            }
        default:
            break
        }
    }
}

private final class XHTMLTextDelegate: NSObject, XMLParserDelegate {
    private var parts: [String] = []

    var text: String {
        parts.joined(separator: " ")
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let normalized = DocumentImportService.normalizeText(string)
        if !normalized.isEmpty {
            parts.append(normalized)
        }
    }
}
