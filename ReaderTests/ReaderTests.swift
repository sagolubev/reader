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
}
