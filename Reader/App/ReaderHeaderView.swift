import SwiftUI

struct ReaderHeaderView: View {
    let wordCount: Int
    let isFocusMode: Bool
    let canJump: Bool
    let canBookmark: Bool
    let onOpenLibrary: () -> Void
    let onAddBook: () -> Void
    let onOpenBookmarks: () -> Void
    let onJump: () -> Void
    let onOpenSettings: () -> Void
    let themeMode: ReaderThemeMode
    let onToggleTheme: () -> Void
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
                .foregroundStyle(ReaderTheme.controlForeground)
                .background(
                    Circle()
                        .fill(ReaderTheme.controlFill)
                )
                .accessibilityLabel("Exit focus mode")
                .accessibilityIdentifier("reader.exit-focus")
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reader")
                        .font(.headline)
                        .foregroundStyle(ReaderTheme.primaryText)

                    Text("\(wordCount) words")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("reader.word-count")
                }

                Spacer()

                HStack(spacing: 6) {
                    HeaderIconButton(
                        systemName: "books.vertical",
                        accessibilityLabel: "Open library",
                        accessibilityIdentifier: "reader.open-library",
                        action: onOpenLibrary
                    )

                    HeaderIconButton(
                        systemName: "doc.badge.plus",
                        accessibilityLabel: "Add book",
                        accessibilityIdentifier: "reader.add-book",
                        action: onAddBook
                    )

                    HeaderIconButton(
                        systemName: "list.bullet.rectangle",
                        accessibilityLabel: "Show bookmarks",
                        accessibilityIdentifier: "reader.bookmarks",
                        isEnabled: canBookmark,
                        action: onOpenBookmarks
                    )

                    HeaderIconButton(
                        systemName: "target",
                        accessibilityLabel: "Jump to position",
                        accessibilityIdentifier: "reader.jump",
                        isEnabled: canJump,
                        action: onJump
                    )

                    HeaderIconButton(
                        systemName: "gearshape.fill",
                        accessibilityLabel: "Settings",
                        accessibilityIdentifier: "reader.settings",
                        action: onOpenSettings
                    )

                    HeaderIconButton(
                        systemName: themeMode.toggleSystemName,
                        accessibilityLabel: themeMode.toggleAccessibilityLabel,
                        accessibilityIdentifier: "reader.toggle-theme",
                        action: onToggleTheme
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
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 38, height: 38)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(ReaderTheme.controlForeground)
        .background(
            Circle()
                .fill(ReaderTheme.controlFill)
        )
        .opacity(isEnabled ? 1 : 0.35)
        .disabled(!isEnabled)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

#Preview {
    ZStack {
        ReaderTheme.background.ignoresSafeArea()
        VStack(spacing: 24) {
            ReaderHeaderView(
                wordCount: 120,
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
            ReaderHeaderView(
                wordCount: 120,
                isFocusMode: true,
                canJump: true,
                canBookmark: true,
                onOpenLibrary: {},
                onAddBook: {},
                onOpenBookmarks: {},
                onJump: {},
                onOpenSettings: {},
                themeMode: .dark,
                onToggleTheme: {},
                onExitFocusMode: {}
            )
        }
        .padding()
    }
}
