import Foundation
import PDFKit

struct PDFKitTextExtractor: PDFTextExtracting {
    let limits: ReaderResourceLimits

    init(limits: ReaderResourceLimits = .default) {
        self.limits = limits
    }

    func extractText(from url: URL) throws -> String {
        let values = try? url.resourceValues(forKeys: [.fileSizeKey])
        if let fileSize = values?.fileSize, fileSize > limits.maxDocumentBytes {
            throw DocumentImportError.resourceLimitExceeded
        }

        guard let document = PDFDocument(url: url) else {
            throw DocumentImportError.emptyExtractedText
        }
        guard document.pageCount <= limits.maxPDFPages else {
            throw DocumentImportError.resourceLimitExceeded
        }

        var text = ""
        for pageIndex in 0..<document.pageCount {
            guard let pageText = document.page(at: pageIndex)?.string else {
                continue
            }
            let separatorCount = text.isEmpty ? 0 : 1
            guard pageText.count + separatorCount <= limits.maxExtractedCharacters - text.count else {
                throw DocumentImportError.resourceLimitExceeded
            }
            if !text.isEmpty {
                text.append("\n")
            }
            text.append(pageText)
        }

        guard !DocumentImportService.normalizeText(text).isEmpty else {
            throw DocumentImportError.emptyExtractedText
        }

        return text
    }
}
