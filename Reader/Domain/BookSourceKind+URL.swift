import Foundation

extension BookSourceKind {
    init(url: URL) {
        switch url.pathExtension.lowercased() {
        case "pdf":
            self = .pdf
        case "epub":
            self = .epub
        default:
            self = .pastedText
        }
    }
}
