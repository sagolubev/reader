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

    private func sourceFile(_ path: String) throws -> String {
        let testFile = URL(fileURLWithPath: #filePath)
        let repoRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repoRoot.appendingPathComponent(path)
        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
