import SwiftUI

struct ReaderView: View {
    @State private var session: ReadingSession
    @State private var playbackLoopID = 0
    @State private var isFocusMode = false
    @State private var presentedSheet: ReaderSheet?

    init(initialText: String = ReaderView.defaultText) {
        var session = ReadingSession()
        session.loadText(initialText)
        _session = State(initialValue: session)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 28) {
                ReaderHeaderView(
                    wordCount: session.words.count,
                    isFocusMode: isFocusMode,
                    onLoadContent: showLoadContent,
                    onOpenSettings: showSettings,
                    onExitFocusMode: exitFocusMode
                )

                Spacer(minLength: 24)

                RSVPDisplayView(
                    frame: session.currentFrame,
                    fadeEnabled: session.settings.fadeEnabled,
                    fadeDurationMilliseconds: session.settings.fadeDurationMilliseconds
                )
                    .accessibilityIdentifier("reader.current-word")

                VStack(spacing: 18) {
                    ReaderProgressView(
                        progress: session.progressPercentage / 100,
                        isSeekingEnabled: session.playbackState != .playing
                    ) { fraction in
                        session.seek(toPercentage: fraction * 100)
                    }

                    HStack {
                        Text("\(session.currentWordIndex + 1) / \(session.words.count)")
                        Spacer()
                        Text(session.timeRemaining)
                    }
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("reader.progress-summary")

                    PlaybackControlsView(
                        playbackState: session.playbackState,
                        canStep: !session.words.isEmpty,
                        onRestart: restart,
                        onStepBackward: stepBackward,
                        onPlayPause: playPause,
                        onStop: stop,
                        onStepForward: stepForward
                    )
                }

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 28)
        }
        .task(id: playbackLoopID) {
            await runPlaybackLoop()
        }
        .sheet(item: $presentedSheet) { sheet in
            switch sheet {
            case .loadContent:
                LoadContentView { text in
                    loadText(text)
                }
            case .settings:
                SettingsView(settings: settingsBinding)
            }
        }
    }

    @MainActor
    private func showLoadContent() {
        presentedSheet = .loadContent
    }

    @MainActor
    private func showSettings() {
        presentedSheet = .settings
    }

    @MainActor
    private func loadText(_ text: String) {
        session.loadText(text)
        isFocusMode = false
        playbackLoopID += 1
    }

    @MainActor
    private func playPause() {
        switch session.playbackState {
        case .playing:
            session.pause()
        case .paused:
            session.resume()
            isFocusMode = true
        case .stopped:
            session.play()
            isFocusMode = true
        }

        playbackLoopID += 1
    }

    @MainActor
    private func restart() {
        session.restart()
        isFocusMode = true
        playbackLoopID += 1
    }

    @MainActor
    private func stop() {
        session.stop()
        isFocusMode = false
        playbackLoopID += 1
    }

    @MainActor
    private func exitFocusMode() {
        if session.playbackState == .playing {
            session.pause()
            playbackLoopID += 1
        }

        isFocusMode = false
    }

    @MainActor
    private func stepBackward() {
        session.stepBackward()
    }

    @MainActor
    private func stepForward() {
        session.stepForward()
    }

    @MainActor
    private func runPlaybackLoop() async {
        guard session.playbackState == .playing else {
            return
        }

        while session.playbackState == .playing, !Task.isCancelled {
            let delay = playbackDelayMilliseconds()

            do {
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000))
            } catch {
                return
            }

            guard !Task.isCancelled else {
                return
            }

            session.advanceOneWord()
        }
    }

    private func playbackDelayMilliseconds() -> Double {
        var delay = WordTiming.delayMilliseconds(
            for: session.currentWord,
            settings: session.settings
        )

        if WordTiming.shouldPause(
            atWordIndex: session.currentWordIndex,
            pauseAfterWords: session.settings.pauseAfterWords
        ) {
            delay += Double(session.settings.pauseDurationMilliseconds)
        }

        return max(1, delay)
    }

    private var settingsBinding: Binding<ReaderSettings> {
        Binding(
            get: { session.settings },
            set: { newSettings in
                var normalizedSettings = newSettings
                normalizedSettings.normalizeForControls()
                session.settings = normalizedSettings
            }
        )
    }
}

private enum ReaderSheet: Identifiable {
    case loadContent
    case settings

    var id: String {
        switch self {
        case .loadContent:
            return "load-content"
        case .settings:
            return "settings"
        }
    }
}

private extension ReaderView {
    static let defaultText = """
    Rapid serial visual presentation keeps one word in focus at a time. Load text, set the speed, and read without moving your eyes across the page.
    """
}

#Preview("Default") {
    ReaderView()
}

#Preview("Small Phone", traits: .fixedLayout(width: 375, height: 667)) {
    ReaderView(initialText: "Short words keep the focal point stable on compact screens.")
}

#Preview("Large Phone", traits: .fixedLayout(width: 430, height: 932)) {
    ReaderView(initialText: """
    Longer sample text keeps the reader surface populated while checking spacing, centered ORP alignment, progress, and controls on a large phone.
    """)
}
