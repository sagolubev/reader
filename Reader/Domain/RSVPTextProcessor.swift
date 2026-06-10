import Foundation

struct WordDisplayParts: Equatable {
    let before: String
    let orp: String
    let after: String
}

enum RSVPTextProcessor {
    static func parseText(_ text: String) -> [String] {
        text
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)
    }

    static func splitForDisplay(_ word: String) -> WordDisplayParts {
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
