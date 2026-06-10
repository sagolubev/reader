import XCTest
@testable import ReaderCore

final class ReadingSessionTests: XCTestCase {
    func testLoadTextParsesWordsAndResetsPosition() {
        var session = ReadingSession()
        session.loadText("one two three")
        session.stepForward()

        session.loadText("alpha beta")

        XCTAssertEqual(session.text, "alpha beta")
        XCTAssertEqual(session.words, ["alpha", "beta"])
        XCTAssertEqual(session.currentWordIndex, 0)
        XCTAssertEqual(session.currentWord, "alpha")
        XCTAssertEqual(session.progressPercentage, 0)
        XCTAssertEqual(session.playbackState, .stopped)
    }

    func testPlayPauseResumeStopAndRestartTransitions() {
        var session = ReadingSession()
        session.loadText("one two three")

        session.play()
        XCTAssertEqual(session.playbackState, .playing)

        session.pause()
        XCTAssertEqual(session.playbackState, .paused)

        session.resume()
        XCTAssertEqual(session.playbackState, .playing)

        session.stepForward()
        session.stop()
        XCTAssertEqual(session.playbackState, .stopped)
        XCTAssertEqual(session.currentWordIndex, 0)

        session.stepForward()
        session.restart()
        XCTAssertEqual(session.playbackState, .playing)
        XCTAssertEqual(session.currentWordIndex, 0)
    }

    func testStepForwardAndBackwardClampToWordRange() {
        var session = ReadingSession()
        session.loadText("one two three")

        session.stepForward()
        session.stepForward()
        session.stepForward()
        XCTAssertEqual(session.currentWordIndex, 2)
        XCTAssertEqual(session.currentWord, "three")

        session.stepBackward()
        session.stepBackward()
        session.stepBackward()
        XCTAssertEqual(session.currentWordIndex, 0)
        XCTAssertEqual(session.currentWord, "one")
    }

    func testSeekByPercentageUpdatesProgress() {
        var session = ReadingSession()
        session.loadText("zero one two three")

        session.seek(toPercentage: 50)

        XCTAssertEqual(session.currentWordIndex, 2)
        XCTAssertEqual(session.progressPercentage, 50)
    }

    func testJumpAcceptsWordNumberAndPercentage() {
        var session = ReadingSession()
        session.loadText("zero one two three")

        session.jump(to: "3")
        XCTAssertEqual(session.currentWordIndex, 3)

        session.jump(to: "50%")
        XCTAssertEqual(session.currentWordIndex, 2)

        session.jump(to: "999")
        XCTAssertEqual(session.currentWordIndex, 3)

        session.jump(to: "-10")
        XCTAssertEqual(session.currentWordIndex, 0)
    }

    func testDerivedFrameAndTimeRemainingUseSettings() {
        var session = ReadingSession()
        session.loadText("zero one two three")
        session.settings.frameWordCount = 3
        session.settings.wordsPerMinute = 120
        session.seek(toPercentage: 50)

        XCTAssertEqual(session.currentFrame.words, ["one", "two", "three"])
        XCTAssertEqual(session.currentFrame.centerOffset, 1)
        XCTAssertEqual(session.timeRemaining, "0:01")
    }
}
