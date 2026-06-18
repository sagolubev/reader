import XCTest
import ZIPFoundation
@testable import ReaderCore

final class EPUBTextExtractorTests: XCTestCase {
    func testExtractTextReadsSpineDocumentsInOrder() throws {
        let url = try EPUBFixture.writeEPUB(
            spine: ["chapter2", "chapter1"],
            chapters: [
                "chapter1": "<html xmlns=\"http://www.w3.org/1999/xhtml\"><body><p>First &amp; final.</p></body></html>",
                "chapter2": "<html xmlns=\"http://www.w3.org/1999/xhtml\"><body><h1>Second</h1><p>chapter.</p></body></html>"
            ]
        )

        let text = try EPUBTextExtractor().extractText(from: url)

        XCTAssertEqual(DocumentImportService.normalizeText(text), "Second chapter. First & final.")
    }

    func testExtractTextResolvesURLManagedChapterHrefs() throws {
        let url = try EPUBFixture.writeEPUB(
            spine: ["chapter1"],
            manifest: ["chapter1": "Text/Chapter%201.xhtml#start"],
            files: [
                "Text/Chapter 1.xhtml": "<html xmlns=\"http://www.w3.org/1999/xhtml\"><body><p>Apple Books export.</p></body></html>"
            ]
        )

        let text = try EPUBTextExtractor().extractText(from: url)

        XCTAssertEqual(DocumentImportService.normalizeText(text), "Apple Books export.")
    }

    func testExtractTextReadsAppleBooksDirectoryPackage() throws {
        let url = try EPUBFixture.writeEPUBDirectory(
            spine: ["cover", "chapter1"],
            manifest: [
                "cover": "cover.xhtml",
                "chapter1": "ch1.xhtml"
            ],
            files: [
                "cover.xhtml": "<html xmlns=\"http://www.w3.org/1999/xhtml\"><body><p>Book title.</p></body></html>",
                "ch1.xhtml": "<html xmlns=\"http://www.w3.org/1999/xhtml\"><body><p>Readable chapter.</p></body></html>"
            ]
        )

        let text = try EPUBTextExtractor().extractText(from: url)

        XCTAssertEqual(DocumentImportService.normalizeText(text), "Book title. Readable chapter.")
    }

    func testExtractTextReadsEPUBFixturePathFromEnvironment() throws {
        guard
            let path = ProcessInfo.processInfo.environment["READER_EPUB_FIXTURE_PATH"],
            !path.isEmpty
        else {
            throw XCTSkip("Set READER_EPUB_FIXTURE_PATH to smoke-test a local EPUB.")
        }

        let text = try EPUBTextExtractor().extractText(from: URL(fileURLWithPath: path))

        XCTAssertFalse(DocumentImportService.normalizeText(text).isEmpty)
    }

    func testExtractTextRejectsEPUBWithoutReadableText() throws {
        let url = try EPUBFixture.writeEPUB(
            spine: ["chapter1"],
            chapters: [
                "chapter1": "<html xmlns=\"http://www.w3.org/1999/xhtml\"><body><p> </p></body></html>"
            ]
        )

        XCTAssertThrowsError(try EPUBTextExtractor().extractText(from: url)) { error in
            XCTAssertEqual(error as? DocumentImportError, .emptyExtractedText)
        }
    }
}

private enum EPUBFixture {
    static func writeEPUB(spine: [String], chapters: [String: String]) throws -> URL {
        let manifest = Dictionary(uniqueKeysWithValues: chapters.keys.map { ($0, "\($0).xhtml") })
        let files = Dictionary(uniqueKeysWithValues: chapters.map { key, value in ("\(key).xhtml", value) })
        return try writeEPUB(spine: spine, manifest: manifest, files: files)
    }

    static func writeEPUB(spine: [String], manifest: [String: String], files: [String: String]) throws -> URL {
        let root = try writeEPUBDirectory(spine: spine, manifest: manifest, files: files)

        let epubURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("epub")
        try FileManager.default.zipItem(
            at: root,
            to: epubURL,
            shouldKeepParent: false,
            compressionMethod: .none
        )
        return epubURL
    }

    static func writeEPUBDirectory(spine: [String], manifest: [String: String], files: [String: String]) throws -> URL {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathExtension("epub")
        let oebps = root.appendingPathComponent("OEBPS", isDirectory: true)
        let metaInf = root.appendingPathComponent("META-INF", isDirectory: true)
        try FileManager.default.createDirectory(at: oebps, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: metaInf, withIntermediateDirectories: true)

        try "application/epub+zip".write(
            to: root.appendingPathComponent("mimetype"),
            atomically: true,
            encoding: .utf8
        )
        try containerXML.write(
            to: metaInf.appendingPathComponent("container.xml"),
            atomically: true,
            encoding: .utf8
        )
        try packageDocument(spine: spine, manifest: manifest).write(
            to: oebps.appendingPathComponent("content.opf"),
            atomically: true,
            encoding: .utf8
        )

        for (relativePath, html) in files {
            let chapterURL = oebps.appendingPathComponent(relativePath)
            try FileManager.default.createDirectory(
                at: chapterURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try html.write(
                to: chapterURL,
                atomically: true,
                encoding: .utf8
            )
        }

        return root
    }

    private static let containerXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
      <rootfiles>
        <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
      </rootfiles>
    </container>
    """

    private static func packageDocument(spine: [String], manifest: [String: String]) -> String {
        let manifestItems = manifest
            .sorted { $0.key < $1.key }
            .map { "<item id=\"\($0.key)\" href=\"\($0.value)\" media-type=\"application/xhtml+xml\"/>" }
            .joined()
        let itemRefs = spine
            .map { "<itemref idref=\"\($0)\"/>" }
            .joined()

        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <package xmlns="http://www.idpf.org/2007/opf" version="3.0">
          <manifest>\(manifestItems)</manifest>
          <spine>\(itemRefs)</spine>
        </package>
        """
    }
}
