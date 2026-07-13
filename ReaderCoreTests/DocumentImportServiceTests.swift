import XCTest
@testable import ReaderCore

final class DocumentImportServiceTests: XCTestCase {
    func testPDFImportDispatchesToPDFExtractorAndNormalizesText() throws {
        let pdfExtractor = RecordingPDFExtractor(result: " One\n\n two!!! ")
        let epubExtractor = RecordingEPUBExtractor(result: "unused")
        let service = DocumentImportService(
            pdfExtractor: pdfExtractor,
            epubExtractor: epubExtractor
        )

        let text = try service.importText(from: URL(fileURLWithPath: "/tmp/book.PDF"))

        XCTAssertEqual(text, "One two!")
        XCTAssertEqual(pdfExtractor.requestedURL?.lastPathComponent, "book.PDF")
        XCTAssertNil(epubExtractor.requestedURL)
    }

    func testEPUBImportDispatchesToEPUBExtractorAndNormalizesText() throws {
        let pdfExtractor = RecordingPDFExtractor(result: "unused")
        let epubExtractor = RecordingEPUBExtractor(result: " Chapter\t one?? ")
        let service = DocumentImportService(
            pdfExtractor: pdfExtractor,
            epubExtractor: epubExtractor
        )

        let text = try service.importText(from: URL(fileURLWithPath: "/tmp/book.epub"))

        XCTAssertEqual(text, "Chapter one?")
        XCTAssertNil(pdfExtractor.requestedURL)
        XCTAssertEqual(epubExtractor.requestedURL?.lastPathComponent, "book.epub")
    }

    func testUnsupportedFileTypeThrowsVisibleImportError() {
        let service = DocumentImportService(
            pdfExtractor: RecordingPDFExtractor(result: "unused"),
            epubExtractor: RecordingEPUBExtractor(result: "unused")
        )

        XCTAssertThrowsError(try service.importText(from: URL(fileURLWithPath: "/tmp/book.docx"))) { error in
            XCTAssertEqual(error as? DocumentImportError, .unsupportedFileType("docx"))
        }
    }

    func testEmptyNormalizedExtractionThrowsWithoutReplacingText() {
        let service = DocumentImportService(
            pdfExtractor: RecordingPDFExtractor(result: " \n\t "),
            epubExtractor: RecordingEPUBExtractor(result: "unused")
        )

        XCTAssertThrowsError(try service.importText(from: URL(fileURLWithPath: "/tmp/empty.pdf"))) { error in
            XCTAssertEqual(error as? DocumentImportError, .emptyExtractedText)
        }
    }

    func testNormalizeTextCollapsesWhitespaceAndRepeatedSentencePunctuation() {
        let text = DocumentImportService.normalizeText("  Hello\tworld!!!\n\nWait...  ")

        XCTAssertEqual(text, "Hello world! Wait.")
    }

    func testImportRejectsNormalizedTextAboveCharacterLimit() {
        let service = DocumentImportService(
            pdfExtractor: RecordingPDFExtractor(result: "12345"),
            epubExtractor: RecordingEPUBExtractor(result: "unused"),
            limits: ReaderResourceLimits(maxExtractedCharacters: 4)
        )

        XCTAssertThrowsError(try service.importText(from: URL(fileURLWithPath: "/tmp/book.pdf"))) {
            XCTAssertEqual($0 as? DocumentImportError, .resourceLimitExceeded)
        }
    }
}

private final class RecordingPDFExtractor: PDFTextExtracting {
    private let result: String
    private(set) var requestedURL: URL?

    init(result: String) {
        self.result = result
    }

    func extractText(from url: URL) throws -> String {
        requestedURL = url
        return result
    }
}

private final class RecordingEPUBExtractor: EPUBTextExtracting {
    private let result: String
    private(set) var requestedURL: URL?

    init(result: String) {
        self.result = result
    }

    func extractText(from url: URL) throws -> String {
        requestedURL = url
        return result
    }
}
