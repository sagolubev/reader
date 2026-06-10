import XCTest

final class ReaderUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAppLaunchesToReaderSurface() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["reader.current-word"].waitForExistence(timeout: 5))
    }
}
