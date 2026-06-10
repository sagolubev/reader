enum WordTiming {
    static func delayMilliseconds(for word: String, settings: ReaderSettings) -> Double {
        guard settings.wordsPerMinute > 0 else {
            return 200
        }

        var delay = 60_000 / Double(settings.wordsPerMinute)

        if settings.wordLengthWPMMultiplier > 0 && word.count >= 12 {
            delay *= 1 + ((settings.wordLengthWPMMultiplier / 100) * Double(word.count - 12))
        }

        guard settings.pauseOnPunctuation, let lastCharacter = word.last else {
            return delay
        }

        if ".!?;:".contains(lastCharacter) {
            return delay * settings.punctuationPauseMultiplier
        }

        if lastCharacter == "," {
            return delay * 1.5
        }

        return delay
    }
}
