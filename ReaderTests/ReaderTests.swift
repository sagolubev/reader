import XCTest
import SwiftUI
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

    @MainActor
    func testRSVPDisplayViewCanBeCreatedWithFrameAndFadeSettings() {
        let frame = WordFrame(words: ["fast", "reading", "now"], centerOffset: 1)

        _ = RSVPDisplayView(
            frame: frame,
            fadeEnabled: false,
            fadeDurationMilliseconds: 0
        )
    }

    @MainActor
    func testReaderProgressViewCanBeCreated() {
        _ = ReaderProgressView(progress: 0.25, isSeekingEnabled: true) { _ in }
    }

    @MainActor
    func testPlaybackControlsViewCanBeCreated() {
        _ = PlaybackControlsView(
            playbackState: .stopped,
            canStep: true,
            onRestart: {},
            onStepBackward: {},
            onPlayPause: {},
            onStop: {},
            onStepForward: {}
        )
    }

    @MainActor
    func testReaderTouchControlsViewCanBeCreated() {
        _ = ReaderTouchControlsView(
            canStep: true,
            wordsPerMinute: 300,
            onStepBackward: {},
            onSlower: {},
            onFaster: {},
            onStepForward: {}
        )
    }

    @MainActor
    func testReaderHeaderViewCanBeCreated() {
        _ = ReaderHeaderView(
            wordCount: 12,
            isFocusMode: false,
            onLoadContent: {},
            onOpenSettings: {},
            onExitFocusMode: {}
        )
    }

    @MainActor
    func testLoadContentViewCanBeCreated() {
        _ = LoadContentView { _ in }
    }

    @MainActor
    func testSettingsViewCanBeCreated() {
        let settings = Binding<ReaderSettings>(
            get: { ReaderSettings() },
            set: { _ in }
        )

        _ = SettingsView(settings: settings)
    }
}
