import XCTest

final class DocumentationSourceTests: XCTestCase {
    func testRootReadmeDocumentsUserWorkflowAndVerificationCommands() throws {
        let readme = try sourceFile("README.md")
        let expectedSnippets = [
            "# Reader",
            "Add books",
            "Library",
            "Bookmarks",
            "RSVP playback",
            "Save and resume",
            "swift test",
            "xcodebuild -scheme Reader",
            "-parallel-testing-enabled NO",
            "archive",
            "docs/ios-rsvp-reader-acceptance.md"
        ]

        for expectedSnippet in expectedSnippets {
            XCTAssertTrue(
                readme.contains(expectedSnippet),
                "Missing README snippet: \(expectedSnippet)"
            )
        }
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
