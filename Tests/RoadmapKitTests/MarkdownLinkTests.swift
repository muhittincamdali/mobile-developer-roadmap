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
        "- [Docs](https://developer.apple.com/a) — ask <!@evil.example>",
        "- [Docs](https://developer.apple.com/a)\n  [Evil](https://evil.example/)",
        "- [Docs](https://developer.apple.com/a)\n\n    [evil]: https://evil.example/",
        "- [Docs](https://developer.apple.com/a)\n  <a href=//evil.example>Evil</a>",
        #"- [Docs](https://developer.apple.com/a) <img src="https:&#47&#47evil.example/x.png">"#,
        "- [Docs](https://developer.apple.com/a)\n  <source srcset=//evil.example/x.png>",
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
        "- Write to <!@evil.example>.",
        "- Write to <x'y=@evil.example>.",
        "- Write to <%@evil.example>.",
        "- Write to <{a}|b~^`#$&*/?@evil.example>.",
        "- <https://evil.example/>",
        "- <A HREF=//evil.example>Evil</A>",
        #"- Pic <img src="https:&#47&#47evil.example/x.png">"#,
        #"- Pic <img src="https:/&#47evil.example/x.png">"#,
        #"- Pic <img src="&#104ttps:&#47&#47evil.example/x.png">"#,
        #"- Pic <IMG SRC="//evil.example/x.png">"#,
        "- Pic <img\tsrc=//evil.example/x.png>",
        "- Pic <img/src=//evil.example/x.png>",
        "- Pic <img",
        "- Slashes &#47&#47 and &#x2F&#x2f spelled as numbers.",
        "- [evil]: https://evil.example/",
        "**Practice:** Compare with [the notes][evil].",
    ])
    func linkInSummary(summary: String) {
        let text = "# iOS\n\n" + Fixtures.topic("ios/links", summary: summary)
        let parsed = TopicParser.parse(text, track: .ios, file: "ios.md")
        #expect(parsed.diagnostics.map(\.message) == [Self.topicLinkProblem])
    }

    /// Inside an HTML block GitHub reads the line with an HTML parser, which accepts attribute
    /// names that inline raw HTML does not, so these rendered an image outside `SourcePolicy`.
    @Test("Rejects a line that starts an HTML block", arguments: [
        "- <div> <img 1 src=/evil-user/repo/raw/main/x.png>",
        #"- <div> <img "a" src=/evil-user/repo/raw/main/x.png>"#,
        "- <div> <img =x src=/evil-user/repo/raw/main/x.png>",
        "- <p> <img =x src=//evil.example/x.png>",
        "- <div> <a 1 href=https:evil.example>Evil</a>",
        #"- <div> <img 1 src=https:/\evil.example/x.png>"#,
        #"- <div> <img 1 src=https:\/\/evil.example/x.png>"#,
        "- <div> <img 1 src=https:/&#47evil.example/x.png>",
        "- <div> <img 1 src=https://evil&#46;example/x.png>",
        "- <div> <img 1 src=https://evil&period;example/x.png>",
        "<div> <img 1 src=/evil-user/repo/raw/main/x.png>",
        "> <div> <img 1 src=/evil-user/repo/raw/main/x.png>",
        "1. <div> <img 1 src=/evil-user/repo/raw/main/x.png>",
        "- > 2) <DIV>",
        "- <details open>",
        "- </div>",
        "- <pre>",
        "- <!-- hidden -->",
        "- <!DOCTYPE html>",
        "- <![CDATA[x]]>",
        "- <?php ?>",
        "- Pic <img 1 src=/evil-user/repo/raw/main/x.png>",
        #"- Pic <img "a" src=/evil-user/repo/raw/main/x.png>"#,
        "- Pic <img =x src=/evil-user/repo/raw/main/x.png>",
        "- `x<y @z`",
    ])
    func htmlBlockInSummary(summary: String) {
        let text = "# iOS\n\n" + Fixtures.topic("ios/links", summary: summary)
        let parsed = TopicParser.parse(text, track: .ios, file: "ios.md")
        #expect(parsed.diagnostics.map(\.message) == [Self.topicLinkProblem])
    }

    @Test("Rejects an HTML block on the line after a list item")
    func htmlBlockOnNextLine() {
        let text = "# iOS\n\n" + Fixtures.topic("ios/links", summary: "- <div>\n  <img 1 src=/evil-user/repo/raw/main/x.png>")
        let parsed = TopicParser.parse(text, track: .ios, file: "ios.md")
        #expect(parsed.diagnostics.map(\.message) == [Self.topicLinkProblem, Self.topicLinkProblem])
        #expect(parsed.diagnostics.map(\.location.line) == [7, 8])
    }

    @Test("Rejects an HTML block in a note or a continuation line", arguments: [
        "- [Docs](https://developer.apple.com/a) <div> <img 1 src=/evil-user/repo/raw/main/x.png>",
        #"- [Docs](https://developer.apple.com/a) <img "a" src=/evil-user/repo/raw/main/x.png>"#,
        "- [Docs](https://developer.apple.com/a) <img =x src=/evil-user/repo/raw/main/x.png>",
        "- [Docs](https://developer.apple.com/a)\n  <div> <img 1 src=/evil-user/repo/raw/main/x.png>",
        "- [Docs](https://developer.apple.com/a)\n  <details>",
    ])
    func htmlBlockInItem(items: String) {
        let parsed = parse(learnFrom: items)
        #expect(parsed.diagnostics.map(\.message) == [Self.topicLinkProblem])
    }

    @Test("Rejects an HTML block in the introduction")
    func htmlBlockOutsideTopics() {
        let header = "# iOS\n\n<p> <img 1 src=/evil-user/repo/raw/main/x.png>\n\n"
        let parsed = TopicParser.parse(header + Fixtures.topic("ios/links"), track: .ios, file: "ios.md")
        #expect(parsed.diagnostics.map(\.message) == [Self.fileLinkProblem])
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
            - `Array<@Sendable () -> Void>` and `<@MainActor in>`.
            - `1 < 2`, `x<y` and a quote:
            > Not a tag.
            - `Array<Int>`, `Dictionary<String, [Int]>`, `<T: Equatable>` and `<br/>`.
            - Issue #12 & #x and an `&#` without a number.
            """
        let text = "# iOS\n\nIntroduction.\n\n" + Fixtures.topic("ios/links", summary: summary, practice: "Port it to `Result<T, E>`.")
            + "## ios/notes: Notes\n\n**Stage:** beginner\n\n- Text.\n\n**Learn from:**\n\n"
            + "- [Concurrency](https://docs.swift.org/swift-book/) — the book chapter\n  that wraps onto a second line\n"
        let parsed = TopicParser.parse(text, track: .ios, file: "ios.md")
        #expect(parsed.diagnostics.isEmpty)
        #expect(parsed.topics.map(\.id) == ["ios/links", "ios/notes"])
    }

    @Test("The HTML block forms fail the lint of a whole roadmap")
    func reportedHTMLForms() throws {
        let summary = """
            - <div> <img 1 src=/evil-user/repo/raw/main/x.png>
            - <div> <img "a" src=/evil-user/repo/raw/main/x.png>
            - <div> <img =x src=/evil-user/repo/raw/main/x.png>
            """
        let folder = try TemporaryFolder()
        try folder.writeRoadmap([.engineering: "# Engineering\n\n" + Fixtures.topic("engineering/basics", summary: summary)])
        let roadmap = try Roadmap.load(from: folder.url)
        let messages = RoadmapLinter().lint(roadmap).map(\.message)
        #expect(messages == Array(repeating: "engineering/basics: links may only appear as `- [Title](https://…)` items under `**Learn from:**`", count: 3))
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
