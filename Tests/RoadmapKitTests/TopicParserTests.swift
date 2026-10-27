import Testing
@testable import RoadmapKit

@Suite("Topic parser")
struct TopicParserTests {
    @Test("Reads every part of a topic")
    func readsTopic() throws {
        let text = """
            # iOS

            Introduction.

            ## ios/concurrency: Swift concurrency

            **Stage:** intermediate · **Needs:** ios/networking, foundations/async

            - Tasks and actors.

            ```swift
            ## not a heading
            **Learn from:** not the resource list
            ```

            **Practice:** Download images in parallel.

            **Learn from:**

            - [Concurrency](https://docs.swift.org/swift-book/concurrency/) — the book chapter
            - [Int(exactly:)](https://developer.apple.com/documentation/swift/int/init(exactly:)-5k3ls)
            """
        let parsed = TopicParser.parse(text, track: .ios, file: "ios.md")
        #expect(parsed.diagnostics.isEmpty)
        #expect(parsed.title == "iOS")
        let topic = try #require(parsed.topics.first)
        #expect(topic.id == "ios/concurrency")
        #expect(topic.title == "Swift concurrency")
        #expect(topic.stage == .intermediate)
        #expect(topic.needs == ["ios/networking", "foundations/async"])
        #expect(topic.practice == "Download images in parallel.")
        #expect(topic.summary.hasPrefix("- Tasks and actors."))
        #expect(topic.summary.contains("## not a heading"), "lines inside code stay in the summary")
        #expect(topic.resources == [
            Resource(title: "Concurrency", url: "https://docs.swift.org/swift-book/concurrency/"),
            Resource(title: "Int(exactly:)", url: "https://developer.apple.com/documentation/swift/int/init(exactly:)-5k3ls"),
        ])
        #expect(topic.location == SourceLocation(file: "ios.md", line: 5))
    }

    @Test("Accepts CRLF line ends and a byte order mark")
    func lineEnds() {
        let text = "\u{FEFF}# iOS\r\n\r\n" + Fixtures.topic("ios/swift").replacingOccurrences(of: "\n", with: "\r\n")
        let parsed = TopicParser.parse(text, track: .ios, file: "ios.md")
        #expect(parsed.diagnostics.isEmpty)
        #expect(parsed.title == "iOS")
        #expect(parsed.topics.map(\.id) == ["ios/swift"])
    }

    @Test("Valid and invalid IDs", arguments: [
        ("ios/swift", true),
        ("react-native/new-architecture", true),
        ("ios/a1", true),
        ("ios/" + String(repeating: "a", count: 48), true),
        ("ios/" + String(repeating: "a", count: 49), false),
        ("ios/Swift", false),
        ("ios/1swift", false),
        ("ios/swift-", false),
        ("ios/swift--ui", false),
        ("ios/swift_ui", false),
        ("ios/", false),
        ("ios", false),
        ("ios/swift/ui", false),
        ("web/react", false),
        ("IOS/swift", false),
        ("ios/swıft", false),
        ("ios/ swift", false),
    ])
    func ids(id: String, valid: Bool) {
        #expect(TopicParser.isValidID(id) == valid)
    }

    @Test("Reports headings and stage lines it cannot read")
    func formatProblems() {
        let text = """
            ## ios/early: Before the title

            **Stage:** beginner

            Text.

            **Learn from:**

            - [Docs](https://developer.apple.com/)

            # A second title

            ## not an id: Title

            ## android/wrong-track: In the iOS file

            ## ios/no-stage: Missing stage

            Text first.

            ## ios/bad-stage: Unknown stage

            **Stage:** expert

            ## ios/bad-needs: Needs with a typo

            **Stage:** beginner · **Needs:** ios/Swift

            ## ios/extra-meta: Something after needs

            **Stage:** beginner · **Needs:** ios/swift · **Level:** high

            ## ios/empty: Nothing below
            """
        let parsed = TopicParser.parse(text, track: .ios, file: "ios.md")
        let messages = parsed.diagnostics.map(\.message)
        #expect(parsed.topics.map(\.id) == ["ios/early"])
        #expect(messages.contains("the file needs a `# Title` heading before its first topic"))
        #expect(messages.contains("only one `# ` heading is allowed, before the first topic"))
        #expect(messages.contains("topic headings look like `## ios/topic-name: Title`"))
        #expect(messages.contains("`android/wrong-track` is in ios.md, so its ID must start with `ios/`"))
        #expect(messages.contains("ios/no-stage must start with `**Stage:** beginner`, `intermediate` or `advanced`"))
        #expect(messages.contains("ios/bad-stage has an unknown stage `expert`; use beginner, intermediate or advanced"))
        #expect(messages.contains("ios/bad-needs: `ios/Swift` is not a topic ID such as `ios/swift`"))
        #expect(messages.contains("ios/extra-meta: after the stage only `· **Needs:** track/topic, …` may follow"))
        #expect(messages.contains("ios/empty has no stage line"))
    }

    @Test("Only link items may follow the resource line")
    func resourceList() {
        let text = "# iOS\n\n" + Fixtures.topic("ios/swift") + """
            Some prose after the list.
            - [No URL]()
            - [Spaces](https://developer.apple.com/a b)
            - [Unclosed](https://developer.apple.com/a
            - [Good](https://developer.apple.com/b) — with a note
              that wraps onto a second line
            """
        let parsed = TopicParser.parse(text, track: .ios, file: "ios.md")
        #expect(parsed.diagnostics.count == 4)
        #expect(parsed.diagnostics.allSatisfy { $0.message == "ios/swift: after `**Learn from:**` only `- [Title](https://…)` items may follow" })
        #expect(parsed.topics.first?.resources.map(\.url) == [Fixtures.link, "https://developer.apple.com/b"])
    }

    @Test("A code block after the resources ends the topic with a problem")
    func codeAfterResources() {
        let text = "# iOS\n\n" + Fixtures.topic("ios/swift") + "```\ncode\n```\n"
        let parsed = TopicParser.parse(text, track: .ios, file: "ios.md")
        #expect(parsed.topics.isEmpty)
        #expect(parsed.diagnostics.map(\.message) == ["ios/swift: `**Learn from:**` must be the last part of a topic"])
    }

    @Test("Reports a second practice line and an unclosed code block")
    func practiceAndFence() {
        let twice = "# iOS\n\n" + Fixtures.topic("ios/swift", summary: "Text.\n\n**Practice:** One.\n\n**Practice:** Two.")
        let parsedTwice = TopicParser.parse(twice, track: .ios, file: "ios.md")
        #expect(parsedTwice.diagnostics.map(\.message) == ["ios/swift has more than one practice line"])
        #expect(parsedTwice.topics.first?.practice == "One.")

        let open = "# iOS\n\n## ios/swift: Swift\n\n**Stage:** beginner\n\n```swift\nlet a = 1\n"
        let parsedOpen = TopicParser.parse(open, track: .ios, file: "ios.md")
        #expect(parsedOpen.topics.isEmpty)
        #expect(parsedOpen.diagnostics.map(\.message) == ["this code block is not closed"])
        #expect(parsedOpen.diagnostics.first?.location.line == 7, "the line that opens the block")
    }

    @Test("Stops after the topic limit")
    func topicLimit() {
        let text = "# iOS\n\n" + (1...5).map { Fixtures.topic("ios/topic-\($0)") }.joined()
        let parsed = TopicParser.parse(text, track: .ios, file: "ios.md", limits: RoadmapLimits(maxTopicsPerFile: 3))
        #expect(parsed.topics.count == 3)
        #expect(parsed.diagnostics.map(\.message) == ["more than 3 topics in one file; the rest were not read"])
    }

    @Test("Rejects a title over 120 characters")
    func titleLength() {
        let longest = String(repeating: "t", count: 120)
        let text = "# iOS\n\n" + Fixtures.topic("ios/ok", title: longest) + Fixtures.topic("ios/long", title: longest + "t")
        let parsed = TopicParser.parse(text, track: .ios, file: "ios.md")
        #expect(parsed.topics.map(\.id) == ["ios/ok"])
        #expect(parsed.diagnostics.map(\.message) == ["ios/long: the title is longer than 120 characters"])
    }

    @Test("Caps the problems of one file")
    func diagnosticLimit() {
        let text = String(repeating: "# again\n", count: 20_000)
        let parsed = TopicParser.parse(text, track: .ios, file: "ios.md", limits: RoadmapLimits(maxDiagnosticsPerFile: 50))
        #expect(parsed.diagnostics.count == 51)
        #expect(parsed.diagnostics.last?.message == "more than 50 problems in this file; the rest were not reported")
    }

    @Test("Rejects too many needs and too many resources")
    func perTopicLimits() {
        let limits = RoadmapLimits(maxNeedsPerTopic: 2, maxResourcesPerTopic: 2)
        let needs = "# iOS\n\n" + Fixtures.topic("ios/swift", needs: ["ios/a", "ios/b", "ios/c"])
        #expect(TopicParser.parse(needs, track: .ios, file: "ios.md", limits: limits).diagnostics.map(\.message) == ["ios/swift needs more than 2 topics"])

        let links = (1...3).map { "https://developer.apple.com/\($0)" }
        let resources = "# iOS\n\n" + Fixtures.topic("ios/swift", links: links)
        let parsed = TopicParser.parse(resources, track: .ios, file: "ios.md", limits: limits)
        #expect(parsed.diagnostics.map(\.message) == ["ios/swift lists more than 2 resources"])
        #expect(parsed.topics.first?.resources.count == 2)
    }

    @Test("A blank-line flood after a topic is parsed in linear time")
    func manyBlankLines() {
        let text = "# iOS\n\n## ios/swift: Swift\n\n**Stage:** beginner\n\nText." + String(repeating: "\n", count: 200_000)
        let parsed = TopicParser.parse(text, track: .ios, file: "ios.md")
        #expect(parsed.topics.first?.summary == "Text.")
    }
}
