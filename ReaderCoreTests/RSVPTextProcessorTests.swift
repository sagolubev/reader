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

    func testSplitForDisplayHighlightsLatinORPLetter() {
        let parts = RSVPTextProcessor.splitForDisplay("hello")

        XCTAssertEqual(parts.before, "h")
        XCTAssertEqual(parts.orp, "e")
        XCTAssertEqual(parts.after, "llo")
    }

    func testSplitForDisplayHighlightsCyrillicORPLetterAfterLeadingPunctuation() {
        let parts = RSVPTextProcessor.splitForDisplay("«привет»")

        XCTAssertEqual(parts.before, "«пр")
        XCTAssertEqual(parts.orp, "и")
        XCTAssertEqual(parts.after, "вет»")
    }

    func testSplitForDisplayHighlightsCJKORPLetter() {
        let parts = RSVPTextProcessor.splitForDisplay("你好世界")

        XCTAssertEqual(parts.before, "你")
        XCTAssertEqual(parts.orp, "好")
        XCTAssertEqual(parts.after, "世界")
    }

    func testSplitForDisplayHighlightsRTLScripts() {
        XCTAssertEqual(RSVPTextProcessor.splitForDisplay("مرحبا").orp, "ر")
        XCTAssertEqual(RSVPTextProcessor.splitForDisplay("שלום").orp, "ל")
    }

    func testSplitForDisplayFallsBackToFirstCharacterForTokenWithoutLetters() {
        let parts = RSVPTextProcessor.splitForDisplay("...")

        XCTAssertEqual(parts.before, "")
        XCTAssertEqual(parts.orp, ".")
        XCTAssertEqual(parts.after, "..")
    }

    func testWordFrameReturnsOnlyCurrentWordForSingleWordMode() {
        let words = ["one", "two", "three"]

        let frame = RSVPTextProcessor.wordFrame(words: words, centerIndex: 1, frameSize: 1)

        XCTAssertEqual(frame.words, ["two"])
        XCTAssertEqual(frame.centerOffset, 0)
    }

    func testWordFrameCentersActiveWordWhenNeighborsExist() {
        let words = ["zero", "one", "two", "three", "four"]

        let frame = RSVPTextProcessor.wordFrame(words: words, centerIndex: 2, frameSize: 5)

        XCTAssertEqual(frame.words, ["zero", "one", "two", "three", "four"])
        XCTAssertEqual(frame.centerOffset, 2)
    }

    func testWordFrameClampsAtTextStart() {
        let words = ["zero", "one", "two", "three", "four"]

        let frame = RSVPTextProcessor.wordFrame(words: words, centerIndex: 0, frameSize: 5)

        XCTAssertEqual(frame.words, ["zero", "one", "two"])
        XCTAssertEqual(frame.centerOffset, 0)
    }

    func testWordFrameReturnsEmptyFrameForOutOfRangeIndex() {
        let words = ["one", "two"]

        let frame = RSVPTextProcessor.wordFrame(words: words, centerIndex: 10, frameSize: 3)

        XCTAssertEqual(frame.words, [])
        XCTAssertEqual(frame.centerOffset, 0)
    }
}
