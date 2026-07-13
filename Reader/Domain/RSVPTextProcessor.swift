import Foundation

struct WordDisplayParts: Equatable {
    let before: String
    let orp: String
    let after: String
}

struct WordFrame: Equatable {
    let words: [String]
    let centerOffset: Int
}

enum RSVPTextProcessor {
    static func parseText(_ text: String) -> [String] {
        (try? parseText(text, limits: .default)) ?? []
    }

    static func parseText(
        _ text: String,
        limits: ReaderResourceLimits
    ) throws -> [String] {
        guard text.utf8.count <= limits.maxDocumentBytes,
              text.count <= limits.maxExtractedCharacters else {
            throw DocumentImportError.resourceLimitExceeded
        }

        let subsequences = text.split(
            maxSplits: limits.maxTokenCount,
            omittingEmptySubsequences: true,
            whereSeparator: { $0.isWhitespace }
        )
        guard subsequences.count <= limits.maxTokenCount else {
            throw DocumentImportError.resourceLimitExceeded
        }

        var words: [String] = []
        words.reserveCapacity(subsequences.count)
        for subsequence in subsequences {
            guard subsequence.utf8.count <= limits.maxTokenBytes,
                  subsequence.count <= limits.maxTokenCharacters else {
                throw DocumentImportError.resourceLimitExceeded
            }
            words.append(String(subsequence))
        }
        return words
    }

    static func splitForDisplay(_ word: String) -> WordDisplayParts {
        (try? splitForDisplay(word, limits: .default))
            ?? WordDisplayParts(before: "", orp: "…", after: "")
    }

    static func splitForDisplay(
        _ word: String,
        limits: ReaderResourceLimits
    ) throws -> WordDisplayParts {
        guard word.utf8.count <= limits.maxTokenBytes,
              word.count <= limits.maxTokenCharacters else {
            throw DocumentImportError.resourceLimitExceeded
        }
        guard !word.isEmpty else {
            return WordDisplayParts(before: "", orp: "", after: "")
        }

        let index = actualORPIndex(in: word) ?? word.startIndex
        let nextIndex = word.index(after: index)

        return WordDisplayParts(
            before: String(word[..<index]),
            orp: String(word[index]),
            after: String(word[nextIndex...])
        )
    }

    static func wordFrame(words: [String], centerIndex: Int, frameSize: Int) -> WordFrame {
        guard words.indices.contains(centerIndex) else {
            return WordFrame(words: [], centerOffset: 0)
        }

        guard frameSize > 1 else {
            return WordFrame(words: [words[centerIndex]], centerOffset: 0)
        }

        let radius = max(0, frameSize / 2)
        let lowerBound = max(0, centerIndex - radius)
        let upperBound = min(words.count, centerIndex + radius + 1)

        return WordFrame(
            words: Array(words[lowerBound..<upperBound]),
            centerOffset: centerIndex - lowerBound
        )
    }

    private static func actualORPIndex(in word: String) -> String.Index? {
        let targetLetterOffset = orpLetterOffset(in: word)
        var currentLetterOffset = 0

        for index in word.indices {
            if word[index].containsLetter {
                if currentLetterOffset == targetLetterOffset {
                    return index
                }
                currentLetterOffset += 1
            }
        }

        return word.startIndex
    }

    private static func orpLetterOffset(in word: String) -> Int {
        let letterCount = word.filter(\.containsLetter).count

        if letterCount <= 3 {
            return 0
        }
        if letterCount <= 5 {
            return 1
        }
        if letterCount <= 9 {
            return 2
        }
        if letterCount <= 12 {
            return 3
        }

        return Int(floor(log2(Double(letterCount - 1)))) + 1
    }
}

private extension Character {
    var containsLetter: Bool {
        unicodeScalars.contains { CharacterSet.letters.contains($0) }
    }
}
