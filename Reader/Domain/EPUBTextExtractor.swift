import Foundation
import ZIPFoundation

struct EPUBTextExtractor: EPUBTextExtracting {
    func extractText(from url: URL) throws -> String {
        let archive: Archive
        do {
            archive = try Archive(url: url, accessMode: .read)
        } catch {
            throw DocumentImportError.epubParseFailed
        }

        let packagePath = try packagePath(in: archive)
        let packageData = try data(for: packagePath, in: archive)
        let package = try parsePackage(packageData)

        let text = try package.spine
            .compactMap { package.manifest[$0] }
            .map { resolve($0, relativeTo: packagePath) }
            .map { try chapterText(at: $0, in: archive) }
            .joined(separator: " ")

        guard !DocumentImportService.normalizeText(text).isEmpty else {
            throw DocumentImportError.emptyExtractedText
        }

        return text
    }

    private func packagePath(in archive: Archive) throws -> String {
        let containerData = try data(for: "META-INF/container.xml", in: archive)
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

    private func chapterText(at path: String, in archive: Archive) throws -> String {
        let chapterData = try data(for: path, in: archive)
        let delegate = XHTMLTextDelegate()
        try parse(chapterData, with: delegate)
        return delegate.text
    }

    private func data(for path: String, in archive: Archive) throws -> Data {
        guard let entry = archive[path] else {
            throw DocumentImportError.epubParseFailed
        }

        var data = Data()
        _ = try archive.extract(entry) { chunk in
            data.append(chunk)
        }
        return data
    }

    private func parse(_ data: Data, with delegate: XMLParserDelegate) throws {
        let parser = XMLParser(data: data)
        parser.delegate = delegate

        guard parser.parse() else {
            throw DocumentImportError.epubParseFailed
        }
    }

    private func resolve(_ href: String, relativeTo packagePath: String) -> String {
        let packageDirectory = packagePath
            .split(separator: "/")
            .dropLast()
            .joined(separator: "/")
        let cleanHref = href.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        guard !packageDirectory.isEmpty else {
            return cleanHref
        }

        return "\(packageDirectory)/\(cleanHref)"
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
