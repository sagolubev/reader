import SwiftUI

struct ReaderHeaderView: View {
    let wordCount: Int
    let isFocusMode: Bool
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
            }
        }
        .frame(height: 48)
        .animation(.easeInOut(duration: 0.18), value: isFocusMode)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 24) {
            ReaderHeaderView(wordCount: 120, isFocusMode: false, onExitFocusMode: {})
            ReaderHeaderView(wordCount: 120, isFocusMode: true, onExitFocusMode: {})
        }
        .padding()
    }
}
