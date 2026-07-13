import Foundation

enum DocumentImportError: Error, Equatable, LocalizedError {
    case unsupportedFileType(String)
    case emptyExtractedText
    case extractorUnavailable(String)
    case epubParseFailed
    case resourceLimitExceeded

    var errorDescription: String? {
        switch self {
        case .unsupportedFileType(let fileType):
            return "Unsupported file type: \(fileType)"
        case .emptyExtractedText:
            return "No readable text was found in this document."
        case .extractorUnavailable(let fileType):
            return "\(fileType.uppercased()) import is not available yet."
        case .epubParseFailed:
            return "The EPUB file could not be parsed."
        case .resourceLimitExceeded:
            return "This document is too large or complex to import safely."
        }
    }
}

struct ReaderResourceLimits: Equatable {
    static let `default` = ReaderResourceLimits()

    let maxDocumentBytes: Int
    let maxEPUBResourceBytes: Int
    let maxEPUBTotalBytes: Int
    let maxEPUBSpineItems: Int
    let maxPDFPages: Int
    let maxExtractedCharacters: Int
    let maxTokenCount: Int
    let maxTokenBytes: Int
    let maxTokenCharacters: Int

    init(
        maxDocumentBytes: Int = 32 * 1_024 * 1_024,
        maxEPUBResourceBytes: Int = 8 * 1_024 * 1_024,
        maxEPUBTotalBytes: Int = 32 * 1_024 * 1_024,
        maxEPUBSpineItems: Int = 2_048,
        maxPDFPages: Int = 2_000,
        maxExtractedCharacters: Int = 8_000_000,
        maxTokenCount: Int = 250_000,
        maxTokenBytes: Int = 16_384,
        maxTokenCharacters: Int = 4_096
    ) {
        self.maxDocumentBytes = max(0, maxDocumentBytes)
        self.maxEPUBResourceBytes = max(0, maxEPUBResourceBytes)
        self.maxEPUBTotalBytes = max(0, maxEPUBTotalBytes)
        self.maxEPUBSpineItems = max(0, maxEPUBSpineItems)
        self.maxPDFPages = max(0, maxPDFPages)
        self.maxExtractedCharacters = max(0, maxExtractedCharacters)
        self.maxTokenCount = max(0, maxTokenCount)
        self.maxTokenBytes = max(0, maxTokenBytes)
        self.maxTokenCharacters = max(0, maxTokenCharacters)
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
    var limits: ReaderResourceLimits

    init(
        pdfExtractor: PDFTextExtracting? = nil,
        epubExtractor: EPUBTextExtracting? = nil,
        limits: ReaderResourceLimits = .default
    ) {
        self.pdfExtractor = pdfExtractor ?? PDFKitTextExtractor(limits: limits)
        self.epubExtractor = epubExtractor ?? EPUBTextExtractor(limits: limits)
        self.limits = limits
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

        guard extractedText.utf8.count <= limits.maxDocumentBytes,
              extractedText.count <= limits.maxExtractedCharacters else {
            throw DocumentImportError.resourceLimitExceeded
        }

        let normalizedText = Self.normalizeText(extractedText)
        guard !normalizedText.isEmpty else {
            throw DocumentImportError.emptyExtractedText
        }
        guard normalizedText.utf8.count <= limits.maxDocumentBytes,
              normalizedText.count <= limits.maxExtractedCharacters else {
            throw DocumentImportError.resourceLimitExceeded
        }
        _ = try RSVPTextProcessor.parseText(normalizedText, limits: limits)

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
