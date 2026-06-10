import SwiftUI

struct RSVPDisplayView: View {
    let frame: WordFrame
    let fadeEnabled: Bool
    let fadeDurationMilliseconds: Int

    @State private var displayOpacity = 1.0

    private let displayFontSize: CGFloat = 58
    private let markerColor = Color(red: 0.92, green: 0.12, blue: 0.12)

    init(word: String) {
        self.init(
            frame: WordFrame(words: [word], centerOffset: 0),
            fadeEnabled: true,
            fadeDurationMilliseconds: ReaderSettings().fadeDurationMilliseconds
        )
    }

    init(frame: WordFrame, fadeEnabled: Bool, fadeDurationMilliseconds: Int) {
        self.frame = frame
        self.fadeEnabled = fadeEnabled
        self.fadeDurationMilliseconds = fadeDurationMilliseconds
    }

    var body: some View {
        let parts = RSVPTextProcessor.splitForDisplay(currentWord)
        let before = joinedWords(prefixWords, parts.before)
        let after = joinedWords(parts.after, suffixWords)

        GeometryReader { proxy in
            let centerColumnWidth = displayFontSize * 0.72
            let sideWidth = max(0, (proxy.size.width - centerColumnWidth) / 2)

            ZStack {
                centerMarker

                HStack(spacing: 0) {
                    Text(before)
                        .frame(width: sideWidth, alignment: .trailing)
                        .clipped()

                    Text(parts.orp)
                        .foregroundStyle(markerColor)
                        .frame(width: centerColumnWidth, alignment: .center)

                    Text(after)
                        .frame(width: sideWidth, alignment: .leading)
                        .clipped()
                }
                .frame(width: proxy.size.width)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .font(.system(size: displayFontSize, weight: .medium, design: .monospaced))
        .foregroundStyle(.white)
        .lineLimit(1)
        .minimumScaleFactor(0.28)
        .allowsTightening(true)
        .opacity(displayOpacity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityIdentifier("reader.orp-display")
        .frame(maxWidth: .infinity)
        .frame(height: 148)
        .onChange(of: displayID) {
            animateDisplayChange()
        }
    }

    private var centerMarker: some View {
        VStack(spacing: 10) {
            Capsule()
                .fill(markerColor)
                .frame(width: 3, height: 28)

            Spacer()

            Capsule()
                .fill(markerColor)
                .frame(width: 3, height: 28)
        }
        .padding(.vertical, 10)
        .accessibilityHidden(true)
    }

    private var currentWord: String {
        guard frame.words.indices.contains(frame.centerOffset) else {
            return ""
        }

        return frame.words[frame.centerOffset]
    }

    private var prefixWords: String {
        guard frame.centerOffset > 0 else {
            return ""
        }

        return frame.words[..<frame.centerOffset].joined(separator: " ")
    }

    private var suffixWords: String {
        let nextIndex = frame.centerOffset + 1
        guard frame.words.indices.contains(nextIndex) else {
            return ""
        }

        return frame.words[nextIndex...].joined(separator: " ")
    }

    private var accessibilityText: String {
        let text = frame.words.joined(separator: " ")
        return text.isEmpty ? currentWord : text
    }

    private var displayID: String {
        "\(frame.centerOffset)|\(frame.words.joined(separator: "\u{1F}"))"
    }

    private func joinedWords(_ lhs: String, _ rhs: String) -> String {
        [lhs, rhs]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private func animateDisplayChange() {
        guard fadeEnabled else {
            displayOpacity = 1
            return
        }

        displayOpacity = 0
        withAnimation(.easeOut(duration: Double(max(0, fadeDurationMilliseconds)) / 1_000)) {
            displayOpacity = 1
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        RSVPDisplayView(word: "reading")
            .padding()
    }
}
