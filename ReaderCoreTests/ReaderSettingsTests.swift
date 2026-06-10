import XCTest
@testable import ReaderCore

final class ReaderSettingsTests: XCTestCase {
    func testSourceCompatibleControlRanges() {
        XCTAssertEqual(ReaderSettings.wordsPerMinuteRange.lowerBound, 50)
        XCTAssertEqual(ReaderSettings.wordsPerMinuteRange.upperBound, 1_000)
        XCTAssertEqual(ReaderSettings.wordsPerMinuteStep, 25)

        XCTAssertEqual(ReaderSettings.fadeDurationRange.lowerBound, 50)
        XCTAssertEqual(ReaderSettings.fadeDurationRange.upperBound, 300)
        XCTAssertEqual(ReaderSettings.fadeDurationStep, 25)

        XCTAssertEqual(ReaderSettings.pauseAfterWordsRange.lowerBound, 0)
        XCTAssertEqual(ReaderSettings.pauseAfterWordsRange.upperBound, 50)
        XCTAssertEqual(ReaderSettings.pauseAfterWordsStep, 5)

        XCTAssertEqual(ReaderSettings.pauseDurationRange.lowerBound, 100)
        XCTAssertEqual(ReaderSettings.pauseDurationRange.upperBound, 2_000)
        XCTAssertEqual(ReaderSettings.pauseDurationStep, 100)

        XCTAssertEqual(ReaderSettings.punctuationPauseMultiplierRange.lowerBound, 1)
        XCTAssertEqual(ReaderSettings.punctuationPauseMultiplierRange.upperBound, 4)
        XCTAssertEqual(ReaderSettings.punctuationPauseMultiplierStep, 0.5)

        XCTAssertEqual(ReaderSettings.wordLengthWPMMultiplierRange.lowerBound, 0)
        XCTAssertEqual(ReaderSettings.wordLengthWPMMultiplierRange.upperBound, 50)
        XCTAssertEqual(ReaderSettings.wordLengthWPMMultiplierStep, 1)

        XCTAssertEqual(ReaderSettings.frameWordCounts, [1, 3, 5, 7])
    }

    func testNormalizeForControlsClampsValuesAndKeepsOddFrameCount() {
        var settings = ReaderSettings()
        settings.wordsPerMinute = 1_200
        settings.fadeDurationMilliseconds = 12
        settings.pauseAfterWords = 52
        settings.pauseDurationMilliseconds = 2_500
        settings.punctuationPauseMultiplier = 0.2
        settings.wordLengthWPMMultiplier = 80
        settings.frameWordCount = 4

        settings.normalizeForControls()

        XCTAssertEqual(settings.wordsPerMinute, 1_000)
        XCTAssertEqual(settings.fadeDurationMilliseconds, 50)
        XCTAssertEqual(settings.pauseAfterWords, 50)
        XCTAssertEqual(settings.pauseDurationMilliseconds, 2_000)
        XCTAssertEqual(settings.punctuationPauseMultiplier, 1)
        XCTAssertEqual(settings.wordLengthWPMMultiplier, 50)
        XCTAssertEqual(settings.frameWordCount, 3)
    }
}
