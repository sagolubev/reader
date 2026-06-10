import SwiftData
import XCTest
@testable import ReaderCore

@MainActor
final class SessionStoreTests: XCTestCase {
    func testSaveWritesActiveSessionWithPositionSettingsAndTimestamp() throws {
        let store = try makeStore()
        var session = ReadingSession()
        session.loadText("zero one two three")
        session.jump(to: "2")
        session.settings.wordsPerMinute = 450
        session.settings.pauseOnPunctuation = false
        session.settings.frameWordCount = 5
        let savedAt = Date(timeIntervalSince1970: 1_234)

        try store.save(session, savedAt: savedAt)

        let snapshot = try XCTUnwrap(store.load())
        XCTAssertEqual(snapshot.text, "zero one two three")
        XCTAssertEqual(snapshot.currentWordIndex, 2)
        XCTAssertEqual(snapshot.totalWordCount, 4)
        XCTAssertEqual(snapshot.settings.wordsPerMinute, 450)
        XCTAssertEqual(snapshot.settings.pauseOnPunctuation, false)
        XCTAssertEqual(snapshot.settings.frameWordCount, 5)
        XCTAssertEqual(snapshot.savedAt, savedAt)
    }

    func testSaveWithoutContentDoesNotWriteSession() throws {
        let store = try makeStore()

        try store.save(ReadingSession(), savedAt: Date(timeIntervalSince1970: 1_234))

        XCTAssertNil(try store.load())
    }

    func testClearRemovesSavedSession() throws {
        let store = try makeStore()
        var session = ReadingSession()
        session.loadText("one two")
        try store.save(session)

        try store.clear()

        XCTAssertNil(try store.load())
    }

    func testSavedSnapshotRestoresSessionPositionAndSettings() throws {
        let store = try makeStore()
        var savedSession = ReadingSession()
        savedSession.loadText("zero one two three")
        savedSession.jump(to: "3")
        savedSession.settings.wordsPerMinute = 450
        savedSession.settings.pauseOnPunctuation = false
        try store.save(savedSession)

        let snapshot = try XCTUnwrap(store.load())
        var restoredSession = ReadingSession()
        restoredSession.restore(from: snapshot)

        XCTAssertEqual(restoredSession.text, savedSession.text)
        XCTAssertEqual(restoredSession.words, savedSession.words)
        XCTAssertEqual(restoredSession.currentWordIndex, 3)
        XCTAssertEqual(restoredSession.progressPercentage, 75)
        XCTAssertEqual(restoredSession.settings.wordsPerMinute, 450)
        XCTAssertEqual(restoredSession.settings.pauseOnPunctuation, false)
        XCTAssertEqual(restoredSession.playbackState, .stopped)
    }

    private func makeStore() throws -> SessionStore {
        let schema = Schema([SavedReadingSessionRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
        return SessionStore(modelContext: container.mainContext, retainedContainer: container)
    }
}
