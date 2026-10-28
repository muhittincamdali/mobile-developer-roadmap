import Testing
@testable import RoadmapKit

@Suite("Roadmap linter")
struct RoadmapLinterTests {
    private func messages(_ roadmap: Roadmap) -> [String] {
        RoadmapLinter().lint(roadmap).map(\.message)
    }

    @Test("A consistent roadmap has no problems")
    func clean() {
        let roadmap = Fixtures.roadmap([
            ("foundations/programming", .beginner, []),
            ("ios/swift", .beginner, ["foundations/programming"]),
            ("ios/concurrency", .intermediate, ["ios/swift", "foundations/programming"]),
        ])
        #expect(messages(roadmap).isEmpty)
    }

    @Test("Reports duplicate IDs, unknown, repeated and self needs, and later stages")
    func needs() {
        let roadmap = Fixtures.roadmap([
            ("ios/swift", .beginner, []),
            ("ios/swift", .beginner, []),
            ("ios/ui", .beginner, ["ios/ui", "ios/swift", "ios/swift", "ios/missing", "ios/advanced"]),
            ("ios/advanced", .advanced, []),
        ])
        #expect(messages(roadmap) == [
            "ios/swift is already used at ios.md:1",
            "ios/ui needs itself",
            "ios/ui lists `ios/swift` twice in its needs",
            "ios/ui needs `ios/missing`, which is not a topic",
            "ios/ui is beginner but needs ios/advanced, which is advanced",
        ])
    }

    @Test("Reports each loop of needs once")
    func loops() {
        let roadmap = Fixtures.roadmap([
            ("ios/a", .beginner, ["ios/b"]),
            ("ios/b", .beginner, ["ios/c"]),
            ("ios/c", .beginner, ["ios/a"]),
            ("ios/d", .beginner, ["ios/e"]),
            ("ios/e", .beginner, ["ios/d", "ios/a"]),
        ])
        #expect(messages(roadmap) == [
            "needs form a loop: ios/a → ios/b → ios/c → ios/a",
            "needs form a loop: ios/d → ios/e → ios/d",
        ])
    }

    @Test("A chain of 20,000 needs does not overflow the stack")
    func longChain() {
        let count = 20_000
        let topics = (0..<count).map { index in
            (id: "ios/t\(index)", stage: Stage.beginner, needs: index + 1 < count ? ["ios/t\(index + 1)"] : ["ios/t0"])
        }
        let loops = RoadmapLinter.cycles(in: Fixtures.roadmap(topics), maxCount: 10)
        #expect(loops.count == 1)
        #expect(loops.first?.count == count)
    }

    @Test("Stops collecting loops at the limit")
    func loopLimit() {
        // 300 separate two-topic loops.
        let topics = (0..<300).flatMap { index in
            [(id: "ios/a\(index)", stage: Stage.beginner, needs: ["ios/b\(index)"]),
             (id: "ios/b\(index)", stage: Stage.beginner, needs: ["ios/a\(index)"])]
        }
        #expect(RoadmapLinter.cycles(in: Fixtures.roadmap(topics), maxCount: 25).count == 25)
        let diagnostics = RoadmapLinter(limits: RoadmapLimits(maxDiagnosticsPerFile: 10)).lint(Fixtures.roadmap(topics))
        #expect(diagnostics.count == 11)
        #expect(diagnostics.last?.message == "more than 10 problems in this file; the rest were not reported")
    }

    @Test("Requires a summary and at least one resource")
    func content() {
        let topic = Topic(id: "ios/empty", track: .ios, title: "Empty", stage: .beginner, summary: " \n ", location: SourceLocation(file: "ios.md", line: 3))
        #expect(messages(Roadmap(topics: [topic])) == [
            "ios/empty has no summary of what to learn",
            "ios/empty needs a `**Learn from:**` list with at least one link",
        ])
    }

    @Test("Accepts primary sources and the listed repository paths", arguments: [
        "https://developer.apple.com/documentation/swiftui",
        "https://docs.flutter.dev/perf?tab=1#impeller",
        "https://github.com/swiftlang/swift-evolution/blob/main/proposals/0466-control-default-actor-isolation.md",
        "https://GitHub.com/apple/swift-testing",
        "https://support.google.com/googleplay/android-developer/answer/6346149",
        "https://play.google/developer-content-policy/",
    ])
    func accepted(url: String) {
        #expect(SourcePolicy.primarySources.problem(with: url) == nil)
    }

    @Test("Rejects other links", arguments: [
        ("http://developer.apple.com/documentation", "must be an https URL"),
        ("developer.apple.com/documentation", "must be an https URL"),
        ("https://", "must be an https URL"),
        ("javascript:alert(1)", "must be an https URL"),
        ("https://user:secret@developer.apple.com/", "must not contain a user name or password"),
        ("https://developer.apple.com/?utm_source=roadmap", "must not carry tracking parameters (utm_…)"),
        ("https://developer.apple.com:8443/", "must not name a port"),
        ("https://github.com/apple/../evil/repo", "must not contain `.` or `..` path segments"),
        ("https://github.com/apple/%2e%2e/evil/repo", "must not contain `.` or `..` path segments"),
        ("https://github.com/apple/%2E./evil/repo", "must not contain `.` or `..` path segments"),
        ("https://github.com/apple/./swift-testing", "must not contain `.` or `..` path segments"),
        ("https://developer.apple.com/documentation/..", "must not contain `.` or `..` path segments"),
        (#"https://github.com/apple/..\evil/repo"#, "must not contain a backslash, which browsers read as `/`"),
        (#"https://github.com\@evil.example/apple/"#, "must not contain a backslash, which browsers read as `/`"),
        ("https://medium.com/some-post", "is not a primary source (see SourcePolicy in Sources/RoadmapKit/SourcePolicy.swift)"),
        ("https://evil.developer.apple.com/", "is not a primary source (see SourcePolicy in Sources/RoadmapKit/SourcePolicy.swift)"),
        ("https://developer.apple.com.evil.example/", "is not a primary source (see SourcePolicy in Sources/RoadmapKit/SourcePolicy.swift)"),
        ("https://github.com/someone/my-own-library", "is not a primary source (see SourcePolicy in Sources/RoadmapKit/SourcePolicy.swift)"),
        ("https://github.com/apple-fan/swift", "is not a primary source (see SourcePolicy in Sources/RoadmapKit/SourcePolicy.swift)"),
        ("https://github.com/facebook/react-native-fork", "is not a primary source (see SourcePolicy in Sources/RoadmapKit/SourcePolicy.swift)"),
        ("https://support.google.com/mail/answer/1", "is not a primary source (see SourcePolicy in Sources/RoadmapKit/SourcePolicy.swift)"),
        ("https://play.google/developer-content-policy-archive/", "is not a primary source (see SourcePolicy in Sources/RoadmapKit/SourcePolicy.swift)"),
    ])
    func rejected(url: String, problem: String) {
        #expect(SourcePolicy.primarySources.problem(with: url) == problem)
    }

    @Test("Reports a link that is listed twice and a link outside the policy")
    func resourceProblems() {
        let topic = Topic(
            id: "ios/links",
            track: .ios,
            title: "Links",
            stage: .beginner,
            summary: "Text.",
            resources: [
                Resource(title: "A", url: Fixtures.link),
                Resource(title: "B", url: Fixtures.link),
                Resource(title: "C", url: "https://example.com/"),
            ],
            location: SourceLocation(file: "ios.md", line: 1)
        )
        #expect(messages(Roadmap(topics: [topic])) == [
            "ios/links lists `\(Fixtures.link)` twice",
            "ios/links: `https://example.com/` is not a primary source (see SourcePolicy in Sources/RoadmapKit/SourcePolicy.swift)",
        ])
    }

    @Test("Loader and linter problems share one limit per file")
    func sharedLimit() throws {
        let folder = try TemporaryFolder()
        let bad = (0..<30).map { "## ios/topic-\($0): Missing stage\n\nText.\n" }.joined(separator: "\n")
        try folder.writeRoadmap([.ios: "# iOS\n\n" + bad])
        let roadmap = try Roadmap.load(from: folder.url, limits: RoadmapLimits(maxDiagnosticsPerFile: 5))
        let diagnostics = RoadmapLinter(limits: RoadmapLimits(maxDiagnosticsPerFile: 5)).lint(roadmap)
        #expect(diagnostics.filter { $0.location.file == "ios.md" }.count == 6)
    }
}
