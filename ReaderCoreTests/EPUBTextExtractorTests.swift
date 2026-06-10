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
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
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
        try packageDocument(spine: spine, chapterIDs: Array(chapters.keys)).write(
            to: oebps.appendingPathComponent("content.opf"),
            atomically: true,
            encoding: .utf8
        )

        for (id, html) in chapters {
            try html.write(
                to: oebps.appendingPathComponent("\(id).xhtml"),
                atomically: true,
                encoding: .utf8
            )
        }

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

    private static let containerXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
      <rootfiles>
        <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
      </rootfiles>
    </container>
    """

    private static func packageDocument(spine: [String], chapterIDs: [String]) -> String {
        let manifest = chapterIDs
            .sorted()
            .map { "<item id=\"\($0)\" href=\"\($0).xhtml\" media-type=\"application/xhtml+xml\"/>" }
            .joined()
        let itemRefs = spine
            .map { "<itemref idref=\"\($0)\"/>" }
            .joined()

        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <package xmlns="http://www.idpf.org/2007/opf" version="3.0">
          <manifest>\(manifest)</manifest>
          <spine>\(itemRefs)</spine>
        </package>
        """
    }
}
