import XCTest

final class AccessibilitySourceTests: XCTestCase {
    func testSettingsCompactControlsDeclareAccessibilityLabels() throws {
        let source = try settingsViewSource()

        let expectedLabels = [
            "\"Words per minute\"",
            "\"Set 200 words per minute\"",
            "\"Set 300 words per minute\"",
            "\"Set 400 words per minute\"",
            "\"Set 500 words per minute\"",
            "\"Long-word pause\"",
            "\"Fade duration\"",
            "\"Punctuation multiplier\"",
            "\"Pause interval\"",
            "\"Pause duration\""
        ]

        for expectedLabel in expectedLabels {
            XCTAssertTrue(
                source.contains(expectedLabel),
                "Missing accessibility label: \(expectedLabel)"
            )
        }
    }

    private func settingsViewSource() throws -> String {
        let testFile = URL(fileURLWithPath: #filePath)
        let repoRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repoRoot.appendingPathComponent("Reader/App/SettingsView.swift")
        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
