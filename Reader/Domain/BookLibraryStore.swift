import Foundation
import SwiftData

enum BookLibraryStoreError: LocalizedError, Equatable {
    case emptyBook

    var errorDescription: String? {
        switch self {
        case .emptyBook:
            return "The book does not contain readable text."
        }
    }
}

@Model
final class StoredBookRecord {
    var id: UUID
    var title: String
    var sourceKindRawValue: String
    var text: String
    var wordCount: Int
    var currentWordIndex: Int
    var settingsData: Data
    var addedAt: Date
    var lastOpenedAt: Date

    init(
        id: UUID,
        title: String,
        sourceKindRawValue: String,
        text: String,
        wordCount: Int,
        currentWordIndex: Int,
        settingsData: Data,
        addedAt: Date,
        lastOpenedAt: Date
    ) {
        self.id = id
        self.title = title
        self.sourceKindRawValue = sourceKindRawValue
        self.text = text
        self.wordCount = wordCount
        self.currentWordIndex = currentWordIndex
        self.settingsData = settingsData
        self.addedAt = addedAt
        self.lastOpenedAt = lastOpenedAt
    }
}

@Model
final class StoredBookmarkRecord {
    var id: UUID
    var bookID: UUID
    var wordIndex: Int
    var preview: String
    var createdAt: Date

    init(id: UUID, bookID: UUID, wordIndex: Int, preview: String, createdAt: Date) {
        self.id = id
        self.bookID = bookID
        self.wordIndex = wordIndex
        self.preview = preview
        self.createdAt = createdAt
    }
}

@MainActor
final class BookLibraryStore {
    private let modelContext: ModelContext
    private let retainedContainer: ModelContainer?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(modelContext: ModelContext, retainedContainer: ModelContainer? = nil) {
        self.modelContext = modelContext
        self.retainedContainer = retainedContainer
    }

    func createBook(
        title: String,
        sourceKind: BookSourceKind,
        text: String,
        settings: ReaderSettings,
        now: Date = Date()
    ) throws -> LibraryBookSnapshot {
        let snapshot = LibraryBookSnapshot.makeNewBook(
            title: title,
            sourceKind: sourceKind,
            text: text,
            settings: settings,
            now: now
        )
        guard snapshot.wordCount > 0 else {
            throw BookLibraryStoreError.emptyBook
        }

        let record = StoredBookRecord(
            id: snapshot.id,
            title: snapshot.title,
            sourceKindRawValue: snapshot.sourceKind.rawValue,
            text: snapshot.text,
            wordCount: snapshot.wordCount,
            currentWordIndex: snapshot.currentWordIndex,
            settingsData: try encoder.encode(snapshot.settings),
            addedAt: snapshot.addedAt,
            lastOpenedAt: snapshot.lastOpenedAt
        )
        modelContext.insert(record)
        try modelContext.save()
        return snapshot
    }

    func listBooks() throws -> [LibraryBookSnapshot] {
        let descriptor = FetchDescriptor<StoredBookRecord>(
            sortBy: [SortDescriptor(\.lastOpenedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).map(snapshot(from:))
    }

    func lastOpenedBook() throws -> LibraryBookSnapshot? {
        var descriptor = FetchDescriptor<StoredBookRecord>(
            sortBy: [SortDescriptor(\.lastOpenedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first.map(snapshot(from:))
    }

    func migrateLegacySession(
        _ snapshot: SavedSessionSnapshot,
        now: Date = Date()
    ) throws -> LibraryBookSnapshot? {
        let text = snapshot.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let words = RSVPTextProcessor.parseText(text)
        guard !words.isEmpty else {
            return nil
        }

        let currentWordIndex = min(words.count - 1, max(0, snapshot.currentWordIndex))
        let settingsData = try encoder.encode(snapshot.settings)

        if let record = try matchingBookRecord(text: text) {
            record.text = text
            record.wordCount = words.count
            record.currentWordIndex = currentWordIndex
            record.settingsData = settingsData
            record.lastOpenedAt = now
            try modelContext.save()
            return try self.snapshot(from: record)
        }

        let record = StoredBookRecord(
            id: UUID(),
            title: "Recovered Session",
            sourceKindRawValue: BookSourceKind.pastedText.rawValue,
            text: text,
            wordCount: words.count,
            currentWordIndex: currentWordIndex,
            settingsData: settingsData,
            addedAt: snapshot.savedAt,
            lastOpenedAt: now
        )
        modelContext.insert(record)
        try modelContext.save()
        return try self.snapshot(from: record)
    }

    func openBook(id: UUID, now: Date = Date()) throws -> LibraryBookSnapshot? {
        guard let record = try bookRecord(id: id) else {
            return nil
        }

        record.lastOpenedAt = now
        try modelContext.save()
        return try snapshot(from: record)
    }

    func deleteBook(id: UUID) throws {
        if let record = try bookRecord(id: id) {
            modelContext.delete(record)
        }

        let bookmarks = try bookmarkRecords(bookID: id)
        for bookmark in bookmarks {
            modelContext.delete(bookmark)
        }

        try modelContext.save()
    }

    func clearLibrary() throws {
        let books = try modelContext.fetch(FetchDescriptor<StoredBookRecord>())
        for book in books {
            modelContext.delete(book)
        }

        let bookmarks = try modelContext.fetch(FetchDescriptor<StoredBookmarkRecord>())
        for bookmark in bookmarks {
            modelContext.delete(bookmark)
        }

        try modelContext.save()
    }

    func updateBook(id: UUID, from session: ReadingSession, now: Date = Date()) throws {
        guard !session.words.isEmpty, let record = try bookRecord(id: id) else {
            return
        }

        record.text = session.text
        record.wordCount = session.words.count
        record.currentWordIndex = min(session.words.count - 1, max(0, session.currentWordIndex))
        record.settingsData = try encoder.encode(session.settings)
        record.lastOpenedAt = now
        try modelContext.save()
    }

    func toggleBookmark(
        bookID: UUID,
        wordIndex: Int,
        words: [String],
        now: Date = Date()
    ) throws -> BookmarkSnapshot? {
        if let existing = try bookmarkRecord(bookID: bookID, wordIndex: wordIndex) {
            modelContext.delete(existing)
            try modelContext.save()
            return nil
        }

        let snapshot = BookmarkSnapshot.makeNewBookmark(
            bookID: bookID,
            wordIndex: wordIndex,
            words: words,
            now: now
        )
        let record = StoredBookmarkRecord(
            id: snapshot.id,
            bookID: snapshot.bookID,
            wordIndex: snapshot.wordIndex,
            preview: snapshot.preview,
            createdAt: snapshot.createdAt
        )
        modelContext.insert(record)
        try modelContext.save()
        return snapshot
    }

    func deleteBookmark(bookID: UUID, wordIndex: Int) throws {
        if let existing = try bookmarkRecord(bookID: bookID, wordIndex: wordIndex) {
            modelContext.delete(existing)
            try modelContext.save()
        }
    }

    func bookmarks(for bookID: UUID) throws -> [BookmarkSnapshot] {
        let descriptor = FetchDescriptor<StoredBookmarkRecord>(
            predicate: #Predicate { $0.bookID == bookID },
            sortBy: [SortDescriptor(\.wordIndex)]
        )
        return try modelContext.fetch(descriptor).map(snapshot(from:))
    }

    func isBookmarked(bookID: UUID, wordIndex: Int) throws -> Bool {
        try bookmarkRecord(bookID: bookID, wordIndex: wordIndex) != nil
    }

    private func bookRecord(id: UUID) throws -> StoredBookRecord? {
        var descriptor = FetchDescriptor<StoredBookRecord>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    private func bookmarkRecords(bookID: UUID) throws -> [StoredBookmarkRecord] {
        let descriptor = FetchDescriptor<StoredBookmarkRecord>(
            predicate: #Predicate { $0.bookID == bookID }
        )
        return try modelContext.fetch(descriptor)
    }

    private func bookmarkRecord(bookID: UUID, wordIndex: Int) throws -> StoredBookmarkRecord? {
        var descriptor = FetchDescriptor<StoredBookmarkRecord>(
            predicate: #Predicate { $0.bookID == bookID && $0.wordIndex == wordIndex }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    private func matchingBookRecord(text: String) throws -> StoredBookRecord? {
        let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return try modelContext
            .fetch(FetchDescriptor<StoredBookRecord>())
            .first { record in
                record.text.trimmingCharacters(in: .whitespacesAndNewlines) == normalizedText
            }
    }

    private func snapshot(from record: StoredBookRecord) throws -> LibraryBookSnapshot {
        LibraryBookSnapshot(
            id: record.id,
            title: record.title,
            sourceKind: BookSourceKind(rawValue: record.sourceKindRawValue) ?? .pastedText,
            text: record.text,
            wordCount: record.wordCount,
            currentWordIndex: record.currentWordIndex,
            settings: try decoder.decode(ReaderSettings.self, from: record.settingsData),
            addedAt: record.addedAt,
            lastOpenedAt: record.lastOpenedAt
        )
    }

    private func snapshot(from record: StoredBookmarkRecord) -> BookmarkSnapshot {
        BookmarkSnapshot(
            id: record.id,
            bookID: record.bookID,
            wordIndex: record.wordIndex,
            preview: record.preview,
            createdAt: record.createdAt
        )
    }
}
