import XCTest
@testable import ReaderCore

final class PDFKitTextExtractorTests: XCTestCase {
    func testExtractTextReadsTextBasedPDF() throws {
        let url = try MinimalPDFFixture.writePDF(text: "Hello PDF world!")
        let extractor = PDFKitTextExtractor()

        let text = try extractor.extractText(from: url)

        XCTAssertEqual(DocumentImportService.normalizeText(text), "Hello PDF world!")
    }

    func testExtractTextRejectsPDFWithoutReadableText() throws {
        let url = try MinimalPDFFixture.writePDF(text: nil)
        let extractor = PDFKitTextExtractor()

        XCTAssertThrowsError(try extractor.extractText(from: url)) { error in
            XCTAssertEqual(error as? DocumentImportError, .emptyExtractedText)
        }
    }
}

private enum MinimalPDFFixture {
    static func writePDF(text: String?) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("pdf")

        let content = text.map { "BT /F1 24 Tf 72 720 Td (\(escapePDFString($0))) Tj ET" } ?? ""
        let stream = "\(content)\n"
        let objects = [
            "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n",
            "2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n",
            "3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 5 0 R >> >> /Contents 4 0 R >>\nendobj\n",
            "4 0 obj\n<< /Length \(stream.utf8.count) >>\nstream\n\(stream)endstream\nendobj\n",
            "5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n"
        ]

        var pdf = "%PDF-1.4\n"
        var offsets: [Int] = []
        for object in objects {
            offsets.append(pdf.utf8.count)
            pdf += object
        }

        let xrefOffset = pdf.utf8.count
        pdf += "xref\n0 \(objects.count + 1)\n"
        pdf += "0000000000 65535 f \n"
        for offset in offsets {
            pdf += String(format: "%010d 00000 n \n", offset)
        }
        pdf += "trailer\n<< /Size \(objects.count + 1) /Root 1 0 R >>\n"
        pdf += "startxref\n\(xrefOffset)\n%%EOF\n"

        try XCTUnwrap(pdf.data(using: .ascii)).write(to: url)
        return url
    }

    private static func escapePDFString(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "(", with: "\\(")
            .replacingOccurrences(of: ")", with: "\\)")
    }
}
