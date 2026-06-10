import SwiftUI

struct ReaderView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotionEnabled
    @Environment(\.scenePhase) private var scenePhase

    private let persistence: ReaderPersistenceActions?
    private let resetSavedSessionOnLaunch: Bool

    @State private var session: ReadingSession
    @State private var playbackLoopID = 0
    @State private var isFocusMode = false
    @State private var presentedSheet: ReaderSheet?
    @State private var didCheckSavedSession = false
    @State private var persistenceErrorMessage: String?

    init(
        initialText: String = ReaderView.defaultText,
        sessionStore: (any SessionPersisting)? = nil,
        resetSavedSessionOnLaunch: Bool = false
    ) {
        self.resetSavedSessionOnLaunch = resetSavedSessionOnLaunch

        var session = ReadingSession()
        session.loadText(initialText)
        _session = State(initialValue: session)

        if let sessionStore {
            persistence = ReaderPersistenceActions(store: sessionStore)
        } else {
            persistence = nil
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 28) {
                ReaderHeaderView(
                    wordCount: session.words.count,
                    isFocusMode: isFocusMode,
                    canJump: canJump,
                    canSave: !session.words.isEmpty,
                    onLoadContent: showLoadContent,
                    onJump: showJump,
                    onSave: saveSession,
                    onOpenSettings: showSettings,
                    onExitFocusMode: exitFocusMode
                )

                Spacer(minLength: 24)

                RSVPDisplayView(
                    frame: session.currentFrame,
                    fadeEnabled: ReaderMotionPolicy.isFadeEnabled(
                        settings: session.settings,
                        reduceMotionEnabled: reduceMotionEnabled
                    ),
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
                    .foregroundStyle(.white.opacity(0.72))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Reading position")
                    .accessibilityValue("\(session.currentWordIndex + 1) of \(session.words.count) words, \(session.timeRemaining) remaining")
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

                    ReaderTouchControlsView(
                        canStep: !session.words.isEmpty,
                        wordsPerMinute: session.settings.wordsPerMinute,
                        onStepBackward: stepBackwardByTouch,
                        onSlower: slowDown,
                        onFaster: speedUp,
                        onStepForward: stepForwardByTouch
                    )
                }

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 28)

            ReaderKeyboardShortcutsView(
                onPlayPause: playPause,
                onExit: exitFocusMode,
                onSpeedUp: speedUpByKeyboard,
                onSlowDown: slowDownByKeyboard,
                onStepBackward: stepBackwardByKeyboard,
                onStepForward: stepForward,
                onJump: showJumpShortcut,
                onSave: saveShortcut
            )
        }
        .task(id: playbackLoopID) {
            await runPlaybackLoop()
        }
        .onChange(of: scenePhase) { _, newScenePhase in
            handleScenePhaseChange(newScenePhase)
        }
        .sheet(item: $presentedSheet) { sheet in
            switch sheet {
            case .loadContent:
                LoadContentView { text in
                    loadText(text)
                }
            case .settings:
                SettingsView(settings: settingsBinding)
            case .jump:
                JumpToPositionView(
                    currentWordIndex: session.currentWordIndex,
                    totalWordCount: session.words.count,
                    onJump: jumpToPosition
                )
            case .resumeSession(let snapshot):
                ResumeSessionView(
                    snapshot: snapshot,
                    onResume: { resumeSavedSession(snapshot) },
                    onStartFresh: startFresh
                )
            }
        }
        .task {
            showSavedSessionPromptIfNeeded()
        }
        .alert("Session Error", isPresented: persistenceErrorIsPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(persistenceErrorMessage ?? "")
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
    private func showJump() {
        guard canJump else {
            return
        }

        presentedSheet = .jump
    }

    @MainActor
    private func showSavedSessionPromptIfNeeded() {
        guard !didCheckSavedSession, let persistence else {
            return
        }

        didCheckSavedSession = true

        do {
            if resetSavedSessionOnLaunch {
                try persistence.startFresh()
                return
            }

            if let snapshot = try persistence.loadSavedSession() {
                presentedSheet = .resumeSession(snapshot)
            }
        } catch {
            persistenceErrorMessage = error.localizedDescription
        }
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
    private func handleScenePhaseChange(_ newScenePhase: ScenePhase) {
        let lifecyclePhase = ReaderLifecyclePhase(scenePhase: newScenePhase)
        guard session.pauseForLifecycleTransition(to: lifecyclePhase) else {
            return
        }

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
    private func stepBackwardByTouch() {
        session.stepBackward(by: Self.touchWordStep)
    }

    @MainActor
    private func stepForwardByTouch() {
        session.stepForward(by: Self.touchWordStep)
    }

    @MainActor
    private func slowDown() {
        session.adjustWordsPerMinute(by: -Self.touchWordsPerMinuteStep)
    }

    @MainActor
    private func speedUp() {
        session.adjustWordsPerMinute(by: Self.touchWordsPerMinuteStep)
    }

    @MainActor
    private func stepBackwardByKeyboard() {
        session.stepBackward(by: Self.keyboardBackwardWordStep)
    }

    @MainActor
    private func slowDownByKeyboard() {
        session.adjustWordsPerMinute(by: -ReaderSettings.wordsPerMinuteStep)
    }

    @MainActor
    private func speedUpByKeyboard() {
        session.adjustWordsPerMinute(by: ReaderSettings.wordsPerMinuteStep)
    }

    @MainActor
    private func showJumpShortcut() {
        showJump()
    }

    @MainActor
    private func saveShortcut() {
        saveSession()
    }

    @MainActor
    private func saveSession() {
        guard let persistence else {
            return
        }

        do {
            try persistence.save(session)
        } catch {
            persistenceErrorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func resumeSavedSession(_ snapshot: SavedSessionSnapshot) {
        persistence?.resume(snapshot, into: &session)
        isFocusMode = false
        playbackLoopID += 1
    }

    @MainActor
    private func startFresh() {
        guard let persistence else {
            return
        }

        do {
            try persistence.startFresh()
        } catch {
            persistenceErrorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func jumpToPosition(_ target: String) {
        session.jump(to: target)
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

    private var canJump: Bool {
        !session.words.isEmpty && session.playbackState != .playing
    }

    private var persistenceErrorIsPresented: Binding<Bool> {
        Binding(
            get: { persistenceErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    persistenceErrorMessage = nil
                }
            }
        )
    }
}

private enum ReaderSheet: Identifiable {
    case loadContent
    case settings
    case jump
    case resumeSession(SavedSessionSnapshot)

    var id: String {
        switch self {
        case .loadContent:
            return "load-content"
        case .settings:
            return "settings"
        case .jump:
            return "jump"
        case .resumeSession(let snapshot):
            return "resume-session-\(snapshot.savedAt.timeIntervalSince1970)"
        }
    }
}

private extension ReaderView {
    static let touchWordStep = 5
    static let touchWordsPerMinuteStep = 50
    static let keyboardBackwardWordStep = 2

    static let defaultText = """
    Rapid serial visual presentation keeps one word in focus at a time. Load text, set the speed, and read without moving your eyes across the page.
    """
}

private extension ReaderLifecyclePhase {
    init(scenePhase: ScenePhase) {
        switch scenePhase {
        case .active:
            self = .active
        case .inactive:
            self = .inactive
        case .background:
            self = .background
        @unknown default:
            self = .inactive
        }
    }
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
