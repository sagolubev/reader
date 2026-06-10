import SwiftUI

struct ResumeSessionView: View {
    @Environment(\.dismiss) private var dismiss

    let snapshot: SavedSessionSnapshot
    let onResume: () -> Void
    let onStartFresh: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Resume Session")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)

                        Text(sessionSummary)
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 12) {
                        Button(action: resume) {
                            Label("Resume", systemImage: "arrow.clockwise")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("resume-session.resume")

                        Button(role: .destructive, action: startFresh) {
                            Label("Start Fresh", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("resume-session.start-fresh")
                    }
                    .controlSize(.large)

                    Spacer(minLength: 0)
                }
                .padding(24)
            }
            .navigationTitle("Saved Session")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
        .accessibilityIdentifier("resume-session.sheet")
    }

    private var sessionSummary: String {
        let position = min(snapshot.totalWordCount, snapshot.currentWordIndex + 1)
        let date = snapshot.savedAt.formatted(date: .abbreviated, time: .shortened)
        return "\(position) / \(snapshot.totalWordCount) words - \(date)"
    }

    private func resume() {
        onResume()
        dismiss()
    }

    private func startFresh() {
        onStartFresh()
        dismiss()
    }
}

#Preview {
    ResumeSessionView(
        snapshot: SavedSessionSnapshot(
            text: "one two three",
            currentWordIndex: 1,
            totalWordCount: 3,
            settings: ReaderSettings(),
            savedAt: Date()
        ),
        onResume: {},
        onStartFresh: {}
    )
}
