import XCTest
@testable import Reader

final class ReaderTests: XCTestCase {
    func testRootViewCanBeCreated() {
        _ = RootView()
    }

    @MainActor
    func testReaderViewCanBeCreated() {
        _ = ReaderView()
    }

    @MainActor
    func testRSVPDisplayViewCanBeCreated() {
        _ = RSVPDisplayView(word: "reading")
    }
}
