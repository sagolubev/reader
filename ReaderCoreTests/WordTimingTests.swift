import XCTest
@testable import ReaderCore

final class WordTimingTests: XCTestCase {
    func testReaderSettingsDefaultsMatchSourceReader() {
        let settings = ReaderSettings()

        XCTAssertEqual(settings.wordsPerMinute, 300)
        XCTAssertEqual(settings.fadeEnabled, true)
        XCTAssertEqual(settings.fadeDurationMilliseconds, 150)
        XCTAssertEqual(settings.pauseAfterWords, 0)
        XCTAssertEqual(settings.pauseDurationMilliseconds, 500)
        XCTAssertEqual(settings.pauseOnPunctuation, true)
        XCTAssertEqual(settings.punctuationPauseMultiplier, 2)
        XCTAssertEqual(settings.wordLengthWPMMultiplier, 5)
        XCTAssertEqual(settings.frameWordCount, 1)
    }

    func testBaseDelayUsesWordsPerMinute() {
        var settings = ReaderSettings()
        settings.wordsPerMinute = 300
        XCTAssertEqual(WordTiming.delayMilliseconds(for: "hello", settings: settings), 200, accuracy: 0.001)

        settings.wordsPerMinute = 600
        XCTAssertEqual(WordTiming.delayMilliseconds(for: "hello", settings: settings), 100, accuracy: 0.001)
    }

    func testSentencePunctuationUsesMultiplier() {
        var settings = ReaderSettings()
        settings.wordsPerMinute = 300
        settings.pauseOnPunctuation = true
        settings.punctuationPauseMultiplier = 2

        XCTAssertEqual(WordTiming.delayMilliseconds(for: "word.", settings: settings), 400, accuracy: 0.001)
        XCTAssertEqual(WordTiming.delayMilliseconds(for: "word!", settings: settings), 400, accuracy: 0.001)
        XCTAssertEqual(WordTiming.delayMilliseconds(for: "word?", settings: settings), 400, accuracy: 0.001)
        XCTAssertEqual(WordTiming.delayMilliseconds(for: "word;", settings: settings), 400, accuracy: 0.001)
        XCTAssertEqual(WordTiming.delayMilliseconds(for: "word:", settings: settings), 400, accuracy: 0.001)
    }

    func testCommaUsesShorterPunctuationPause() {
        var settings = ReaderSettings()
        settings.wordsPerMinute = 300

        XCTAssertEqual(WordTiming.delayMilliseconds(for: "word,", settings: settings), 300, accuracy: 0.001)
    }

    func testPunctuationCanBeDisabled() {
        var settings = ReaderSettings()
        settings.wordsPerMinute = 300
        settings.pauseOnPunctuation = false

        XCTAssertEqual(WordTiming.delayMilliseconds(for: "word.", settings: settings), 200, accuracy: 0.001)
        XCTAssertEqual(WordTiming.delayMilliseconds(for: "word,", settings: settings), 200, accuracy: 0.001)
    }

    func testLongWordMultiplierIncreasesDelay() {
        var settings = ReaderSettings()
        settings.wordsPerMinute = 300
        settings.pauseOnPunctuation = false
        settings.wordLengthWPMMultiplier = 10

        XCTAssertEqual(WordTiming.delayMilliseconds(for: "extraordinary", settings: settings), 220, accuracy: 0.001)
        XCTAssertEqual(WordTiming.delayMilliseconds(for: "acknowledgement", settings: settings), 260, accuracy: 0.001)
    }

    func testRemainingTimeFormatsAsMinutesAndSeconds() {
        XCTAssertEqual(WordTiming.formatTimeRemaining(remainingWords: 300, wordsPerMinute: 300), "1:00")
        XCTAssertEqual(WordTiming.formatTimeRemaining(remainingWords: 150, wordsPerMinute: 300), "0:30")
        XCTAssertEqual(WordTiming.formatTimeRemaining(remainingWords: 450, wordsPerMinute: 300), "1:30")
        XCTAssertEqual(WordTiming.formatTimeRemaining(remainingWords: 0, wordsPerMinute: 300), "0:00")
        XCTAssertEqual(WordTiming.formatTimeRemaining(remainingWords: 300, wordsPerMinute: 0), "0:00")
    }

    func testPeriodicPauseChecksWordBoundaries() {
        XCTAssertFalse(WordTiming.shouldPause(atWordIndex: 0, pauseAfterWords: 10))
        XCTAssertFalse(WordTiming.shouldPause(atWordIndex: 9, pauseAfterWords: 10))
        XCTAssertTrue(WordTiming.shouldPause(atWordIndex: 10, pauseAfterWords: 10))
        XCTAssertTrue(WordTiming.shouldPause(atWordIndex: 20, pauseAfterWords: 10))
        XCTAssertFalse(WordTiming.shouldPause(atWordIndex: 20, pauseAfterWords: 0))
    }
}
