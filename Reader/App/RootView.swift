import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext

    private let launchOptions: ReaderLaunchOptions

    init(launchOptions: ReaderLaunchOptions = .current) {
        self.launchOptions = launchOptions
    }

    var body: some View {
        ReaderView(
            libraryStore: BookLibraryStore(modelContext: modelContext),
            legacySessionStore: SessionStore(modelContext: modelContext),
            resetSavedSessionOnLaunch: launchOptions.resetSavedSessionOnLaunch
        )
    }
}

#Preview {
    RootView()
        .modelContainer(
            for: [
                SavedReadingSessionRecord.self,
                StoredBookRecord.self,
                StoredBookmarkRecord.self
            ],
            inMemory: true
        )
}
