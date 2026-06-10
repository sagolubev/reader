import Foundation
import SwiftData

struct SavedSessionSnapshot: Equatable {
    let text: String
    let currentWordIndex: Int
    let totalWordCount: Int
    let settings: ReaderSettings
    let savedAt: Date
}

@Model
final class SavedReadingSessionRecord {
    var text: String
    var currentWordIndex: Int
    var totalWordCount: Int
    var settingsData: Data
    var savedAt: Date

    init(
        text: String,
        currentWordIndex: Int,
        totalWordCount: Int,
        settingsData: Data,
        savedAt: Date
    ) {
        self.text = text
        self.currentWordIndex = currentWordIndex
        self.totalWordCount = totalWordCount
        self.settingsData = settingsData
        self.savedAt = savedAt
    }
}

@MainActor
final class SessionStore {
    private let modelContext: ModelContext
    private let retainedContainer: ModelContainer?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(modelContext: ModelContext, retainedContainer: ModelContainer? = nil) {
        self.modelContext = modelContext
        self.retainedContainer = retainedContainer
    }

    func save(_ session: ReadingSession, savedAt: Date = Date()) throws {
        guard !session.words.isEmpty else {
            return
        }

        try clear()

        let record = SavedReadingSessionRecord(
            text: session.text,
            currentWordIndex: session.currentWordIndex,
            totalWordCount: session.words.count,
            settingsData: try encoder.encode(session.settings),
            savedAt: savedAt
        )
        modelContext.insert(record)
        try modelContext.save()
    }

    func load() throws -> SavedSessionSnapshot? {
        var descriptor = FetchDescriptor<SavedReadingSessionRecord>(
            sortBy: [SortDescriptor(\.savedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1

        guard let record = try modelContext.fetch(descriptor).first else {
            return nil
        }

        return SavedSessionSnapshot(
            text: record.text,
            currentWordIndex: record.currentWordIndex,
            totalWordCount: record.totalWordCount,
            settings: try decoder.decode(ReaderSettings.self, from: record.settingsData),
            savedAt: record.savedAt
        )
    }

    func clear() throws {
        let records = try modelContext.fetch(FetchDescriptor<SavedReadingSessionRecord>())
        for record in records {
            modelContext.delete(record)
        }
        try modelContext.save()
    }
}

extension ReadingSession {
    mutating func restore(from snapshot: SavedSessionSnapshot) {
        loadText(snapshot.text)
        currentWordIndex = restoredIndex(snapshot.currentWordIndex)
        settings = snapshot.settings
        playbackState = .stopped
    }

    private func restoredIndex(_ index: Int) -> Int {
        guard !words.isEmpty else {
            return 0
        }

        return min(words.count - 1, max(0, index))
    }
}
