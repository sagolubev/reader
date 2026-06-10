import Foundation

@MainActor
protocol SessionPersisting: AnyObject {
    func save(_ session: ReadingSession, savedAt: Date) throws
    func load() throws -> SavedSessionSnapshot?
    func clear() throws
}

@MainActor
struct ReaderPersistenceActions {
    private let store: any SessionPersisting
    private let now: () -> Date

    init(store: any SessionPersisting, now: @escaping () -> Date = Date.init) {
        self.store = store
        self.now = now
    }

    func save(_ session: ReadingSession) throws {
        try store.save(session, savedAt: now())
    }

    func loadSavedSession() throws -> SavedSessionSnapshot? {
        try store.load()
    }

    func resume(_ snapshot: SavedSessionSnapshot, into session: inout ReadingSession) {
        session.restore(from: snapshot)
    }

    func startFresh() throws {
        try store.clear()
    }
}
