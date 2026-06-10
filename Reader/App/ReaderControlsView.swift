import SwiftUI

struct ReaderProgressView: View {
    let progress: Double
    let isSeekingEnabled: Bool
    let onSeek: (Double) -> Void

    private let markerColor = Color(red: 0.92, green: 0.12, blue: 0.12)

    var body: some View {
        GeometryReader { proxy in
            let clampedProgress = min(1, max(0, progress))

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.16))

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

private struct ControlIconButton: View {
    let systemName: String
    let accessibilityLabel: String
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
        .foregroundStyle(isProminent ? .black : .white)
        .background(
            Circle()
                .fill(isProminent ? Color.white : Color.white.opacity(0.14))
        )
        .opacity(isEnabled ? 1 : 0.35)
        .disabled(!isEnabled)
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
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
        }
        .padding()
    }
}
