import XCTest

final class ReaderUITests: XCTestCase {
    private static let resetSavedSessionArgument = "--reader-ui-test-reset-session"

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
    }

    @MainActor
    func testAppLaunchesToReaderSurface() {
        launch(resetSavedSession: true)

        XCTAssertTrue(element("reader.current-word").waitForExistence(timeout: 5))
    }

    @MainActor
    func testLoadPlaybackJumpSaveAndResumeSmokeFlow() {
        launch(resetSavedSession: true)
        XCTAssertTrue(element("reader.current-word").waitForExistence(timeout: 5))

        loadText("zero one two three four five six seven eight nine")
        XCTAssertEqual(app.staticTexts["reader.word-count"].label, "10 words")

        playAndPause()
        jump(to: "50%")
        assertProgressSummaryContains(["6", "10"])

        let saveButton = app.buttons["reader.save-session"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()

        app.terminate()
        app = XCUIApplication()
        launch(resetSavedSession: false)

        let resumeButton = app.buttons["resume-session.resume"]
        XCTAssertTrue(resumeButton.waitForExistence(timeout: 5))
        resumeButton.tap()

        XCTAssertTrue(element("reader.current-word").waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["reader.word-count"].label, "10 words")
        assertProgressSummaryContains(["6", "10"])
    }

    private func launch(resetSavedSession: Bool) {
        app.launchArguments = resetSavedSession ? [Self.resetSavedSessionArgument] : []
        app.launch()

        if resetSavedSession {
            startFreshIfPromptAppears()
        }
    }

    private func loadText(_ text: String) {
        let loadContentButton = app.buttons["reader.load-content"]
        XCTAssertTrue(loadContentButton.waitForExistence(timeout: 5))
        loadContentButton.tap()

        let editor = app.textViews["load-content.text-editor"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.tap()
        editor.typeText(text)

        let loadTextButton = app.buttons["load-content.load-text"]
        XCTAssertTrue(loadTextButton.waitForExistence(timeout: 5))
        loadTextButton.tap()

        XCTAssertTrue(app.staticTexts["reader.word-count"].waitForExistence(timeout: 5))
    }

    private func playAndPause() {
        let playButton = app.buttons["Play"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 5))
        playButton.tap()

        let pauseButton = app.buttons["Pause"]
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 5))
        pauseButton.tap()

        let exitFocusButton = app.buttons["reader.exit-focus"]
        XCTAssertTrue(exitFocusButton.waitForExistence(timeout: 5))
        exitFocusButton.tap()
    }

    private func jump(to target: String) {
        let jumpButton = app.buttons["reader.jump"]
        XCTAssertTrue(jumpButton.waitForExistence(timeout: 5))
        jumpButton.tap()

        let targetField = app.textFields["jump.target"]
        XCTAssertTrue(targetField.waitForExistence(timeout: 5))
        targetField.tap()
        targetField.typeText(target)

        let submitButton = app.buttons["jump.submit"]
        XCTAssertTrue(submitButton.waitForExistence(timeout: 5))
        submitButton.tap()

        let closeButton = app.buttons["Close"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 5))
        closeButton.tap()
    }

    private func startFreshIfPromptAppears() {
        let startFreshButton = app.buttons["resume-session.start-fresh"]
        if startFreshButton.waitForExistence(timeout: 1) {
            startFreshButton.tap()
        }
    }

    private func assertProgressSummaryContains(
        _ expectedFragments: [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let summary = element("reader.progress-summary")
        XCTAssertTrue(summary.waitForExistence(timeout: 5), file: file, line: line)
        let summaryText = accessibilityText(for: summary)

        for fragment in expectedFragments {
            XCTAssertTrue(
                summaryText.contains(fragment),
                "Expected progress summary to contain \(fragment), got: \(summaryText)",
                file: file,
                line: line
            )
        }
    }

    private func accessibilityText(for element: XCUIElement) -> String {
        [element.label, element.value as? String]
            .compactMap { $0 }
            .joined(separator: " ")
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }
}
