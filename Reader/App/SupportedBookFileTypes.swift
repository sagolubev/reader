import UniformTypeIdentifiers

enum SupportedBookFileTypes {
    static let documentTypes: [UTType] = [.pdf, .epubDocument, .content]
}

extension UTType {
    static var epubDocument: UTType {
        UTType(filenameExtension: "epub") ?? UTType(importedAs: "org.idpf.epub-container")
    }
}
