import Foundation

struct LoadContentState {
    var pastedText = ""
    var errorMessage: String?
    var isImportingFile = false
    var isFileImporterPresented = false

    var canLoadPastedText: Bool {
        !DocumentImportService.normalizeText(pastedText).isEmpty && !isImportingFile
    }

    mutating func takePastedText() -> String? {
        guard !isImportingFile else {
            return nil
        }

        let text = DocumentImportService.normalizeText(pastedText)
        guard !text.isEmpty else {
            errorMessage = "Enter text to load."
            return nil
        }

        pastedText = ""
        errorMessage = nil
        return text
    }

    mutating func beginFileImport() -> Bool {
        guard !isImportingFile else {
            return false
        }

        errorMessage = nil
        isImportingFile = true
        return true
    }

    mutating func finishFileImport(_ result: Result<String, Error>) -> String? {
        isImportingFile = false

        switch result {
        case .success(let text):
            let normalizedText = DocumentImportService.normalizeText(text)
            guard !normalizedText.isEmpty else {
                errorMessage = Self.message(for: DocumentImportError.emptyExtractedText)
                return nil
            }

            errorMessage = nil
            return normalizedText
        case .failure(let error):
            errorMessage = Self.message(for: error)
            return nil
        }
    }

    mutating func failFileSelection(_ error: Error) {
        errorMessage = Self.message(for: error)
    }

    private static func message(for error: Error) -> String {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            return description
        }

        return error.localizedDescription
    }
}
