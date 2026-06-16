import XCTest
@testable import ReaderCore

final class LibraryDomainTests: XCTestCase {
    func testBookSnapshotDerivesTitleAndWordCountFromImportedText() {
        let book = LibraryBookSnapshot.makeNewBook(
            title: "",
            sourceKind: .pastedText,
            text: "  One   two three four five six seven  ",
            settings: ReaderSettings(),
            now: Date(timeIntervalSince1970: 100)
        )

        XCTAssertEqual(book.title, "One two three four five")
        XCTAssertEqual(book.sourceKind, .pastedText)
        XCTAssertEqual(book.wordCount, 7)
        XCTAssertEqual(book.currentWordIndex, 0)
        XCTAssertEqual(book.addedAt, Date(timeIntervalSince1970: 100))
        XCTAssertEqual(book.lastOpenedAt, Date(timeIntervalSince1970: 100))
    }

    func testBookSnapshotUsesProvidedFileTitle() {
        let book = LibraryBookSnapshot.makeNewBook(
            title: "Book Title.pdf",
            sourceKind: .pdf,
            text: "one two",
            settings: ReaderSettings(),
            now: Date(timeIntervalSince1970: 100)
        )

        XCTAssertEqual(book.title, "Book Title")
        XCTAssertEqual(book.sourceKind, .pdf)
    }

    func testReadingSessionRestoresFromLibraryBook() {
        var settings = ReaderSettings()
        settings.wordsPerMinute = 450
        settings.pauseOnPunctuation = false

        let book = LibraryBookSnapshot(
            id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!,
            title: "Stored Book",
            sourceKind: .epub,
            text: "zero one two three",
            wordCount: 4,
            currentWordIndex: 2,
            settings: settings,
            addedAt: Date(timeIntervalSince1970: 10),
            lastOpenedAt: Date(timeIntervalSince1970: 20)
        )

        var session = ReadingSession()
        session.restore(from: book)

        XCTAssertEqual(session.text, "zero one two three")
        XCTAssertEqual(session.words, ["zero", "one", "two", "three"])
        XCTAssertEqual(session.currentWordIndex, 2)
        XCTAssertEqual(session.settings.wordsPerMinute, 450)
        XCTAssertEqual(session.settings.pauseOnPunctuation, false)
        XCTAssertEqual(session.playbackState, .stopped)
    }

    func testBookmarkSnapshotBuildsPreviewAroundWordIndex() {
        let words = ["zero", "one", "two", "three", "four", "five"]
        let bookmark = BookmarkSnapshot.makeNewBookmark(
            bookID: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!,
            wordIndex: 3,
            words: words,
            now: Date(timeIntervalSince1970: 200)
        )

        XCTAssertEqual(bookmark.wordIndex, 3)
        XCTAssertEqual(bookmark.preview, "one two three four five")
        XCTAssertEqual(bookmark.createdAt, Date(timeIntervalSince1970: 200))
    }

    func testBookmarkSnapshotMatchesBookAndWordIndex() {
        let bookID = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!
        let otherBookID = UUID(uuidString: "11111111-2222-3333-4444-555555555555")!
        let bookmark = BookmarkSnapshot.makeNewBookmark(
            bookID: bookID,
            wordIndex: 2,
            words: ["zero", "one", "two"],
            now: Date(timeIntervalSince1970: 200)
        )

        XCTAssertTrue(bookmark.matches(bookID: bookID, wordIndex: 2))
        XCTAssertFalse(bookmark.matches(bookID: bookID, wordIndex: 1))
        XCTAssertFalse(bookmark.matches(bookID: otherBookID, wordIndex: 2))
    }
}
