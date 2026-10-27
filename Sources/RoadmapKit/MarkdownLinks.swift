/// The parts of Markdown that make GitHub render a link other than the one written.
///
/// The linter checks a resource URL as it is written in the file, but GitHub renders the link
/// after CommonMark has decoded backslash escapes (`\.`) and character references (`&#46;`,
/// `&period;`) in the destination, and browsers then read a `\` in an `https` URL as `/`. So
/// `https://github.com/apple/&#46;&#46;/evil` passes every check on the text and still opens
/// `github.com/evil`. Decoding every named character reference would need the HTML entity table,
/// so the parser accepts only destinations whose text is already the address: no backslash, no
/// character reference, no `<…>` form and no whitespace.
///
/// For the same reason a link may only be written as a plain `- [Title](https://…)` item under
/// `**Learn from:**`: a title that moves the end of the link, a second link in the item's note,
/// or a link anywhere else in a track file would be rendered without being checked.
enum MarkdownLinks {
    static let outsideItemsProblem = "links may only appear as `- [Title](https://…)` items under `**Learn from:**`"
    static let outsideTopicsProblem = "links may only appear as `- [Title](https://…)` items under a topic's `**Learn from:**`"

    /// Why GitHub would render the item `- [title](url)` followed by `note` as a link other than
    /// `resource`, as a message suffix after the topic ID, or `nil`.
    static func itemProblem(_ resource: Resource, note: Substring) -> String? {
        if let problem = titleProblem(resource.title) {
            return ": the link title `\(resource.title)` \(problem)"
        }
        if let problem = destinationProblem(resource.url) {
            return ": `\(resource.url)` \(problem)"
        }
        if containsLink(note) {
            return ": \(outsideItemsProblem)"
        }
        return nil
    }

    /// Why GitHub would open a different address than `destination` reads, or `nil`.
    static func destinationProblem<S: StringProtocol>(_ destination: S) -> String? {
        let rewritten = destination.contains("\\")
            || destination.first == "<"
            || destination.contains(where: { $0.isWhitespace || $0.unicodeScalars.contains { $0.properties.generalCategory == .control } })
            || containsCharacterReference(destination)
        guard rewritten else { return nil }
        return "must be written without backslashes, `<…>`, spaces or character references such as `&#46;`: GitHub decodes them, so the link would open another address than the one checked"
    }

    /// Why the link text `title` could make GitHub end the link somewhere else, or `nil`.
    ///
    /// Code spans, raw HTML, autolinks and escapes bind tighter than the brackets of a link, so in
    /// ``- [`](https://a)`](https://b)`` GitHub links the code span to `b` while a reader of the
    /// text, and the parser, see a link to `a`.
    static func titleProblem<S: StringProtocol>(_ title: S) -> String? {
        guard title.contains(where: { "[]`<\\".contains($0) }) || containsLink(title) else { return nil }
        return "must not contain `[`, `]`, `` ` ``, `<`, `\\` or a link, which change where GitHub ends the link"
    }

    /// Whether GitHub could render a link from `text`, read as Markdown outside a link.
    ///
    /// Covers inline links and images (`](`), reference links and their definitions (`][`,
    /// `]:`), autolinks and raw `<a>` or `<area>` tags, and the GitHub extensions that link bare
    /// `https://…`, `www.…` and e-mail addresses. A backslash escape only removes the backslash
    /// and a character reference can spell any of these, so both are read as what they decode
    /// to. The check is deliberately wider than GitHub: it also matches inside code spans, which
    /// is why a summary writes `@MainActor` (no letter before the `@`) but not `user@host`.
    static func containsLink<S: StringProtocol>(_ text: S) -> Bool {
        if containsCharacterReference(text) { return true }
        let plain = String(text.lowercased().filter { $0 != "\\" })
        if ["](", "][", "]:", "://", "www."].contains(where: { plain.contains($0) }) { return true }
        return containsTagOrAutolink(plain) || containsEmailAddress(plain)
    }

    /// `<a …>`, `<area …>`, or an autolink such as `<https:…>` or `<mailto:…>`, in lowercased text.
    private static func containsTagOrAutolink(_ text: String) -> Bool {
        let characters = Array(text)
        for (index, character) in characters.enumerated() where character == "<" {
            let run = characters[(index + 1)...].prefix { $0.isASCII && ($0.isLetter || $0.isNumber || "+.-".contains($0)) }
            let next = characters.indices.contains(index + 1 + run.count) ? characters[index + 1 + run.count] : " "
            if let first = run.first, first.isLetter, (2...32).contains(run.count), next == ":" { return true }
            if ["a", "area"].contains(String(run)), next.isWhitespace || next == ">" || next == "/" { return true }
        }
        return false
    }

    /// An `@` between a character of an address's local part and a letter or digit, as in
    /// `someone@example.com`; `@MainActor` after a space or a backtick is not one.
    private static func containsEmailAddress(_ text: String) -> Bool {
        let characters = Array(text)
        let isLocal: (Character) -> Bool = { $0.isASCII && ($0.isLetter || $0.isNumber || "._+-".contains($0)) }
        for index in characters.indices.dropFirst().dropLast() where characters[index] == "@" {
            let after = characters[index + 1]
            if isLocal(characters[index - 1]), after.isASCII, after.isLetter || after.isNumber { return true }
        }
        return false
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
