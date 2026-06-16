import SwiftUI

struct BookmarksView: View {
    @Environment(\.dismiss) private var dismiss

    let bookmarks: [BookmarkSnapshot]
    let onSelectBookmark: (BookmarkSnapshot) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                ReaderTheme.background.ignoresSafeArea()

                if bookmarks.isEmpty {
                    ContentUnavailableView(
                        "No Bookmarks",
                        systemImage: "bookmark",
                        description: Text("Tap the bookmark button while reading to save a position.")
                    )
                    .foregroundStyle(ReaderTheme.primaryText)
                    .accessibilityIdentifier("bookmarks.empty")
                } else {
                    List(bookmarks) { bookmark in
                        Button {
                            onSelectBookmark(bookmark)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(bookmark.preview)
                                    .font(.body)
                                    .foregroundStyle(ReaderTheme.primaryText)
                                    .lineLimit(2)

                                Text("Word \(bookmark.wordIndex + 1)")
                                    .font(.footnote.monospacedDigit())
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 6)
                        }
                        .accessibilityIdentifier("bookmarks.bookmark")
                    }
                    .scrollContentBackground(.hidden)
                    .accessibilityIdentifier("bookmarks.list")
                }
            }
            .navigationTitle("Bookmarks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .tint(ReaderTheme.accent)
        .accessibilityIdentifier("bookmarks.sheet")
    }
}

#Preview {
    BookmarksView(
        bookmarks: [
            BookmarkSnapshot.makeNewBookmark(
                bookID: UUID(),
                wordIndex: 2,
                words: ["zero", "one", "two", "three", "four"]
            )
        ],
        onSelectBookmark: { _ in }
    )
}
