import Foundation

enum BookSourceKind: String, Codable, Equatable, CaseIterable {
    case pastedText
    case pdf
    case epub
}

struct LibraryBookSnapshot: Equatable, Identifiable {
    let id: UUID
    var title: String
    var sourceKind: BookSourceKind
    var text: String
    var wordCount: Int
    var currentWordIndex: Int
    var settings: ReaderSettings
    var addedAt: Date
    var lastOpenedAt: Date

    static func makeNewBook(
        id: UUID = UUID(),
        title: String,
        sourceKind: BookSourceKind,
        text: String,
        settings: ReaderSettings,
        now: Date = Date()
    ) -> LibraryBookSnapshot {
        let words = RSVPTextProcessor.parseText(text)
        return LibraryBookSnapshot(
            id: id,
            title: normalizedTitle(title, fallbackText: text),
            sourceKind: sourceKind,
            text: text.trimmingCharacters(in: .whitespacesAndNewlines),
            wordCount: words.count,
            currentWordIndex: 0,
            settings: settings,
            addedAt: now,
            lastOpenedAt: now
        )
    }

    private static func normalizedTitle(_ title: String, fallbackText: String) -> String {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTitle.isEmpty {
            return (trimmedTitle as NSString).deletingPathExtension
        }

        let words = RSVPTextProcessor.parseText(fallbackText)
        let generated = words.prefix(5).joined(separator: " ")
        return generated.isEmpty ? "Untitled Book" : generated
    }
}

extension ReadingSession {
    mutating func restore(from book: LibraryBookSnapshot) {
        loadText(book.text)
        if !words.isEmpty {
            currentWordIndex = min(words.count - 1, max(0, book.currentWordIndex))
        }
        settings = book.settings
        playbackState = .stopped
    }
}
