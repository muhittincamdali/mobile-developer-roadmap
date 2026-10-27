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
