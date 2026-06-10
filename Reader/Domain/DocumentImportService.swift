import Foundation

enum DocumentImportError: Error, Equatable, LocalizedError {
    case unsupportedFileType(String)
    case emptyExtractedText
    case extractorUnavailable(String)

    var errorDescription: String? {
        switch self {
        case .unsupportedFileType(let fileType):
            return "Unsupported file type: \(fileType)"
        case .emptyExtractedText:
            return "No readable text was found in this document."
        case .extractorUnavailable(let fileType):
            return "\(fileType.uppercased()) import is not available yet."
        }
    }
}

protocol PDFTextExtracting {
    func extractText(from url: URL) throws -> String
}

protocol EPUBTextExtracting {
    func extractText(from url: URL) throws -> String
}

struct DocumentImportService {
    var pdfExtractor: PDFTextExtracting
    var epubExtractor: EPUBTextExtracting

    init(
        pdfExtractor: PDFTextExtracting = UnavailablePDFTextExtractor(),
        epubExtractor: EPUBTextExtracting = UnavailableEPUBTextExtractor()
    ) {
        self.pdfExtractor = pdfExtractor
        self.epubExtractor = epubExtractor
    }

    func importText(from url: URL) throws -> String {
        let fileType = normalizedFileType(for: url)
        let extractedText: String

        switch fileType {
        case "pdf":
            extractedText = try pdfExtractor.extractText(from: url)
        case "epub":
            extractedText = try epubExtractor.extractText(from: url)
        default:
            throw DocumentImportError.unsupportedFileType(fileType)
        }

        let normalizedText = Self.normalizeText(extractedText)
        guard !normalizedText.isEmpty else {
            throw DocumentImportError.emptyExtractedText
        }

        return normalizedText
    }

    static func normalizeText(_ text: String) -> String {
        text
            .replacingOccurrences(
                of: "\\s+",
                with: " ",
                options: .regularExpression
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(
                of: "([.!?])\\1+",
                with: "$1",
                options: .regularExpression
            )
    }

    private func normalizedFileType(for url: URL) -> String {
        let fileExtension = url.pathExtension.lowercased()
        return fileExtension.isEmpty ? "unknown" : fileExtension
    }
}

private struct UnavailablePDFTextExtractor: PDFTextExtracting {
    func extractText(from url: URL) throws -> String {
        throw DocumentImportError.extractorUnavailable("pdf")
    }
}

private struct UnavailableEPUBTextExtractor: EPUBTextExtracting {
    func extractText(from url: URL) throws -> String {
        throw DocumentImportError.extractorUnavailable("epub")
    }
}
