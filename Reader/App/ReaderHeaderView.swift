import SwiftUI

struct ReaderHeaderView: View {
    let wordCount: Int
    let isFocusMode: Bool
    let onLoadContent: () -> Void
    let onOpenSettings: () -> Void
    let onExitFocusMode: () -> Void

    var body: some View {
        HStack {
            if isFocusMode {
                Spacer()

                Button(action: onExitFocusMode) {
                    Image(systemName: "xmark")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.14))
                )
                .accessibilityLabel("Exit focus mode")
                .accessibilityIdentifier("reader.exit-focus")
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reader")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("\(wordCount) words")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("reader.word-count")
                }

                Spacer()

                HStack(spacing: 10) {
                    HeaderIconButton(
                        systemName: "doc.badge.plus",
                        accessibilityLabel: "Load content",
                        accessibilityIdentifier: "reader.load-content",
                        action: onLoadContent
                    )

                    HeaderIconButton(
                        systemName: "gearshape.fill",
                        accessibilityLabel: "Settings",
                        accessibilityIdentifier: "reader.settings",
                        action: onOpenSettings
                    )
                }
            }
        }
        .frame(height: 48)
        .animation(.easeInOut(duration: 0.18), value: isFocusMode)
    }
}

private struct HeaderIconButton: View {
    let systemName: String
    let accessibilityLabel: String
    let accessibilityIdentifier: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(
            Circle()
                .fill(Color.white.opacity(0.14))
        )
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 24) {
            ReaderHeaderView(
                wordCount: 120,
                isFocusMode: false,
                onLoadContent: {},
                onOpenSettings: {},
                onExitFocusMode: {}
            )
            ReaderHeaderView(
                wordCount: 120,
                isFocusMode: true,
                onLoadContent: {},
                onOpenSettings: {},
                onExitFocusMode: {}
            )
        }
        .padding()
    }
}
