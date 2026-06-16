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
    func testPlaybackJumpAndLibrarySmokeFlow() {
        launch(resetSavedSession: true)
        XCTAssertTrue(element("reader.current-word").waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["reader.add-book"].waitForExistence(timeout: 5))

        openLibraryAndAssertAddBookAction()
        playAndPause()
        jump(to: "50%")
        XCTAssertTrue(element("reader.progress-summary").waitForExistence(timeout: 5))
    }

    @MainActor
    private func launch(resetSavedSession: Bool) {
        app.launchArguments = resetSavedSession ? [Self.resetSavedSessionArgument] : []
        app.launch()

        if resetSavedSession {
            startFreshIfPromptAppears()
        }
    }

    @MainActor
    private func openLibraryAndAssertAddBookAction() {
        let libraryButton = app.buttons["reader.open-library"]
        XCTAssertTrue(libraryButton.waitForExistence(timeout: 5))
        libraryButton.tap()

        XCTAssertTrue(element("library.sheet").waitForExistence(timeout: 5))
        XCTAssertTrue(element("library.empty").waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["library.add-book"].waitForExistence(timeout: 5))

        let closeButton = app.buttons["Close"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 5))
        closeButton.tap()
        XCTAssertTrue(element("library.sheet").waitForNonExistence(timeout: 5))
    }

    @MainActor
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

    @MainActor
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

        XCTAssertTrue(targetField.waitForNonExistence(timeout: 5))
        XCTAssertTrue(element("reader.progress-summary").waitForExistence(timeout: 5))
    }

    @MainActor
    private func startFreshIfPromptAppears() {
        let startFreshButton = app.buttons["resume-session.start-fresh"]
        if startFreshButton.waitForExistence(timeout: 1) {
            startFreshButton.tap()
        }
    }

    @MainActor
    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }
}
