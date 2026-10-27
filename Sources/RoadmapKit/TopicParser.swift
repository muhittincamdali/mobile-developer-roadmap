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
                current?.body.append((number, line))
                continue
            }
            if line.hasPrefix("# ") {
                if parsed.title == nil && current == nil && parsed.topics.isEmpty {
                    parsed.title = line.dropFirst(2).trimmingSpaces()
                } else {
                    log.append(Diagnostic("only one `# ` heading is allowed, before the first topic", at: location))
                }
                continue
            }
            if line.hasPrefix("## ") {
                finish()
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
                continue
            }
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

    /// Reads `- [Title](url)` with an optional note after it; `nil` when the line is not a link
    /// item. URLs may contain balanced parentheses, as in `.../init(exactly:)`.
    static func parseResourceItem(_ line: Substring) -> Resource? {
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
        return Resource(title: title, url: url)
    }
}

/// The lines of a topic until the next heading.
private struct TopicDraft {
    var id: String
    var title: String
    var line: Int
    var body: [(Int, Substring)] = []

    func build(track: Track, file: String, limits: RoadmapLimits, diagnostics: inout DiagnosticLog) -> Topic? {
        let headingLocation = SourceLocation(file: file, line: line)
        guard let metaIndex = body.firstIndex(where: { !$0.1.allSatisfy(\.isWhitespace) }) else {
            diagnostics.append(Diagnostic("\(id) has no stage line", at: headingLocation))
            return nil
        }
        let (metaLine, metaText) = body[metaIndex]
        let metaLocation = SourceLocation(file: file, line: metaLine)
        guard let (stage, needs) = parseMeta(metaText, location: metaLocation, limits: limits, diagnostics: &diagnostics) else {
            return nil
        }

        var summary: [Substring] = []
        var practice: String?
        var resources: [Resource] = []
        var inResources = false
        var fence = FenceTracker()
        for (number, text) in body[(metaIndex + 1)...] {
            let location = SourceLocation(file: file, line: number)
            if fence.consume(text) {
                if inResources {
                    diagnostics.append(Diagnostic("\(id): `**Learn from:**` must be the last part of a topic", at: location))
                    return nil
                }
                summary.append(text)
                continue
            }
            if inResources {
                if text.allSatisfy(\.isWhitespace) || text.hasPrefix("  ") { continue }
                guard let resource = TopicParser.parseResourceItem(text) else {
                    diagnostics.append(Diagnostic("\(id): after `**Learn from:**` only `- [Title](https://…)` items may follow", at: location))
                    continue
                }
                guard resources.count < limits.maxResourcesPerTopic else {
                    diagnostics.append(Diagnostic("\(id) lists more than \(limits.maxResourcesPerTopic) resources", at: location))
                    continue
                }
                resources.append(resource)
                continue
            }
            if text.trimmingSpaces() == TopicParser.resourcesLine {
                inResources = true
                continue
            }
            if text.hasPrefix(TopicParser.practicePrefix) {
                guard practice == nil else {
                    diagnostics.append(Diagnostic("\(id) has more than one practice line", at: location))
                    continue
                }
                practice = text.dropFirst(TopicParser.practicePrefix.count).trimmingSpaces()
                continue
            }
            summary.append(text)
        }
        if fence.isOpen {
            return nil
        }

        return Topic(
            id: id,
            track: track,
            title: title,
            stage: stage,
            needs: needs,
            summary: Self.trimBlankLines(summary),
            practice: practice?.isEmpty == false ? practice : nil,
            resources: resources,
            location: headingLocation
        )
    }

    /// Joins the lines without the blank lines at the start and the end. Slicing instead of
    /// removing one line at a time keeps a topic followed by many blank lines linear.
    private static func trimBlankLines(_ lines: [Substring]) -> String {
        let isBlank: (Substring) -> Bool = { $0.allSatisfy(\.isWhitespace) }
        guard let first = lines.firstIndex(where: { !isBlank($0) }),
              let last = lines.lastIndex(where: { !isBlank($0) }) else { return "" }
        return lines[first...last].joined(separator: "\n")
    }

    /// `**Stage:** intermediate · **Needs:** ios/swift, foundations/git`.
    private func parseMeta(_ text: Substring, location: SourceLocation, limits: RoadmapLimits, diagnostics: inout DiagnosticLog) -> (Stage, [String])? {
        let parts = text.trimmingSpaces().components(separatedBy: TopicParser.separator)
        guard let first = parts.first, first.hasPrefix(TopicParser.stagePrefix) else {
            diagnostics.append(Diagnostic("\(id) must start with `**Stage:** beginner`, `intermediate` or `advanced`", at: location))
            return nil
        }
        let stageName = first.dropFirst(TopicParser.stagePrefix.count)
        guard let stage = Stage(rawValue: String(stageName)) else {
            diagnostics.append(Diagnostic("\(id) has an unknown stage `\(stageName)`; use beginner, intermediate or advanced", at: location))
            return nil
        }
        guard parts.count > 1 else { return (stage, []) }
        guard parts.count == 2, parts[1].hasPrefix(TopicParser.needsPrefix) else {
            diagnostics.append(Diagnostic("\(id): after the stage only `· **Needs:** track/topic, …` may follow", at: location))
            return nil
        }
        let names = parts[1].dropFirst(TopicParser.needsPrefix.count).split(separator: ",")
        guard names.count <= limits.maxNeedsPerTopic else {
            diagnostics.append(Diagnostic("\(id) needs more than \(limits.maxNeedsPerTopic) topics", at: location))
            return nil
        }
        var needs: [String] = []
        for name in names.map({ $0.trimmingSpaces() }) {
            guard TopicParser.isValidID(name) else {
                diagnostics.append(Diagnostic("\(id): `\(name)` is not a topic ID such as `ios/swift`", at: location))
                return nil
            }
            needs.append(name)
        }
        return (stage, needs)
    }
}

/// The problems of one file: at most `limit`, then one line that says the rest were not
/// reported, so a file of the same mistake on every line cannot fill memory with diagnostics.
struct DiagnosticLog {
    let limit: Int
    private(set) var entries: [Diagnostic] = []
    private var isFull = false

    init(limit: Int) {
        self.limit = max(limit, 0)
    }

    mutating func append(_ diagnostic: Diagnostic) {
        guard !isFull else { return }
        guard entries.count < limit else {
            isFull = true
            entries.append(Self.overflow(limit: limit, at: diagnostic.location))
            return
        }
        entries.append(diagnostic)
    }

    static func overflow(limit: Int, at location: SourceLocation) -> Diagnostic {
        Diagnostic("more than \(limit) problems in this file; the rest were not reported", at: location)
    }
}

/// Follows fenced code blocks (three or more backticks or tildes) so that headings and the lines
/// inside code are read as code.
struct FenceTracker {
    private var open: Substring?

    var isOpen: Bool { open != nil }

    /// Returns `true` when the line opens, closes or is inside a code block.
    mutating func consume(_ line: Substring) -> Bool {
        let trimmed = line.drop { $0 == " " }
        guard let first = trimmed.first, first == "`" || first == "~" else { return isOpen }
        let run = trimmed.prefix { $0 == first }
        guard run.count >= 3 else { return isOpen }
        guard let opener = open else {
            open = run
            return true
        }
        // A closing fence uses the same character, is at least as long and has no info string.
        if opener.first == first && run.count >= opener.count && trimmed.dropFirst(run.count).allSatisfy(\.isWhitespace) {
            open = nil
        }
        return true
    }
}

extension StringProtocol {
    func trimmingSpaces() -> String {
        String(drop(while: \.isWhitespace).reversed().drop(while: \.isWhitespace).reversed())
    }
}
