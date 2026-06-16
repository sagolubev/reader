import XCTest

final class UISmokeSourceTests: XCTestCase {
    func testUISmokeSuiteCoversLoadPlaybackJumpSaveAndResume() throws {
        let source = try sourceFile("ReaderUITests/ReaderUITests.swift")
        let expectedSnippets = [
            "testPlaybackJumpAndLibrarySmokeFlow",
            "--reader-ui-test-reset-session",
            "reader.add-book",
            "reader.open-library",
            "library.sheet",
            "library.empty",
            "library.add-book",
            "\"Play\"",
            "\"Pause\"",
            "reader.jump",
            "jump.target",
            "jump.submit"
        ]

        for expectedSnippet in expectedSnippets {
            XCTAssertTrue(
                source.contains(expectedSnippet),
                "Missing UI smoke snippet: \(expectedSnippet)"
            )
        }

        XCTAssertFalse(source.contains("reader.load-content"))
        XCTAssertFalse(source.contains("load-content.text-editor"))
        XCTAssertFalse(source.contains("load-content.load-text"))
    }

    func testAppExposesUITestSessionResetLaunchArgument() throws {
        let launchOptionsSource = try sourceFile("Reader/App/ReaderLaunchOptions.swift")
        let rootViewSource = try sourceFile("Reader/App/RootView.swift")
        let readerViewSource = try sourceFile("Reader/App/ReaderView.swift")

        XCTAssertTrue(launchOptionsSource.contains("--reader-ui-test-reset-session"))
        XCTAssertTrue(rootViewSource.contains("BookLibraryStore"))
        XCTAssertTrue(readerViewSource.contains("resetSavedSessionOnLaunch"))
        XCTAssertTrue(readerViewSource.contains("clearLibrary"))
    }

    func testBookmarkToggleLivesBelowSpeedControls() throws {
        let readerViewSource = try sourceFile("Reader/App/ReaderView.swift")
        let headerSource = try sourceFile("Reader/App/ReaderHeaderView.swift")
        let controlsSource = try sourceFile("Reader/App/ReaderControlsView.swift")

        let speedControlsRange = try XCTUnwrap(readerViewSource.range(of: "ReaderTouchControlsView("))
        let bookmarkControlsRange = try XCTUnwrap(readerViewSource.range(of: "ReaderBookmarkControlsView("))

        XCTAssertLessThan(speedControlsRange.lowerBound, bookmarkControlsRange.lowerBound)
        XCTAssertFalse(headerSource.contains("reader.toggle-bookmark"))
        XCTAssertTrue(controlsSource.contains("struct ReaderBookmarkControlsView"))
        XCTAssertTrue(controlsSource.contains("reader.toggle-bookmark"))
    }

    func testBookmarkToggleMatchesPrimaryPlayButtonSize() throws {
        let controlsSource = try sourceFile("Reader/App/ReaderControlsView.swift")
        let playbackControlsRange = try XCTUnwrap(controlsSource.range(of: "struct PlaybackControlsView"))
        let bookmarkControlsRange = try XCTUnwrap(controlsSource.range(of: "struct ReaderBookmarkControlsView"))
        let playbackControlsSource = String(controlsSource[playbackControlsRange.lowerBound..<bookmarkControlsRange.lowerBound])
        let bookmarkControlsSource = String(controlsSource[bookmarkControlsRange.lowerBound...])

        XCTAssertTrue(playbackControlsSource.contains("size: 58"))
        XCTAssertTrue(bookmarkControlsSource.contains("size: 58"))
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
