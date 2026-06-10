import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var settings: ReaderSettings

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        SettingsSection(title: "Speed", systemName: "speedometer") {
                            SliderSettingRow(
                                title: "Words per minute",
                                valueText: "\(settings.wordsPerMinute) WPM"
                            ) {
                                Slider(
                                    value: wordsPerMinuteBinding,
                                    in: Double(ReaderSettings.wordsPerMinuteRange.lowerBound)...Double(ReaderSettings.wordsPerMinuteRange.upperBound),
                                    step: Double(ReaderSettings.wordsPerMinuteStep)
                                )
                                .accessibilityLabel("Words per minute")
                                .accessibilityValue("\(settings.wordsPerMinute) words per minute")
                            }

                            HStack(spacing: 10) {
                                ForEach([200, 300, 400, 500], id: \.self) { preset in
                                    Button("\(preset)") {
                                        settings.wordsPerMinute = preset
                                        settings.normalizeForControls()
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                    .tint(settings.wordsPerMinute == preset ? .red : .white)
                                    .accessibilityLabel(presetAccessibilityLabel(for: preset))
                                }
                            }
                            .accessibilityIdentifier("settings.wpm-presets")

                            SliderSettingRow(
                                title: "Long-word pause",
                                valueText: "\(Int(settings.wordLengthWPMMultiplier))%"
                            ) {
                                Slider(
                                    value: wordLengthMultiplierBinding,
                                    in: ReaderSettings.wordLengthWPMMultiplierRange,
                                    step: ReaderSettings.wordLengthWPMMultiplierStep
                                )
                                .accessibilityLabel("Long-word pause")
                                .accessibilityValue("\(Int(settings.wordLengthWPMMultiplier)) percent")
                            }
                        }

                        SettingsSection(title: "Display", systemName: "text.word.spacing") {
                            VStack(alignment: .leading, spacing: 10) {
                                SettingHeader(
                                    title: "Words shown",
                                    valueText: "\(settings.frameWordCount)"
                                )

                                Picker("Words shown", selection: $settings.frameWordCount) {
                                    ForEach(ReaderSettings.frameWordCounts, id: \.self) { count in
                                        Text("\(count)").tag(count)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .accessibilityIdentifier("settings.frame-word-count")
                            }
                        }

                        SettingsSection(title: "Effects", systemName: "sparkles") {
                            Toggle("Word fade", isOn: $settings.fadeEnabled)
                                .tint(.red)
                                .accessibilityIdentifier("settings.fade-enabled")

                            if settings.fadeEnabled {
                                SliderSettingRow(
                                    title: "Fade duration",
                                    valueText: "\(settings.fadeDurationMilliseconds) ms"
                                ) {
                                    Slider(
                                        value: fadeDurationBinding,
                                        in: Double(ReaderSettings.fadeDurationRange.lowerBound)...Double(ReaderSettings.fadeDurationRange.upperBound),
                                        step: Double(ReaderSettings.fadeDurationStep)
                                    )
                                    .accessibilityLabel("Fade duration")
                                    .accessibilityValue("\(settings.fadeDurationMilliseconds) milliseconds")
                                }
                            }
                        }

                        SettingsSection(title: "Pauses", systemName: "pause.fill") {
                            Toggle("Pause on punctuation", isOn: $settings.pauseOnPunctuation)
                                .tint(.red)
                                .accessibilityIdentifier("settings.pause-on-punctuation")

                            if settings.pauseOnPunctuation {
                                SliderSettingRow(
                                    title: "Punctuation multiplier",
                                    valueText: "\(settings.punctuationPauseMultiplier.formatted(.number.precision(.fractionLength(0...1))))x"
                                ) {
                                    Slider(
                                        value: punctuationMultiplierBinding,
                                        in: ReaderSettings.punctuationPauseMultiplierRange,
                                        step: ReaderSettings.punctuationPauseMultiplierStep
                                    )
                                    .accessibilityLabel("Punctuation multiplier")
                                    .accessibilityValue("\(settings.punctuationPauseMultiplier.formatted(.number.precision(.fractionLength(0...1)))) times")
                                }
                            }

                            SliderSettingRow(
                                title: "Pause every",
                                valueText: settings.pauseAfterWords == 0 ? "Off" : "\(settings.pauseAfterWords) words"
                            ) {
                                Slider(
                                    value: pauseAfterWordsBinding,
                                    in: Double(ReaderSettings.pauseAfterWordsRange.lowerBound)...Double(ReaderSettings.pauseAfterWordsRange.upperBound),
                                    step: Double(ReaderSettings.pauseAfterWordsStep)
                                )
                                .accessibilityLabel("Pause interval")
                                .accessibilityValue(settings.pauseAfterWords == 0 ? "Off" : "\(settings.pauseAfterWords) words")
                            }

                            if settings.pauseAfterWords > 0 {
                                SliderSettingRow(
                                    title: "Pause duration",
                                    valueText: "\(settings.pauseDurationMilliseconds) ms"
                                ) {
                                    Slider(
                                        value: pauseDurationBinding,
                                        in: Double(ReaderSettings.pauseDurationRange.lowerBound)...Double(ReaderSettings.pauseDurationRange.upperBound),
                                        step: Double(ReaderSettings.pauseDurationStep)
                                    )
                                    .accessibilityLabel("Pause duration")
                                    .accessibilityValue("\(settings.pauseDurationMilliseconds) milliseconds")
                                }
                            }
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            settings.normalizeForControls()
        }
        .accessibilityIdentifier("settings.sheet")
    }

    private var wordsPerMinuteBinding: Binding<Double> {
        Binding(
            get: { Double(settings.wordsPerMinute) },
            set: {
                settings.wordsPerMinute = Int($0)
                settings.normalizeForControls()
            }
        )
    }

    private var fadeDurationBinding: Binding<Double> {
        Binding(
            get: { Double(settings.fadeDurationMilliseconds) },
            set: {
                settings.fadeDurationMilliseconds = Int($0)
                settings.normalizeForControls()
            }
        )
    }

    private var pauseAfterWordsBinding: Binding<Double> {
        Binding(
            get: { Double(settings.pauseAfterWords) },
            set: {
                settings.pauseAfterWords = Int($0)
                settings.normalizeForControls()
            }
        )
    }

    private var pauseDurationBinding: Binding<Double> {
        Binding(
            get: { Double(settings.pauseDurationMilliseconds) },
            set: {
                settings.pauseDurationMilliseconds = Int($0)
                settings.normalizeForControls()
            }
        )
    }

    private var punctuationMultiplierBinding: Binding<Double> {
        Binding(
            get: { settings.punctuationPauseMultiplier },
            set: {
                settings.punctuationPauseMultiplier = $0
                settings.normalizeForControls()
            }
        )
    }

    private var wordLengthMultiplierBinding: Binding<Double> {
        Binding(
            get: { settings.wordLengthWPMMultiplier },
            set: {
                settings.wordLengthWPMMultiplier = $0
                settings.normalizeForControls()
            }
        )
    }

    private func presetAccessibilityLabel(for preset: Int) -> String {
        switch preset {
        case 200:
            return "Set 200 words per minute"
        case 300:
            return "Set 300 words per minute"
        case 400:
            return "Set 400 words per minute"
        case 500:
            return "Set 500 words per minute"
        default:
            return "Set \(preset) words per minute"
        }
    }
}

private struct SettingsSection<Content: View>: View {
    let title: String
    let systemName: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: systemName)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            VStack(alignment: .leading, spacing: 18) {
                content()
            }
        }
    }
}

private struct SliderSettingRow<Content: View>: View {
    let title: String
    let valueText: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SettingHeader(title: title, valueText: valueText)
            content()
        }
    }
}

private struct SettingHeader: View {
    let title: String
    let valueText: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .foregroundStyle(.white)
            Spacer(minLength: 12)
            Text(valueText)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    @Previewable @State var settings = ReaderSettings()
    SettingsView(settings: $settings)
}
