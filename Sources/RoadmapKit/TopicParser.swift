/// The result of reading one roadmap file.
public struct ParsedFile: Sendable {
    /// The file's `# ` heading.
    public var title: String?
    public var topics: [Topic]
    public var diagnostics: [Diagnostic]
}

/// Reads the Markdown format described in `roadmap/README.md`:
///
/// ```markdown
/// # iOS
///
/// ## ios/swift-concurrency: Swift concurrency
///
/// **Stage:** intermediate · **Needs:** ios/swift, foundations/threads
///
/// What to learn, in Markdown.
///
/// **Practice:** A small project.
///
/// **Learn from:**
///
/// - [Concurrency](https://docs.swift.org/swift-book/...)
/// ```
///
/// The parser never throws: everything it cannot read becomes a ``Diagnostic`` with a line
/// number, so one run reports every problem in a file, up to a limit.
public enum TopicParser {
    static let stagePrefix = "**Stage:** "
    static let needsPrefix = "**Needs:** "
    static let practicePrefix = "**Practice:** "
    static let resourcesLine = "**Learn from:**"
    static let separator = " · "
    /// Longest slug after `<track>/`.
    static let maxSlugLength = 48
    /// Longest topic title, in characters. Titles are printed in lists, plans and graphs.
    public static let maxTitleLength = 120

    public static func parse(
        _ text: String,
        track: Track,
        file: String,
        limits: RoadmapLimits = .default
    ) -> ParsedFile {
        var parsed = ParsedFile(title: nil, topics: [], diagnostics: [])
        var log = DiagnosticLog(limit: limits.maxDiagnosticsPerFile)
        var fence = FenceTracker()
        var current: TopicDraft?
        var fenceStart = 0

        // Lines outside a topic's body are rendered too, so they may not carry a link either. The
        // body of a topic whose heading was rejected is not checked again: that file already fails.
        var afterRejectedHeading = false
        func checkOutsideTopics(_ line: Substring, at location: SourceLocation) {
            if !afterRejectedHeading, MarkdownLinks.containsLink(line) {
                log.append(Diagnostic(MarkdownLinks.outsideTopicsProblem, at: location))
            }
        }

        func finish() {
            guard let draft = current else { return }
            current = nil
            if let topic = draft.build(track: track, file: file, limits: limits, diagnostics: &log) {
                parsed.topics.append(topic)
            }
        }

        for (offset, line) in splitLines(text).enumerated() {
            let number = offset + 1
            let location = SourceLocation(file: file, line: number)
            let wasInCode = fence.isOpen
            if fence.consume(line) {
                if !wasInCode { fenceStart = number }
                if current == nil { checkOutsideTopics(line, at: location) }
                current?.body.append((number, line))
                continue
            }
            if line.hasPrefix("# ") {
                checkOutsideTopics(line, at: location)
                if parsed.title == nil && current == nil && parsed.topics.isEmpty {
                    parsed.title = line.dropFirst(2).trimmingSpaces()
                } else {
                    log.append(Diagnostic("only one `# ` heading is allowed, before the first topic", at: location))
                }
                continue
            }
            if line.hasPrefix("## ") {
                finish()
                afterRejectedHeading = false
                checkOutsideTopics(line, at: location)
                afterRejectedHeading = true
                if parsed.topics.count >= limits.maxTopicsPerFile {
                    log.append(Diagnostic("more than \(limits.maxTopicsPerFile) topics in one file; the rest were not read", at: location))
                    parsed.diagnostics = log.entries
                    return parsed
                }
                if parsed.title == nil {
                    log.append(Diagnostic("the file needs a `# Title` heading before its first topic", at: location))
                    parsed.title = ""
                }
                guard let (id, title) = parseHeading(line.dropFirst(3)) else {
                    log.append(Diagnostic("topic headings look like `## \(track.rawValue)/topic-name: Title`", at: location))
                    continue
                }
                guard title.count <= maxTitleLength else {
                    log.append(Diagnostic("\(id): the title is longer than \(maxTitleLength) characters", at: location))
                    continue
                }
                guard id.hasPrefix(track.rawValue + "/") else {
                    log.append(Diagnostic("`\(id)` is in \(track.fileName), so its ID must start with `\(track.rawValue)/`", at: location))
                    continue
                }
                current = TopicDraft(id: id, title: title, line: number)
                afterRejectedHeading = false
                continue
            }
            if current == nil { checkOutsideTopics(line, at: location) }
            current?.body.append((number, line))
        }
        if fence.isOpen {
            log.append(Diagnostic("this code block is not closed", at: SourceLocation(file: file, line: fenceStart)))
        }
        finish()
        parsed.diagnostics = log.entries
        return parsed
    }

    /// Splits on `\n`, `\r\n` and `\r`, and drops a byte order mark.
    static func splitLines(_ text: String) -> [Substring] {
        var body = Substring(text)
        if body.first == "\u{FEFF}" { body = body.dropFirst() }
        return body.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
    }

    /// `ios/swift: The Swift language` → ("ios/swift", "The Swift language").
    static func parseHeading(_ heading: Substring) -> (String, String)? {
        guard let colon = heading.firstIndex(of: ":") else { return nil }
        let id = heading[..<colon]
        let title = heading[heading.index(after: colon)...].trimmingSpaces()
        guard isValidID(id), !title.isEmpty else { return nil }
        return (String(id), title)
    }

    /// `<track>/<slug>`: a known track, a slash, and a slug of lowercase ASCII letters, digits and
    /// single hyphens that starts with a letter.
    public static func isValidID<S: StringProtocol>(_ id: S) -> Bool {
        let parts = id.split(separator: "/", omittingEmptySubsequences: false)
        guard parts.count == 2, Track(rawValue: String(parts[0])) != nil else { return false }
        let slug = parts[1]
        guard let first = slug.first, first.isASCII, first.isLowercase,
              slug.count <= maxSlugLength,
              slug.last != "-", !slug.contains("--") else { return false }
        return slug.allSatisfy { $0.isASCII && ($0.isLowercase || $0.isNumber || $0 == "-") }
    }

    /// Reads `- [Title](url)` and the note after it; `nil` when the line is not a link item. URLs
    /// may contain balanced parentheses, as in `.../init(exactly:)`.
    static func parseResourceItem(_ line: Substring) -> (resource: Resource, note: Substring)? {
        guard line.hasPrefix("- [") else { return nil }
        let afterBracket = line.dropFirst(3)
        guard let close = afterBracket.range(of: "](") else { return nil }
        let title = afterBracket[..<close.lowerBound].trimmingSpaces()
        var cursor = close.upperBound
        var depth = 0
        while cursor < afterBracket.endIndex {
            let character = afterBracket[cursor]
            if character == "(" { depth += 1 }
            if character == ")" {
                if depth == 0 { break }
                depth -= 1
            }
            cursor = afterBracket.index(after: cursor)
        }
        guard cursor < afterBracket.endIndex, !title.isEmpty else { return nil }
        let url = afterBracket[close.upperBound..<cursor].trimmingSpaces()
        guard !url.isEmpty, !url.contains(" ") else { return nil }
        return (Resource(title: title, url: url), afterBracket[afterBracket.index(after: cursor)...])
    }
}
