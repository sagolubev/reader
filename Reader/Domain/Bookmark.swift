import Foundation

struct BookmarkSnapshot: Equatable, Identifiable {
    let id: UUID
    let bookID: UUID
    let wordIndex: Int
    let preview: String
    let createdAt: Date

    static func makeNewBookmark(
        id: UUID = UUID(),
        bookID: UUID,
        wordIndex: Int,
        words: [String],
        now: Date = Date()
    ) -> BookmarkSnapshot {
        BookmarkSnapshot(
            id: id,
            bookID: bookID,
            wordIndex: max(0, wordIndex),
            preview: preview(around: wordIndex, words: words),
            createdAt: now
        )
    }

    func matches(bookID: UUID, wordIndex: Int) -> Bool {
        self.bookID == bookID && self.wordIndex == wordIndex
    }

    private static func preview(around wordIndex: Int, words: [String]) -> String {
        guard !words.isEmpty else {
            return ""
        }

        let clampedIndex = min(words.count - 1, max(0, wordIndex))
        let lowerBound = max(0, clampedIndex - 2)
        let upperBound = min(words.count - 1, clampedIndex + 2)
        return words[lowerBound...upperBound].joined(separator: " ")
    }
}
