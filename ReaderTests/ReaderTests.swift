import XCTest
@testable import Reader

final class ReaderTests: XCTestCase {
    func testRootViewCanBeCreated() {
        _ = RootView()
    }

    func testReaderViewCanBeCreated() {
        _ = ReaderView()
    }
}
