import XCTest

final class ReaderProgressSummarySourceTests: XCTestCase {
    func testProgressSummaryUsesReadableForegroundBrightness() throws {
        let source = try sourceFile("Reader/App/ReaderView.swift")

        XCTAssertTrue(source.contains(".accessibilityIdentifier(\"reader.progress-summary\")"))
        XCTAssertTrue(source.contains(".foregroundStyle(ReaderTheme.secondaryText)"))
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
