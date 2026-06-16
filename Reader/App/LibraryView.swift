import SwiftUI

struct LibraryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isFileImporterPresented = false

    let books: [LibraryBookSnapshot]
    let activeBookID: UUID?
    let onOpenBook: (LibraryBookSnapshot) -> Void
    let onAddBook: (URL) -> Void
    let onDeleteBook: (LibraryBookSnapshot) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                ReaderTheme.background.ignoresSafeArea()

                if books.isEmpty {
                    ContentUnavailableView(
                        "No Books",
                        systemImage: "books.vertical",
                        description: Text("Import text, PDF, or EPUB to add a book.")
                    )
                    .foregroundStyle(ReaderTheme.primaryText)
                    .accessibilityIdentifier("library.empty")
                } else {
                    List {
                        ForEach(books) { book in
                            Button {
                                onOpenBook(book)
                                dismiss()
                            } label: {
                                LibraryBookRow(book: book, isActive: book.id == activeBookID)
                            }
                            .accessibilityIdentifier("library.book")
                            .swipeActions {
                                deleteBookButton(book)
                            }
                            .contextMenu {
                                deleteBookButton(book)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .accessibilityIdentifier("library.list")
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(action: showFileImporter) {
                        Label("Add Book", systemImage: "plus")
                    }
                    .accessibilityIdentifier("library.add-book")
                }
            }
        }
        .tint(ReaderTheme.accent)
        .accessibilityIdentifier("library.sheet")
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: SupportedBookFileTypes.documentTypes,
            allowsMultipleSelection: false,
            onCompletion: handleFileSelection
        )
    }

    private func showFileImporter() {
        isFileImporterPresented = true
    }

    private func handleFileSelection(_ result: Result<[URL], Error>) {
        guard case .success(let urls) = result, let url = urls.first else {
            return
        }

        onAddBook(url)
    }

    private func deleteBookButton(_ book: LibraryBookSnapshot) -> some View {
        Button(role: .destructive) {
            onDeleteBook(book)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

private struct LibraryBookRow: View {
    let book: LibraryBookSnapshot
    let isActive: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundStyle(isActive ? ReaderTheme.accent : ReaderTheme.secondaryText)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .foregroundStyle(ReaderTheme.primaryText)
                    .lineLimit(1)

                Text("\(book.wordCount) words · \(Int(bookProgress))%")
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }

    private var bookProgress: Double {
        guard book.wordCount > 0 else {
            return 0
        }

        return (Double(book.currentWordIndex) / Double(book.wordCount)) * 100
    }

    private var iconName: String {
        switch book.sourceKind {
        case .pastedText:
            return "text.alignleft"
        case .pdf:
            return "doc.richtext"
        case .epub:
            return "book"
        }
    }
}

#Preview {
    LibraryView(
        books: [
            LibraryBookSnapshot.makeNewBook(
                title: "Sample",
                sourceKind: .pastedText,
                text: "one two three",
                settings: ReaderSettings()
            )
        ],
        activeBookID: nil,
        onOpenBook: { _ in },
        onAddBook: { _ in },
        onDeleteBook: { _ in }
    )
}
