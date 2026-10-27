import Testing
@testable import RoadmapKit

/// The linter checks a resource URL as it is written, while GitHub renders the link after
/// CommonMark has decoded it. These tests pin the forms where the two would differ.
@Suite("Links as GitHub renders them")
struct MarkdownLinkTests {
    static let destinationProblem = "must be written without backslashes, `<…>`, spaces or character references such as `&#46;`: GitHub decodes them, so the link would open another address than the one checked"

    private func parse(learnFrom items: String) -> ParsedFile {
        let text = "# iOS\n\n## ios/links: Links\n\n**Stage:** beginner\n\n- Text.\n\n**Learn from:**\n\n" + items + "\n"
        return TopicParser.parse(text, track: .ios, file: "ios.md")
    }

    @Test("Rejects a destination that GitHub decodes into another address", arguments: [
        #"https://github.com/apple/\.\./evil/repo"#,
        "https://github.com/apple/&#46;&#46;/evil/repo",
        "https://github.com/apple/&#x2E;&#x2e;/evil/repo",
        "https://github.com/apple/&period;&period;/evil/repo",
        #"https://github.com/apple/..\evil/repo"#,
        "<https://github.com/apple/swift-testing>",
        "https://github.com/apple/swift\ttesting",
    ])
    func decodedDestination(url: String) {
        let parsed = parse(learnFrom: "- [Evil](\(url))\n- [Docs](\(Fixtures.link))")
        #expect(parsed.diagnostics.map(\.message) == ["ios/links: `\(url)` \(Self.destinationProblem)"])
        #expect(parsed.topics.first?.resources.map(\.url) == [Fixtures.link])
    }

    @Test("Keeps an ampersand that is not a character reference", arguments: [
        "https://developer.apple.com/search/?q=swift&type=Documentation",
        "https://developer.apple.com/search/?q=a&copy",
    ])
    func plainAmpersand(url: String) {
        let parsed = parse(learnFrom: "- [Search](\(url))")
        #expect(parsed.diagnostics.isEmpty)
        #expect(parsed.topics.first?.resources.map(\.url) == [url])
    }

    static let titleProblem = "must not contain `[`, `]`, `` ` ``, `<`, `\\` or a link, which change where GitHub ends the link"
    static let topicLinkProblem = "ios/links: links may only appear as `- [Title](https://…)` items under `**Learn from:**`"
    static let fileLinkProblem = "links may only appear as `- [Title](https://…)` items under a topic's `**Learn from:**`"

    /// Each title makes GitHub end the link text later than the parser does, so the rendered
    /// link points at the second URL while the parser read the first.
    @Test("Rejects a link title that moves the end of the link", arguments: [
        "`](https://developer.apple.com/)`",
        #"<span title="](https://developer.apple.com/)">Docs</span>"#,
        #"A\](https://developer.apple.com/) "#,
        "<https://example.com/](https://developer.apple.com/)>",
        "[x](https://developer.apple.com/)",
    ])
    func titleMovesLinkEnd(title: String) throws {
        let item = "- [\(title)](https://evil.example/)"
        let parsed = parse(learnFrom: item + "\n- [Docs](\(Fixtures.link))")
        let prefix = try #require(TopicParser.parseResourceItem(Substring(item))).resource.title
        #expect(parsed.diagnostics.map(\.message) == ["ios/links: the link title `\(prefix)` \(Self.titleProblem)"])
        #expect(parsed.topics.first?.resources.map(\.url) == [Fixtures.link])
    }

    @Test("Rejects a second link in a note or a continuation line", arguments: [
        "- [Docs](https://developer.apple.com/a) and [Evil](https://evil.example/)",
        "- [Docs](https://developer.apple.com/a) <https://evil.example/>",
        "- [Docs](https://developer.apple.com/a) — see www.evil.example",
        "- [Docs](https://developer.apple.com/a) — ask someone&#64;evil.example",
        "- [Docs](https://developer.apple.com/a)\n  [Evil](https://evil.example/)",
        "- [Docs](https://developer.apple.com/a)\n\n    [evil]: https://evil.example/",
        "- [Docs](https://developer.apple.com/a)\n  <a href=//evil.example>Evil</a>",
    ])
    func secondLinkInItem(items: String) {
        let parsed = parse(learnFrom: items)
        #expect(parsed.diagnostics.map(\.message) == [Self.topicLinkProblem])
    }

    @Test("Rejects links in the summary and the practice line", arguments: [
        "- Read [this](https://evil.example/).",
        "- ![Diagram](https://evil.example/diagram.png)",
        "- See https://evil.example/ first.",
        "- See WWW.evil.example first.",
        #"- See https\://evil.example/ first."#,
        "- Write to someone@evil.example.",
        #"- Write to someone\@evil.example."#,
        "- <https://evil.example/>",
        "- <A HREF=//evil.example>Evil</A>",
        "- [evil]: https://evil.example/",
        "**Practice:** Compare with [the notes][evil].",
    ])
    func linkInSummary(summary: String) {
        let text = "# iOS\n\n" + Fixtures.topic("ios/links", summary: summary)
        let parsed = TopicParser.parse(text, track: .ios, file: "ios.md")
        #expect(parsed.diagnostics.map(\.message) == [Self.topicLinkProblem])
    }

    @Test("Rejects links in the title, the introduction and the headings", arguments: [
        "# iOS [Evil](https://evil.example/)\n\n",
        "# iOS\n\nAn introduction with <https://evil.example/>.\n\n",
        "# iOS\n\nIntroduction.\n\n```\n[Evil](https://evil.example/)\n```\n\n",
    ])
    func linkOutsideTopics(header: String) {
        let parsed = TopicParser.parse(header + Fixtures.topic("ios/links"), track: .ios, file: "ios.md")
        #expect(parsed.diagnostics.map(\.message) == [Self.fileLinkProblem])
    }

    @Test("Rejects a link in a topic heading")
    func linkInHeading() {
        let text = "# iOS\n\n" + Fixtures.topic("ios/links", title: "Read [this](https://evil.example/)")
        let parsed = TopicParser.parse(text, track: .ios, file: "ios.md")
        #expect(parsed.diagnostics.map(\.message) == [Self.fileLinkProblem])
    }

    @Test("Keeps code, attributes and notes that are not links")
    func plainText() {
        let summary = """
            - `@MainActor`, `[weak self]`, `Task<Void, Never>` and `a < b`.
            - Q&A sessions, `dictionary[key]` and `@Observable` models.
            """
        let text = "# iOS\n\nIntroduction.\n\n" + Fixtures.topic("ios/links", summary: summary, practice: "Port it to `Result<T, E>`.")
            + "## ios/notes: Notes\n\n**Stage:** beginner\n\n- Text.\n\n**Learn from:**\n\n"
            + "- [Concurrency](https://docs.swift.org/swift-book/) — the book chapter\n  that wraps onto a second line\n"
        let parsed = TopicParser.parse(text, track: .ios, file: "ios.md")
        #expect(parsed.diagnostics.isEmpty)
        #expect(parsed.topics.map(\.id) == ["ios/links", "ios/notes"])
    }

    @Test("The three reported forms fail the lint of a whole roadmap")
    func reportedForms() throws {
        let forms = [
            #"https://github.com/apple/\.\./evil/repo"#,
            "https://github.com/apple/&#46;&#46;/evil/repo",
            "https://github.com/apple/&period;&period;/evil/repo",
        ]
        let folder = try TemporaryFolder()
        try folder.writeRoadmap([.engineering: "# Engineering\n\n" + Fixtures.topic("engineering/basics", links: forms + [Fixtures.link])])
        let roadmap = try Roadmap.load(from: folder.url)
        let messages = RoadmapLinter().lint(roadmap).map(\.message)
        #expect(messages == forms.map { "engineering/basics: `\($0)` \(Self.destinationProblem)" })
        #expect(roadmap.topic(id: "engineering/basics")?.resources.map(\.url) == [Fixtures.link])
    }
}
