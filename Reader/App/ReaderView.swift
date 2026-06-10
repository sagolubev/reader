import SwiftUI

struct ReaderView: View {
    @State private var session: ReadingSession
    @State private var playbackLoopID = 0

    init(initialText: String = ReaderView.defaultText) {
        var session = ReadingSession()
        session.loadText(initialText)
        _session = State(initialValue: session)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 28) {
                header

                Spacer(minLength: 24)

                RSVPDisplayView(word: session.currentWord)
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
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Reader")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("\(session.words.count) words")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("reader.word-count")
            }

            Spacer()
        }
    }

    @MainActor
    private func playPause() {
        switch session.playbackState {
        case .playing:
            session.pause()
        case .paused:
            session.resume()
        case .stopped:
            session.play()
        }

        playbackLoopID += 1
    }

    @MainActor
    private func restart() {
        session.restart()
        playbackLoopID += 1
    }

    @MainActor
    private func stop() {
        session.stop()
        playbackLoopID += 1
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
}

private extension ReaderView {
    static let defaultText = """
    Rapid serial visual presentation keeps one word in focus at a time. Load text, set the speed, and read without moving your eyes across the page.
    """
}

#Preview {
    ReaderView()
}
