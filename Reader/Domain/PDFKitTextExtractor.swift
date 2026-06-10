import Foundation
import PDFKit

struct PDFKitTextExtractor: PDFTextExtracting {
    func extractText(from url: URL) throws -> String {
        guard let document = PDFDocument(url: url) else {
            throw DocumentImportError.emptyExtractedText
        }

        let text = (0..<document.pageCount)
            .compactMap { document.page(at: $0)?.string }
            .joined(separator: "\n")

        guard !DocumentImportService.normalizeText(text).isEmpty else {
            throw DocumentImportError.emptyExtractedText
        }

        return text
    }
}
