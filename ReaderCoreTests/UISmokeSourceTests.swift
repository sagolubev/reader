import XCTest

final class UISmokeSourceTests: XCTestCase {
    func testUISmokeSuiteCoversLoadPlaybackJumpSaveAndResume() throws {
        let source = try sourceFile("ReaderUITests/ReaderUITests.swift")
        let expectedSnippets = [
            "testLoadPlaybackJumpSaveAndResumeSmokeFlow",
            "--reader-ui-test-reset-session",
            "reader.load-content",
            "load-content.text-editor",
            "load-content.load-text",
            "\"Play\"",
            "\"Pause\"",
            "reader.jump",
            "jump.target",
            "jump.submit",
            "reader.save-session",
            "resume-session.resume"
        ]

        for expectedSnippet in expectedSnippets {
            XCTAssertTrue(
                source.contains(expectedSnippet),
                "Missing UI smoke snippet: \(expectedSnippet)"
            )
        }
    }

    func testAppExposesUITestSessionResetLaunchArgument() throws {
        let launchOptionsSource = try sourceFile("Reader/App/ReaderLaunchOptions.swift")
        let rootViewSource = try sourceFile("Reader/App/RootView.swift")
        let readerViewSource = try sourceFile("Reader/App/ReaderView.swift")

        XCTAssertTrue(launchOptionsSource.contains("--reader-ui-test-reset-session"))
        XCTAssertTrue(rootViewSource.contains("ReaderLaunchOptions"))
        XCTAssertTrue(readerViewSource.contains("resetSavedSessionOnLaunch"))
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
