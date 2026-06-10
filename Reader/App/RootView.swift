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
            sessionStore: SessionStore(modelContext: modelContext),
            resetSavedSessionOnLaunch: launchOptions.resetSavedSessionOnLaunch
        )
    }
}

#Preview {
    RootView()
        .modelContainer(for: SavedReadingSessionRecord.self, inMemory: true)
}
