import XCTest
@testable import ReaderCore

final class ReaderLifecyclePolicyTests: XCTestCase {
    func testReduceMotionDisablesFadeEffectButPreservesUserSetting() {
        var settings = ReaderSettings()
        settings.fadeEnabled = true

        XCTAssertFalse(
            ReaderMotionPolicy.isFadeEnabled(
                settings: settings,
                reduceMotionEnabled: true
            )
        )
        XCTAssertTrue(settings.fadeEnabled)
    }

    func testFadeRequiresUserSettingWhenReduceMotionIsOff() {
        var settings = ReaderSettings()
        settings.fadeEnabled = true

        XCTAssertTrue(
            ReaderMotionPolicy.isFadeEnabled(
                settings: settings,
                reduceMotionEnabled: false
            )
        )

        settings.fadeEnabled = false

        XCTAssertFalse(
            ReaderMotionPolicy.isFadeEnabled(
                settings: settings,
                reduceMotionEnabled: false
            )
        )
    }

    func testBackgroundLifecyclePausesPlaybackWithoutChangingPosition() {
        var session = ReadingSession()
        session.loadText("zero one two three")
        session.jump(to: "2")
        session.play()

        let didPause = session.pauseForLifecycleTransition(to: .background)

        XCTAssertTrue(didPause)
        XCTAssertEqual(session.playbackState, .paused)
        XCTAssertEqual(session.currentWordIndex, 2)
    }

    func testInactiveLifecyclePausesPlaybackWithoutChangingPosition() {
        var session = ReadingSession()
        session.loadText("zero one two three")
        session.jump(to: "1")
        session.play()

        let didPause = session.pauseForLifecycleTransition(to: .inactive)

        XCTAssertTrue(didPause)
        XCTAssertEqual(session.playbackState, .paused)
        XCTAssertEqual(session.currentWordIndex, 1)
    }

    func testActiveLifecycleDoesNotPausePlayback() {
        var session = ReadingSession()
        session.loadText("zero one two three")
        session.play()

        let didPause = session.pauseForLifecycleTransition(to: .active)

        XCTAssertFalse(didPause)
        XCTAssertEqual(session.playbackState, .playing)
        XCTAssertEqual(session.currentWordIndex, 0)
    }

    func testReaderViewWiresReduceMotionAndScenePhaseLifecycle() throws {
        let source = try readerViewSource()
        let expectedSnippets = [
            "@Environment(\\.accessibilityReduceMotion)",
            "@Environment(\\.scenePhase)",
            "ReaderMotionPolicy.isFadeEnabled",
            ".onChange(of: scenePhase)",
            "handleScenePhaseChange",
            "pauseForLifecycleTransition"
        ]

        for expectedSnippet in expectedSnippets {
            XCTAssertTrue(
                source.contains(expectedSnippet),
                "Missing lifecycle wiring snippet: \(expectedSnippet)"
            )
        }
    }

    private func readerViewSource() throws -> String {
        let testFile = URL(fileURLWithPath: #filePath)
        let repoRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repoRoot.appendingPathComponent("Reader/App/ReaderView.swift")
        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
