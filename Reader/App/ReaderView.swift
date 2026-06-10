import SwiftUI

struct ReaderView: View {
    @State private var session: ReadingSession

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

                Text(session.currentWord)
                    .font(.system(size: 56, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.35)
                    .accessibilityIdentifier("reader.current-word")

                Text("\(session.currentWordIndex + 1) / \(session.words.count)")
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("reader.progress-summary")

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 28)
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
}

private extension ReaderView {
    static let defaultText = """
    Rapid serial visual presentation keeps one word in focus at a time. Load text, set the speed, and read without moving your eyes across the page.
    """
}

#Preview {
    ReaderView()
}
