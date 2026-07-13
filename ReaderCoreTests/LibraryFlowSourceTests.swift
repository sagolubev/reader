import XCTest

final class LibraryFlowSourceTests: XCTestCase {
    func testReaderViewWiresImportToLibraryBookCreation() throws {
        let readerView = try sourceFile("Reader/App/ReaderView.swift")
        let importedContent = try sourceFile("Reader/App/ImportedContent.swift")
        let sourceKindURL = try sourceFile("Reader/Domain/BookSourceKind+URL.swift")

        XCTAssertTrue(readerView.contains("BookLibraryStore"))
        XCTAssertTrue(readerView.contains("createBook"))
        XCTAssertTrue(readerView.contains("openLibraryBook"))
        XCTAssertTrue(importedContent.contains("struct ImportedContent"))
        XCTAssertTrue(sourceKindURL.contains("extension BookSourceKind"))
        XCTAssertTrue(sourceKindURL.contains("init(url: URL)"))
    }

    func testRootViewWiresLastOpenedBookLaunchAndLibraryReset() throws {
        let rootView = try sourceFile("Reader/App/RootView.swift")
        let readerView = try sourceFile("Reader/App/ReaderView.swift")
        let app = try sourceFile("Reader/ReaderApp.swift")

        XCTAssertTrue(rootView.contains("BookLibraryStore"))
        XCTAssertTrue(rootView.contains("SessionStore"))
        XCTAssertTrue(readerView.contains("lastOpenedBook"))
        XCTAssertTrue(readerView.contains("migrateLegacySession"))
        XCTAssertTrue(readerView.contains("clearLibrary"))
        XCTAssertTrue(app.contains("StoredBookRecord"))
        XCTAssertTrue(app.contains("StoredBookmarkRecord"))
    }

    func testLibraryRowsExposeLongPressDeleteMenu() throws {
        let libraryView = try sourceFile("Reader/App/LibraryView.swift")

        XCTAssertTrue(libraryView.contains(".contextMenu"))
        XCTAssertTrue(libraryView.contains("Button(role: .destructive)"))
        XCTAssertTrue(libraryView.contains("onDeleteBook(book)"))
        XCTAssertTrue(libraryView.contains("Label(\"Delete\", systemImage: \"trash\")"))
    }

    func testLibraryViewExposesAddBookFileImporter() throws {
        let libraryView = try sourceFile("Reader/App/LibraryView.swift")

        XCTAssertTrue(libraryView.contains("onAddBook: (URL) -> Void"))
        XCTAssertTrue(libraryView.contains("Button(action: showFileImporter)"))
        XCTAssertTrue(libraryView.contains("Label(\"Add Book\", systemImage: \"plus\")"))
        XCTAssertTrue(libraryView.contains(".accessibilityIdentifier(\"library.add-book\")"))
        XCTAssertTrue(libraryView.contains(".fileImporter("))
        XCTAssertTrue(libraryView.contains("allowedContentTypes: SupportedBookFileTypes.documentTypes"))
        XCTAssertTrue(libraryView.contains("handleFileSelection"))
    }

    func testBookFilePickerUsesContentFallbackForProviderSpecificBookTypes() throws {
        let supportedTypes = try sourceFile("Reader/App/SupportedBookFileTypes.swift")

        XCTAssertTrue(supportedTypes.contains("static let documentTypes: [UTType] = [.pdf, .epubDocument, .content]"))
        XCTAssertFalse(supportedTypes.contains("com.apple.ibooks.epub"))
    }

    func testLibraryAddBookUsesDirectFileSelectionInsteadOfLoadContentSheet() throws {
        let readerView = try sourceFile("Reader/App/ReaderView.swift")

        let libraryCase = try XCTUnwrap(readerView.range(of: "case .library:"))
        let bookmarksCase = try XCTUnwrap(readerView.range(of: "case .bookmarks:"))
        let librarySheetSource = String(readerView[libraryCase.lowerBound..<bookmarksCase.lowerBound])

        XCTAssertTrue(librarySheetSource.contains("onAddBook: importLibraryBookFile"))
        XCTAssertFalse(librarySheetSource.contains("showLoadContent"))
        XCTAssertFalse(librarySheetSource.contains(".loadContent"))
        XCTAssertTrue(readerView.contains("private func importLibraryBookFile(_ url: URL)"))
        XCTAssertTrue(readerView.contains("DocumentImportService().importText(from: url)"))
        XCTAssertTrue(readerView.contains("loadImportedContent(ImportedContent("))
    }

    func testReaderImportsDocumentsAwayFromMainActor() throws {
        let readerView = try sourceFile("Reader/App/ReaderView.swift")

        XCTAssertTrue(readerView.contains("Task.detached(priority: .userInitiated)"))
        XCTAssertTrue(readerView.contains("try await importTask.value"))
    }

    func testReaderHeaderAddBookUsesDirectFileSelectionInsteadOfLoadContentSheet() throws {
        let readerView = try sourceFile("Reader/App/ReaderView.swift")
        let headerView = try sourceFile("Reader/App/ReaderHeaderView.swift")

        XCTAssertTrue(headerView.contains("onAddBook: () -> Void"))
        XCTAssertTrue(headerView.contains("accessibilityLabel: \"Add book\""))
        XCTAssertTrue(headerView.contains("accessibilityIdentifier: \"reader.add-book\""))
        XCTAssertFalse(headerView.contains("onLoadContent"))

        XCTAssertTrue(readerView.contains("@State private var isBookFileImporterPresented = false"))
        XCTAssertTrue(readerView.contains("onAddBook: showBookFileImporter"))
        XCTAssertTrue(readerView.contains(".fileImporter("))
        XCTAssertTrue(readerView.contains("allowedContentTypes: SupportedBookFileTypes.documentTypes"))
        XCTAssertTrue(readerView.contains("handleBookFileSelection"))
        XCTAssertFalse(readerView.contains("LoadContentView"))
        XCTAssertFalse(readerView.contains("showLoadContent"))
        XCTAssertFalse(readerView.contains("case .loadContent"))
        XCTAssertFalse(readerView.contains("presentedSheet = .loadContent"))
    }

    func testReaderFileSelectionStartsSecurityScopedAccessBeforeAsyncImport() throws {
        let readerView = try sourceFile("Reader/App/ReaderView.swift")
        let importSource = try sourceSlice(
            readerView,
            from: "private func importLibraryBookFile(_ url: URL)",
            to: "private func handleBookFileSelection"
        )
        let handleSelectionSource = try sourceSlice(
            readerView,
            from: "private func handleBookFileSelection",
            to: "private func openLibraryBook"
        )

        let startAccess = try XCTUnwrap(importSource.range(of: "url.startAccessingSecurityScopedResource()"))
        let asyncImport = try XCTUnwrap(importSource.range(of: "Task {"))

        XCTAssertTrue(startAccess.lowerBound < asyncImport.lowerBound)
        XCTAssertFalse(importSource.contains("await Task.yield()"))
        XCTAssertTrue(handleSelectionSource.contains("importLibraryBookFile(url)"))
        XCTAssertFalse(handleSelectionSource.contains("Task { @MainActor"))
    }

    private func sourceFile(_ path: String) throws -> String {
        let testFile = URL(fileURLWithPath: #filePath)
        let repoRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repoRoot.appendingPathComponent(path)
        return try String(contentsOf: sourceURL, encoding: .utf8)
    }

    private func sourceSlice(_ source: String, from startMarker: String, to endMarker: String) throws -> String {
        let start = try XCTUnwrap(source.range(of: startMarker))
        let end = try XCTUnwrap(source.range(of: endMarker, range: start.upperBound..<source.endIndex))
        return String(source[start.lowerBound..<end.lowerBound])
    }
}
