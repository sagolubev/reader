import XCTest

final class ReaderUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunchesToReadyState() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["reader.ready"].waitForExistence(timeout: 5))
    }
}
