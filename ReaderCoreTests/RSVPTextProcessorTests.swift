import XCTest
@testable import ReaderCore

final class RSVPTextProcessorTests: XCTestCase {
    func testParseTextSplitsOnRepeatedWhitespace() {
        XCTAssertEqual(
            RSVPTextProcessor.parseText("  Hello   world\nagain\t "),
            ["Hello", "world", "again"]
        )
    }

    func testParseTextReturnsEmptyArrayForBlankInput() {
        XCTAssertEqual(RSVPTextProcessor.parseText(""), [])
        XCTAssertEqual(RSVPTextProcessor.parseText("   \n\t  "), [])
    }
}
