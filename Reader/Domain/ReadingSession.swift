enum PlaybackState: Equatable {
    case stopped
    case playing
    case paused
}

struct ReadingSession: Equatable {
    var text = ""
    var words: [String] = []
    var currentWordIndex = 0
    var playbackState = PlaybackState.stopped
    var settings = ReaderSettings()

    var currentWord: String {
        guard words.indices.contains(currentWordIndex) else {
            return ""
        }

        return words[currentWordIndex]
    }

    var progressPercentage: Double {
        guard !words.isEmpty else {
            return 0
        }

        return (Double(currentWordIndex) / Double(words.count)) * 100
    }

    var currentFrame: WordFrame {
        RSVPTextProcessor.wordFrame(
            words: words,
            centerIndex: currentWordIndex,
            frameSize: settings.frameWordCount
        )
    }

    var timeRemaining: String {
        WordTiming.formatTimeRemaining(
            remainingWords: max(0, words.count - currentWordIndex),
            wordsPerMinute: settings.wordsPerMinute
        )
    }

    mutating func loadText(_ newText: String) {
        text = newText
        words = RSVPTextProcessor.parseText(newText)
        currentWordIndex = 0
        playbackState = .stopped
    }

    mutating func play() {
        guard !words.isEmpty else {
            return
        }

        playbackState = .playing
    }

    mutating func pause() {
        guard playbackState == .playing else {
            return
        }

        playbackState = .paused
    }

    @discardableResult
    mutating func pauseForLifecycleTransition(to phase: ReaderLifecyclePhase) -> Bool {
        guard phase.shouldPausePlayback, playbackState == .playing else {
            return false
        }

        pause()
        return true
    }

    mutating func resume() {
        guard playbackState == .paused, !words.isEmpty else {
            return
        }

        playbackState = .playing
    }

    mutating func stop() {
        playbackState = .stopped
        currentWordIndex = 0
    }

    mutating func restart() {
        stop()
        play()
    }

    mutating func stepForward(by count: Int = 1) {
        guard !words.isEmpty else {
            return
        }

        currentWordIndex = min(words.count - 1, currentWordIndex + max(0, count))
    }

    mutating func stepBackward(by count: Int = 1) {
        currentWordIndex = max(0, currentWordIndex - max(0, count))
    }

    mutating func adjustWordsPerMinute(by delta: Int) {
        settings.wordsPerMinute += delta
        settings.normalizeForControls()
    }

    mutating func advanceOneWord() {
        guard playbackState == .playing else {
            return
        }

        if currentWordIndex >= words.count - 1 {
            stop()
        } else {
            stepForward()
        }
    }

    mutating func seek(toPercentage percentage: Double) {
        guard !words.isEmpty else {
            return
        }

        let clampedPercentage = min(100, max(0, percentage))
        let target = Int((clampedPercentage / 100) * Double(words.count))
        currentWordIndex = min(words.count - 1, max(0, target))
    }

    mutating func jump(to value: String) {
        guard !words.isEmpty else {
            return
        }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.hasSuffix("%") {
            let percentText = String(trimmed.dropLast())
            if let percentage = Double(percentText) {
                seek(toPercentage: percentage)
            }
            return
        }

        if let wordIndex = Int(trimmed) {
            currentWordIndex = min(words.count - 1, max(0, wordIndex))
        }
    }
}
