import SwiftUI

struct ReaderProgressView: View {
    let progress: Double
    let isSeekingEnabled: Bool
    let onSeek: (Double) -> Void

    private let markerColor = ReaderTheme.accent

    var body: some View {
        GeometryReader { proxy in
            let clampedProgress = min(1, max(0, progress))

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(ReaderTheme.progressTrack)

                Capsule()
                    .fill(markerColor)
                    .frame(width: proxy.size.width * clampedProgress)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        seek(value.location.x, width: proxy.size.width)
                    }
            )
            .simultaneousGesture(
                SpatialTapGesture()
                    .onEnded { value in
                        seek(value.location.x, width: proxy.size.width)
                    }
            )
            .opacity(isSeekingEnabled ? 1 : 0.55)
            .accessibilityLabel("Reading progress")
            .accessibilityValue("\(Int(clampedProgress * 100)) percent")
            .accessibilityIdentifier("reader.progress")
        }
        .frame(height: 14)
    }

    private func seek(_ xPosition: CGFloat, width: CGFloat) {
        guard isSeekingEnabled, width > 0 else {
            return
        }

        onSeek(min(1, max(0, xPosition / width)))
    }
}

struct PlaybackControlsView: View {
    let playbackState: PlaybackState
    let canStep: Bool
    let onRestart: () -> Void
    let onStepBackward: () -> Void
    let onPlayPause: () -> Void
    let onStop: () -> Void
    let onStepForward: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ControlIconButton(
                systemName: "backward.end.fill",
                accessibilityLabel: "Restart",
                isEnabled: canStep,
                action: onRestart
            )

            ControlIconButton(
                systemName: "backward.fill",
                accessibilityLabel: "Previous word",
                isEnabled: canStep,
                action: onStepBackward
            )

            ControlIconButton(
                systemName: playPauseSystemName,
                accessibilityLabel: playPauseLabel,
                size: 58,
                isProminent: true,
                isEnabled: canStep,
                action: onPlayPause
            )

            ControlIconButton(
                systemName: "stop.fill",
                accessibilityLabel: "Stop",
                isEnabled: canStep,
                action: onStop
            )

            ControlIconButton(
                systemName: "forward.fill",
                accessibilityLabel: "Next word",
                isEnabled: canStep,
                action: onStepForward
            )
        }
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("reader.playback-controls")
    }

    private var playPauseSystemName: String {
        playbackState == .playing ? "pause.fill" : "play.fill"
    }

    private var playPauseLabel: String {
        switch playbackState {
        case .playing:
            return "Pause"
        case .paused:
            return "Resume"
        case .stopped:
            return "Play"
        }
    }
}

struct ReaderTouchControlsView: View {
    let canStep: Bool
    let wordsPerMinute: Int
    let onStepBackward: () -> Void
    let onSlower: () -> Void
    let onFaster: () -> Void
    let onStepForward: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ControlIconButton(
                systemName: "gobackward.5",
                accessibilityLabel: "Back 5 words",
                accessibilityIdentifier: "reader.touch-back",
                size: 40,
                isEnabled: canStep,
                action: onStepBackward
            )

            ControlIconButton(
                systemName: "minus",
                accessibilityLabel: "Slower",
                accessibilityIdentifier: "reader.touch-slower",
                size: 40,
                isEnabled: wordsPerMinute > ReaderSettings.wordsPerMinuteRange.lowerBound,
                action: onSlower
            )

            Text("\(wordsPerMinute) WPM")
                .font(.caption.monospacedDigit().weight(.semibold))
                .foregroundStyle(ReaderTheme.primaryText)
                .frame(width: 82, height: 40)
                .accessibilityLabel("Reading speed")
                .accessibilityValue("\(wordsPerMinute) words per minute")
                .accessibilityIdentifier("reader.touch-wpm")

            ControlIconButton(
                systemName: "plus",
                accessibilityLabel: "Faster",
                accessibilityIdentifier: "reader.touch-faster",
                size: 40,
                isEnabled: wordsPerMinute < ReaderSettings.wordsPerMinuteRange.upperBound,
                action: onFaster
            )

            ControlIconButton(
                systemName: "goforward.5",
                accessibilityLabel: "Forward 5 words",
                accessibilityIdentifier: "reader.touch-forward",
                size: 40,
                isEnabled: canStep,
                action: onStepForward
            )
        }
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("reader.touch-controls")
    }
}

struct ReaderBookmarkControlsView: View {
    let canBookmark: Bool
    let isCurrentPositionBookmarked: Bool
    let onToggleBookmark: () -> Void

    var body: some View {
        ControlIconButton(
            systemName: isCurrentPositionBookmarked ? "bookmark.fill" : "bookmark",
            accessibilityLabel: isCurrentPositionBookmarked ? "Remove bookmark" : "Add bookmark",
            accessibilityIdentifier: "reader.toggle-bookmark",
            size: 58,
            isEnabled: canBookmark,
            action: onToggleBookmark
        )
    }
}

struct ReaderKeyboardShortcutsView: View {
    let onPlayPause: () -> Void
    let onExit: () -> Void
    let onSpeedUp: () -> Void
    let onSlowDown: () -> Void
    let onStepBackward: () -> Void
    let onStepForward: () -> Void
    let onJump: () -> Void
    let onSave: () -> Void

    var body: some View {
        Group {
            shortcutButton("Play or pause", shortcut: .space, modifiers: [], action: onPlayPause)
            shortcutButton("Exit focus mode", shortcut: .escape, modifiers: [], action: onExit)
            shortcutButton("Faster", shortcut: .upArrow, modifiers: [], action: onSpeedUp)
            shortcutButton("Slower", shortcut: .downArrow, modifiers: [], action: onSlowDown)
            shortcutButton("Previous word", shortcut: .leftArrow, modifiers: [], action: onStepBackward)
            shortcutButton("Next word", shortcut: .rightArrow, modifiers: [], action: onStepForward)
            shortcutButton("Jump", shortcut: "g", modifiers: [], action: onJump)
            shortcutButton("Save", shortcut: "s", modifiers: .command, action: onSave)
            shortcutButton("Save", shortcut: "s", modifiers: .control, action: onSave)
        }
        .frame(width: 0, height: 0)
        .opacity(0)
        .accessibilityHidden(true)
    }

    private func shortcutButton(
        _ title: String,
        shortcut: KeyEquivalent,
        modifiers: EventModifiers,
        action: @escaping () -> Void
    ) -> some View {
        Button(title, action: action)
            .keyboardShortcut(shortcut, modifiers: modifiers)
    }
}

private struct ControlIconButton: View {
    let systemName: String
    let accessibilityLabel: String
    var accessibilityIdentifier: String?
    var size: CGFloat = 46
    var isProminent = false
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size * 0.38, weight: .semibold))
                .frame(width: size, height: size)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(isProminent ? ReaderTheme.primaryControlForeground : ReaderTheme.controlForeground)
        .background(
            Circle()
                .fill(isProminent ? ReaderTheme.primaryControlFill : ReaderTheme.controlFill)
        )
        .opacity(isEnabled ? 1 : 0.35)
        .disabled(!isEnabled)
        .accessibilityLabel(accessibilityLabel)
        .optionalAccessibilityIdentifier(accessibilityIdentifier)
    }
}

private extension View {
    @ViewBuilder
    func optionalAccessibilityIdentifier(_ identifier: String?) -> some View {
        if let identifier {
            accessibilityIdentifier(identifier)
        } else {
            self
        }
    }
}

#Preview {
    ZStack {
        ReaderTheme.background.ignoresSafeArea()
        VStack(spacing: 28) {
            ReaderProgressView(progress: 0.42, isSeekingEnabled: true) { _ in }
            PlaybackControlsView(
                playbackState: .stopped,
                canStep: true,
                onRestart: {},
                onStepBackward: {},
                onPlayPause: {},
                onStop: {},
                onStepForward: {}
            )
            ReaderTouchControlsView(
                canStep: true,
                wordsPerMinute: 300,
                onStepBackward: {},
                onSlower: {},
                onFaster: {},
                onStepForward: {}
            )
        }
        .padding()
    }
}
