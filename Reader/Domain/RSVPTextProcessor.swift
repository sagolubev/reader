enum RSVPTextProcessor {
    static func parseText(_ text: String) -> [String] {
        text
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)
    }
}
