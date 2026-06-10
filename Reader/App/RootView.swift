import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ReaderView(sessionStore: SessionStore(modelContext: modelContext))
    }
}

#Preview {
    RootView()
        .modelContainer(for: SavedReadingSessionRecord.self, inMemory: true)
}
