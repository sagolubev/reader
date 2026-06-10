import XCTest
@testable import ReaderCore

@MainActor
final class ReaderPersistenceActionsTests: XCTestCase {
    func testSaveActionWritesCurrentSessionWithTimestamp() throws {
        let store = RecordingSessionStore()
        let savedAt = Date(timeIntervalSince1970: 42)
        let actions = ReaderPersistenceActions(store: store, now: { savedAt })
        var session = ReadingSession()
        session.loadText("one two three")
        session.jump(to: "2")

        try actions.save(session)

        XCTAssertEqual(store.savedSession, session)
        XCTAssertEqual(store.savedAt, savedAt)
    }

    func testLoadSavedSessionReturnsSnapshotForPrompt() throws {
        let snapshot = makeSnapshot()
        let store = RecordingSessionStore(snapshot: snapshot)
        let actions = ReaderPersistenceActions(store: store)

        XCTAssertEqual(try actions.loadSavedSession(), snapshot)
    }

    func testResumeActionRestoresSnapshotIntoSession() {
        let actions = ReaderPersistenceActions(store: RecordingSessionStore())
        var session = ReadingSession()

        actions.resume(makeSnapshot(), into: &session)

        XCTAssertEqual(session.text, "zero one two three")
        XCTAssertEqual(session.currentWordIndex, 2)
        XCTAssertEqual(session.progressPercentage, 50)
        XCTAssertEqual(session.settings.wordsPerMinute, 450)
        XCTAssertEqual(session.settings.pauseOnPunctuation, false)
        XCTAssertEqual(session.playbackState, .stopped)
    }

    func testStartFreshClearsSavedSession() throws {
        let store = RecordingSessionStore(snapshot: makeSnapshot())
        let actions = ReaderPersistenceActions(store: store)

        try actions.startFresh()

        XCTAssertTrue(store.didClear)
    }

    private func makeSnapshot() -> SavedSessionSnapshot {
        var settings = ReaderSettings()
        settings.wordsPerMinute = 450
        settings.pauseOnPunctuation = false

        return SavedSessionSnapshot(
            text: "zero one two three",
            currentWordIndex: 2,
            totalWordCount: 4,
            settings: settings,
            savedAt: Date(timeIntervalSince1970: 123)
        )
    }
}

@MainActor
private final class RecordingSessionStore: SessionPersisting {
    private var snapshot: SavedSessionSnapshot?
    private(set) var savedSession: ReadingSession?
    private(set) var savedAt: Date?
    private(set) var didClear = false

    init(snapshot: SavedSessionSnapshot? = nil) {
        self.snapshot = snapshot
    }

    func save(_ session: ReadingSession, savedAt: Date) throws {
        savedSession = session
        self.savedAt = savedAt
    }

    func load() throws -> SavedSessionSnapshot? {
        snapshot
    }

    func clear() throws {
        didClear = true
        snapshot = nil
    }
}
