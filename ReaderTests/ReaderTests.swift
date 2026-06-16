import XCTest
import SwiftUI
@testable import Reader

final class ReaderTests: XCTestCase {
    @MainActor
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
    func testReaderBookmarkControlsViewCanBeCreated() {
        _ = ReaderBookmarkControlsView(
            canBookmark: true,
            isCurrentPositionBookmarked: false,
            onToggleBookmark: {}
        )
    }

    @MainActor
    func testReaderKeyboardShortcutsViewCanBeCreated() {
        _ = ReaderKeyboardShortcutsView(
            onPlayPause: {},
            onExit: {},
            onSpeedUp: {},
            onSlowDown: {},
            onStepBackward: {},
            onStepForward: {},
            onJump: {},
            onSave: {}
        )
    }

    @MainActor
    func testReaderHeaderViewCanBeCreated() {
        _ = ReaderHeaderView(
            wordCount: 12,
            isFocusMode: false,
            canJump: true,
            canBookmark: true,
            onOpenLibrary: {},
            onAddBook: {},
            onOpenBookmarks: {},
            onJump: {},
            onOpenSettings: {},
            themeMode: .lightWarm,
            onToggleTheme: {},
            onExitFocusMode: {}
        )
    }

    @MainActor
    func testLibraryViewCanBeCreated() {
        _ = LibraryView(
            books: [],
            activeBookID: nil,
            onOpenBook: { _ in },
            onAddBook: { _ in },
            onDeleteBook: { _ in }
        )
    }

    @MainActor
    func testBookmarksViewCanBeCreated() {
        _ = BookmarksView(
            bookmarks: [],
            onSelectBookmark: { _ in }
        )
    }

    @MainActor
    func testJumpToPositionViewCanBeCreated() {
        _ = JumpToPositionView(
            currentWordIndex: 1,
            totalWordCount: 3,
            onJump: { _ in }
        )
    }

    @MainActor
    func testResumeSessionViewCanBeCreated() {
        _ = ResumeSessionView(
            snapshot: SavedSessionSnapshot(
                text: "one two three",
                currentWordIndex: 1,
                totalWordCount: 3,
                settings: ReaderSettings(),
                savedAt: Date(timeIntervalSince1970: 123)
            ),
            onResume: {},
            onStartFresh: {}
        )
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
