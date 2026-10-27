/// The parts of Markdown that make GitHub render a link other than the one written.
///
/// The linter checks a resource URL as it is written in the file, but GitHub renders the link
/// after CommonMark has decoded backslash escapes (`\.`) and character references (`&#46;`,
/// `&period;`) in the destination, and browsers then read a `\` in an `https` URL as `/`. So
/// `https://github.com/apple/&#46;&#46;/evil` passes every check on the text and still opens
/// `github.com/evil`. Decoding every named character reference would need the HTML entity table,
/// so the parser accepts only destinations whose text is already the address: no backslash, no
/// character reference, no `<…>` form and no whitespace.
enum MarkdownLinks {
    /// Why GitHub would open a different address than `destination` reads, or `nil`.
    static func destinationProblem<S: StringProtocol>(_ destination: S) -> String? {
        let rewritten = destination.contains("\\")
            || destination.first == "<"
            || destination.contains(where: { $0.isWhitespace || $0.unicodeScalars.contains { $0.properties.generalCategory == .control } })
            || containsCharacterReference(destination)
        guard rewritten else { return nil }
        return "must be written without backslashes, `<…>`, spaces or character references such as `&#46;`: GitHub decodes them, so the link would open another address than the one checked"
    }

    /// Whether `text` contains a CommonMark character reference: `&name;` with up to 32 ASCII
    /// letters and digits starting with a letter, `&#` and 1–7 digits, or `&#x` and 1–6 hex
    /// digits, each ending with `;`. Any name counts, known to HTML or not, so the check needs no
    /// entity table; an `&` in a query string such as `?a=1&b=2` is not a reference.
    static func containsCharacterReference<S: StringProtocol>(_ text: S) -> Bool {
        var rest = Substring(text)
        while let ampersand = rest.firstIndex(of: "&") {
            rest = rest[rest.index(after: ampersand)...]
            if isReferenceBody(rest) { return true }
        }
        return false
    }

    /// `name;`, `#123;` or `#x1F;` at the start of `text`.
    private static func isReferenceBody(_ text: Substring) -> Bool {
        guard let semicolon = text.prefix(34).firstIndex(of: ";") else { return false }
        let body = text[..<semicolon]
        let isDigit: (Character) -> Bool = { $0.isASCII && $0.isNumber }
        if body.first == "#" {
            let number = body.dropFirst()
            if number.first == "x" || number.first == "X" {
                let hex = number.dropFirst()
                return (1...6).contains(hex.count) && hex.allSatisfy { $0.isASCII && $0.isHexDigit }
            }
            return (1...7).contains(number.count) && number.allSatisfy(isDigit)
        }
        guard let first = body.first, first.isASCII, first.isLetter, body.count <= 32 else { return false }
        return body.allSatisfy { $0.isASCII && ($0.isLetter || isDigit($0)) }
    }
}
