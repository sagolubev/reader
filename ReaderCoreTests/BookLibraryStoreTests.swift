import SwiftData
import XCTest
@testable import ReaderCore

@MainActor
final class BookLibraryStoreTests: XCTestCase {
    func testCreateListOpenAndDeleteBooks() throws {
        let store = try makeStore()
        let firstDate = Date(timeIntervalSince1970: 100)
        let secondDate = Date(timeIntervalSince1970: 200)

        let first = try store.createBook(
            title: "First.pdf",
            sourceKind: .pdf,
            text: "one two three",
            settings: ReaderSettings(),
            now: firstDate
        )
        let second = try store.createBook(
            title: "Second",
            sourceKind: .epub,
            text: "four five",
            settings: ReaderSettings(),
            now: secondDate
        )

        XCTAssertEqual(first.title, "First")
        XCTAssertEqual(first.wordCount, 3)
        XCTAssertEqual(second.title, "Second")

        let listed = try store.listBooks()
        XCTAssertEqual(listed.map(\.id), [second.id, first.id])

        let opened = try XCTUnwrap(store.openBook(id: first.id, now: Date(timeIntervalSince1970: 300)))
        XCTAssertEqual(opened.id, first.id)
        XCTAssertEqual(opened.lastOpenedAt, Date(timeIntervalSince1970: 300))
        XCTAssertEqual(try store.lastOpenedBook()?.id, first.id)

        try store.deleteBook(id: first.id)

        XCTAssertNil(try store.openBook(id: first.id))
        XCTAssertEqual(try store.listBooks().map(\.id), [second.id])
    }

    func testUpdateBookPersistsProgressSettingsAndLastOpenedDate() throws {
        let store = try makeStore()
        let book = try store.createBook(
            title: "Progress",
            sourceKind: .pastedText,
            text: "zero one two three",
            settings: ReaderSettings(),
            now: Date(timeIntervalSince1970: 100)
        )
        var session = ReadingSession()
        session.restore(from: book)
        session.jump(to: "3")
        session.settings.wordsPerMinute = 450
        session.settings.pauseOnPunctuation = false

        try store.updateBook(
            id: book.id,
            from: session,
            now: Date(timeIntervalSince1970: 400)
        )

        let reopened = try XCTUnwrap(store.openBook(id: book.id, now: Date(timeIntervalSince1970: 500)))
        XCTAssertEqual(reopened.currentWordIndex, 3)
        XCTAssertEqual(reopened.wordCount, 4)
        XCTAssertEqual(reopened.settings.wordsPerMinute, 450)
        XCTAssertEqual(reopened.settings.pauseOnPunctuation, false)
        XCTAssertEqual(reopened.lastOpenedAt, Date(timeIntervalSince1970: 500))
    }

    func testMigrateLegacySessionUpdatesMatchingBookWithoutDuplicatingIt() throws {
        let store = try makeStore()
        let book = try store.createBook(
            title: "Existing.pdf",
            sourceKind: .pdf,
            text: "zero one two three four",
            settings: ReaderSettings(),
            now: Date(timeIntervalSince1970: 100)
        )
        var legacySettings = ReaderSettings()
        legacySettings.wordsPerMinute = 450
        legacySettings.pauseOnPunctuation = false
        let legacy = SavedSessionSnapshot(
            text: "zero one two three four",
            currentWordIndex: 3,
            totalWordCount: 5,
            settings: legacySettings,
            savedAt: Date(timeIntervalSince1970: 200)
        )

        let migrated = try XCTUnwrap(store.migrateLegacySession(
            legacy,
            now: Date(timeIntervalSince1970: 300)
        ))

        XCTAssertEqual(migrated.id, book.id)
        XCTAssertEqual(migrated.title, "Existing")
        XCTAssertEqual(migrated.currentWordIndex, 3)
        XCTAssertEqual(migrated.settings.wordsPerMinute, 450)
        XCTAssertEqual(migrated.settings.pauseOnPunctuation, false)
        XCTAssertEqual(migrated.lastOpenedAt, Date(timeIntervalSince1970: 300))
        XCTAssertEqual(try store.listBooks().map(\.id), [book.id])
    }

    func testMigrateLegacySessionCreatesBookWhenNoMatchingBookExists() throws {
        let store = try makeStore()
        var legacySettings = ReaderSettings()
        legacySettings.wordsPerMinute = 500
        let legacy = SavedSessionSnapshot(
            text: "legacy session text",
            currentWordIndex: 2,
            totalWordCount: 3,
            settings: legacySettings,
            savedAt: Date(timeIntervalSince1970: 200)
        )

        let migrated = try XCTUnwrap(store.migrateLegacySession(
            legacy,
            now: Date(timeIntervalSince1970: 300)
        ))

        XCTAssertEqual(migrated.title, "Recovered Session")
        XCTAssertEqual(migrated.text, "legacy session text")
        XCTAssertEqual(migrated.wordCount, 3)
        XCTAssertEqual(migrated.currentWordIndex, 2)
        XCTAssertEqual(migrated.settings.wordsPerMinute, 500)
        XCTAssertEqual(migrated.addedAt, Date(timeIntervalSince1970: 200))
        XCTAssertEqual(migrated.lastOpenedAt, Date(timeIntervalSince1970: 300))
        XCTAssertEqual(try store.lastOpenedBook()?.id, migrated.id)
    }

    func testToggleBookmarksListByBookAndCleanupWithBookDeletion() throws {
        let store = try makeStore()
        let first = try store.createBook(
            title: "First",
            sourceKind: .pastedText,
            text: "zero one two three four five",
            settings: ReaderSettings(),
            now: Date(timeIntervalSince1970: 100)
        )
        let second = try store.createBook(
            title: "Second",
            sourceKind: .pastedText,
            text: "alpha beta gamma",
            settings: ReaderSettings(),
            now: Date(timeIntervalSince1970: 200)
        )

        let added = try XCTUnwrap(store.toggleBookmark(
            bookID: first.id,
            wordIndex: 3,
            words: RSVPTextProcessor.parseText(first.text),
            now: Date(timeIntervalSince1970: 300)
        ))
        XCTAssertEqual(added.preview, "one two three four five")
        XCTAssertTrue(try store.isBookmarked(bookID: first.id, wordIndex: 3))
        XCTAssertFalse(try store.isBookmarked(bookID: second.id, wordIndex: 3))

        _ = try store.toggleBookmark(
            bookID: second.id,
            wordIndex: 1,
            words: RSVPTextProcessor.parseText(second.text),
            now: Date(timeIntervalSince1970: 350)
        )
        XCTAssertEqual(try store.bookmarks(for: first.id).map(\.wordIndex), [3])
        XCTAssertEqual(try store.bookmarks(for: second.id).map(\.wordIndex), [1])

        let removed = try store.toggleBookmark(
            bookID: first.id,
            wordIndex: 3,
            words: RSVPTextProcessor.parseText(first.text),
            now: Date(timeIntervalSince1970: 400)
        )
        XCTAssertNil(removed)
        XCTAssertFalse(try store.isBookmarked(bookID: first.id, wordIndex: 3))

        _ = try store.toggleBookmark(
            bookID: first.id,
            wordIndex: 2,
            words: RSVPTextProcessor.parseText(first.text),
            now: Date(timeIntervalSince1970: 450)
        )
        try store.deleteBook(id: first.id)

        XCTAssertEqual(try store.bookmarks(for: first.id), [])
        XCTAssertEqual(try store.bookmarks(for: second.id).map(\.wordIndex), [1])
    }

    func testDeleteBookmarkRemovesOnlyMatchingBookmark() throws {
        let store = try makeStore()
        let first = try store.createBook(
            title: "First",
            sourceKind: .pastedText,
            text: "zero one two three four five",
            settings: ReaderSettings(),
            now: Date(timeIntervalSince1970: 100)
        )
        let second = try store.createBook(
            title: "Second",
            sourceKind: .pastedText,
            text: "alpha beta gamma",
            settings: ReaderSettings(),
            now: Date(timeIntervalSince1970: 200)
        )

        _ = try store.toggleBookmark(
            bookID: first.id,
            wordIndex: 2,
            words: RSVPTextProcessor.parseText(first.text),
            now: Date(timeIntervalSince1970: 300)
        )
        _ = try store.toggleBookmark(
            bookID: first.id,
            wordIndex: 4,
            words: RSVPTextProcessor.parseText(first.text),
            now: Date(timeIntervalSince1970: 350)
        )
        _ = try store.toggleBookmark(
            bookID: second.id,
            wordIndex: 2,
            words: RSVPTextProcessor.parseText(second.text),
            now: Date(timeIntervalSince1970: 400)
        )

        try store.deleteBookmark(bookID: first.id, wordIndex: 2)

        XCTAssertFalse(try store.isBookmarked(bookID: first.id, wordIndex: 2))
        XCTAssertEqual(try store.bookmarks(for: first.id).map(\.wordIndex), [4])
        XCTAssertEqual(try store.bookmarks(for: second.id).map(\.wordIndex), [2])
    }

    private func makeStore() throws -> BookLibraryStore {
        let schema = Schema([StoredBookRecord.self, StoredBookmarkRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
        return BookLibraryStore(modelContext: container.mainContext, retainedContainer: container)
    }
}
