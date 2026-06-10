struct ReaderSettings: Equatable {
    static let wordsPerMinuteRange = 50...1_000
    static let wordsPerMinuteStep = 25
    static let fadeDurationRange = 50...300
    static let fadeDurationStep = 25
    static let pauseAfterWordsRange = 0...50
    static let pauseAfterWordsStep = 5
    static let pauseDurationRange = 100...2_000
    static let pauseDurationStep = 100
    static let punctuationPauseMultiplierRange = 1.0...4.0
    static let punctuationPauseMultiplierStep = 0.5
    static let wordLengthWPMMultiplierRange = 0.0...50.0
    static let wordLengthWPMMultiplierStep = 1.0
    static let frameWordCounts = [1, 3, 5, 7]

    var wordsPerMinute = 300
    var fadeEnabled = true
    var fadeDurationMilliseconds = 150
    var pauseAfterWords = 0
    var pauseDurationMilliseconds = 500
    var pauseOnPunctuation = true
    var punctuationPauseMultiplier = 2.0
    var wordLengthWPMMultiplier = 5.0
    var frameWordCount = 1

    mutating func normalizeForControls() {
        wordsPerMinute = Self.clamp(wordsPerMinute, to: Self.wordsPerMinuteRange)
        fadeDurationMilliseconds = Self.clamp(fadeDurationMilliseconds, to: Self.fadeDurationRange)
        pauseAfterWords = Self.clamp(pauseAfterWords, to: Self.pauseAfterWordsRange)
        pauseDurationMilliseconds = Self.clamp(pauseDurationMilliseconds, to: Self.pauseDurationRange)
        punctuationPauseMultiplier = Self.clamp(
            punctuationPauseMultiplier,
            to: Self.punctuationPauseMultiplierRange
        )
        wordLengthWPMMultiplier = Self.clamp(
            wordLengthWPMMultiplier,
            to: Self.wordLengthWPMMultiplierRange
        )
        frameWordCount = Self.nearestFrameWordCount(to: frameWordCount)
    }

    private static func clamp<T: Comparable>(_ value: T, to range: ClosedRange<T>) -> T {
        min(range.upperBound, max(range.lowerBound, value))
    }

    private static func nearestFrameWordCount(to value: Int) -> Int {
        frameWordCounts.min { lhs, rhs in
            abs(lhs - value) < abs(rhs - value)
        } ?? 1
    }
}
