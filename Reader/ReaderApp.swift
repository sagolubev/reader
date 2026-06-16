import SwiftUI
import SwiftData

@main
struct ReaderApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [
            SavedReadingSessionRecord.self,
            StoredBookRecord.self,
            StoredBookmarkRecord.self
        ])
    }
}
