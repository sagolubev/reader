import SwiftUI

struct RootView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Ready")
                    .font(.system(size: 48, weight: .medium, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("reader.ready")

                Text("RSVP Reader")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    RootView()
}
