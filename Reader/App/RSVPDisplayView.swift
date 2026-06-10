import SwiftUI

struct RSVPDisplayView: View {
    let word: String

    private let displayFontSize: CGFloat = 58
    private let markerColor = Color(red: 0.92, green: 0.12, blue: 0.12)

    var body: some View {
        let parts = RSVPTextProcessor.splitForDisplay(word)
        let orpHalfWidth = displayFontSize * 0.3

        ZStack {
            centerMarker

            ZStack {
                Text(parts.before)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .offset(x: -orpHalfWidth)

                Text(parts.orp)
                    .foregroundStyle(markerColor)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text(parts.after)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(x: orpHalfWidth)
            }
            .font(.system(size: displayFontSize, weight: .medium, design: .monospaced))
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.28)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(word)
            .accessibilityIdentifier("reader.orp-display")
        }
        .frame(maxWidth: .infinity)
        .frame(height: 148)
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
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        RSVPDisplayView(word: "reading")
            .padding()
    }
}
