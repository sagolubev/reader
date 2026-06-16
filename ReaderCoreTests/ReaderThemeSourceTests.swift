import XCTest

final class ReaderThemeSourceTests: XCTestCase {
    func testReaderThemeDefinesWarmLightPalette() throws {
        let themePath = "Reader/App/ReaderTheme.swift"
        let themeURL = repoRoot().appendingPathComponent(themePath)

        XCTAssertTrue(
            FileManager.default.fileExists(atPath: themeURL.path),
            "Missing shared ReaderTheme.swift"
        )
        guard FileManager.default.fileExists(atPath: themeURL.path) else {
            return
        }

        let source = try String(contentsOf: themeURL, encoding: .utf8)
        let expectedSnippets = [
            "enum ReaderThemeMode",
            "static let storageKey",
            "var preferredColorScheme",
            "var toggleSystemName",
            "enum ReaderTheme",
            "static let background",
            "static let primaryText",
            "static let secondaryText",
            "static let accent",
            "static let controlFill",
            "static let primaryControlFill"
        ]

        for snippet in expectedSnippets {
            XCTAssertTrue(source.contains(snippet), "Missing theme snippet: \(snippet)")
        }
    }

    func testReaderSurfacesUseWarmLightThemeInsteadOfForcedDarkSurfaces() throws {
        for path in themedViewPaths {
            let source = try sourceFile(path)

            XCTAssertFalse(
                source.contains("Color.black.ignoresSafeArea()"),
                "\(path) should use ReaderTheme.background"
            )
            XCTAssertFalse(
                source.contains(".preferredColorScheme(.dark)"),
                "\(path) should not force the dark color scheme"
            )
            XCTAssertFalse(
                source.contains(".preferredColorScheme(.light)"),
                "\(path) should inherit the selected theme mode"
            )
        }
    }

    func testMainReaderWiresLightThemeToDisplayAndControls() throws {
        let readerView = try sourceFile("Reader/App/ReaderView.swift")
        let displayView = try sourceFile("Reader/App/RSVPDisplayView.swift")
        let controlsView = try sourceFile("Reader/App/ReaderControlsView.swift")

        XCTAssertTrue(readerView.contains("ReaderTheme.background.ignoresSafeArea()"))
        XCTAssertTrue(readerView.contains(".preferredColorScheme(themeMode.preferredColorScheme)"))
        XCTAssertTrue(displayView.contains("ReaderTheme.primaryText"))
        XCTAssertTrue(controlsView.contains("ReaderTheme.primaryControlFill"))
    }

    func testReaderExposesPersistentThemeToggleInHeader() throws {
        let readerView = try sourceFile("Reader/App/ReaderView.swift")
        let headerView = try sourceFile("Reader/App/ReaderHeaderView.swift")

        XCTAssertTrue(readerView.contains("@AppStorage(ReaderThemeMode.storageKey)"))
        XCTAssertTrue(readerView.contains("onToggleTheme: toggleTheme"))
        XCTAssertTrue(readerView.contains("themeModeRawValue = themeMode.next.rawValue"))
        XCTAssertTrue(headerView.contains("themeMode.toggleSystemName"))
        XCTAssertTrue(headerView.contains("themeMode.toggleAccessibilityLabel"))
        XCTAssertTrue(headerView.contains("reader.toggle-theme"))
    }

    private var themedViewPaths: [String] {
        [
            "Reader/App/ReaderView.swift",
            "Reader/App/RSVPDisplayView.swift",
            "Reader/App/ReaderControlsView.swift",
            "Reader/App/ReaderHeaderView.swift",
            "Reader/App/LibraryView.swift",
            "Reader/App/BookmarksView.swift",
            "Reader/App/SettingsView.swift",
            "Reader/App/JumpToPositionView.swift",
            "Reader/App/ResumeSessionView.swift"
        ]
    }

    private func sourceFile(_ path: String) throws -> String {
        let sourceURL = repoRoot().appendingPathComponent(path)
        return try String(contentsOf: sourceURL, encoding: .utf8)
    }

    private func repoRoot() -> URL {
        let testFile = URL(fileURLWithPath: #filePath)
        return testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
