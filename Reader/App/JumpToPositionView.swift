import SwiftUI

struct JumpToPositionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var target = ""

    let currentWordIndex: Int
    let totalWordCount: Int
    let onJump: (String) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                ReaderTheme.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 18) {
                    Text("\(currentWordIndex + 1) / \(totalWordCount)")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Current position")
                        .accessibilityValue("\(currentWordIndex + 1) of \(totalWordCount) words")
                        .accessibilityIdentifier("jump.position-summary")

                    TextField("Word or percent", text: $target)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numbersAndPunctuation)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.go)
                        .onSubmit(jump)
                        .accessibilityLabel("Jump target")
                        .accessibilityIdentifier("jump.target")

                    Button(action: jump) {
                        Label("Jump", systemImage: "target")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!canJump)
                    .accessibilityIdentifier("jump.submit")

                    Spacer(minLength: 0)
                }
                .padding(24)
            }
            .navigationTitle("Jump")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .tint(ReaderTheme.accent)
        .accessibilityIdentifier("jump.sheet")
    }

    private var canJump: Bool {
        !target.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func jump() {
        guard canJump else {
            return
        }

        onJump(target)
        dismiss()
    }
}

#Preview {
    JumpToPositionView(
        currentWordIndex: 149,
        totalWordCount: 300,
        onJump: { _ in }
    )
}
