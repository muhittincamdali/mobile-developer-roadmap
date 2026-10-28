import Foundation
import Testing
import RoadmapKit

/// The code shown in the DocC articles and the README, run against this repository's roadmap,
/// with the results the documents state.
@Suite("Documentation examples")
struct DocumentationExampleTests {
    let roadmap: Roadmap

    init() throws {
        roadmap = try Roadmap.load(from: RepositoryRoadmapTests.folder)
    }

    @Test("RoadmapKit overview: a plan to the Swift 6 language mode")
    func overview() throws {
        let plan = try roadmap.plan(to: ["ios/swift-6-mode"], knowing: ["foundations/programming", "ios/swift"])
        #expect(plan.steps.last?.id == "ios/swift-6-mode")
        #expect(plan.alreadyKnown == ["foundations/programming", "ios/swift"])
    }

    @Test("Planning a Learning Path: a known topic keeps needs that others still need")
    func knownTopicKeepsSharedNeeds() throws {
        let plan = try roadmap.plan(to: ["ios/swift-6-mode", "flutter/ios-platform"], knowing: ["foundations/programming", "ios/swift"])
        #expect(plan.alreadyKnown == ["foundations/programming", "ios/swift"])
        #expect(Set(plan.goals) == ["ios/swift-6-mode", "flutter/ios-platform"])
        #expect(!plan.steps.contains { $0.id == "ios/swift" })
    }

    @Test("Planning a Learning Path: what can be started next in React Native")
    func nextInReactNative() {
        let known: Set = ["foundations/programming", "foundations/command-line", "foundations/git"]
        #expect(roadmap.nextTopics(knowing: known, track: .reactNative).map(\.id) == ["react-native/javascript"])
    }

    @Test("Getting Started: filters and lookups")
    func gettingStarted() {
        #expect(RoadmapLinter().lint(roadmap).isEmpty)
        #expect(!roadmap.filter(TopicFilter(track: .flutter, stage: .beginner)).isEmpty)
        #expect(roadmap.topic(id: "ios/concurrency") != nil)
        #expect(roadmap.dependents(of: "ios/concurrency").map(\.id).contains("ios/swift-6-mode"))
    }

    @Test("README: the Use the library example")
    func readmeLibraryExample() throws {
        let plan = try roadmap.plan(to: ["flutter/architecture"], knowing: ["foundations/programming"])
        #expect(plan.steps.last?.id == "flutter/architecture")
        #expect(plan.alreadyKnown == ["foundations/programming"])
        #expect(!plan.steps.contains { $0.id == "foundations/programming" })
        #expect(plan.steps.allSatisfy { !$0.title.isEmpty })
    }

    /// The README shows the package line and the code tested above; the version it asks for is
    /// the latest release in the changelog, so the line resolves once that release is tagged.
    @Test("The README shows the tested library code and the latest release")
    func readmeShowsTestedCode() throws {
        func read(_ name: String) throws -> String {
            try String(contentsOf: RepositoryRoadmapTests.root.appendingPathComponent(name), encoding: .utf8)
        }
        let readme = try read("README.md").filter { !$0.isWhitespace }
        let release = try #require(try read("CHANGELOG.md").split(separator: "\n").first { $0.hasPrefix("## [") && !$0.hasPrefix("## [Unreleased]") })
        let version = try #require(release.split(separator: "]").first?.dropFirst(4))
        let lines = [
            #".package(url: "https://github.com/muhittincamdali/mobile-developer-roadmap.git", from: "\#(version)")"#,
            #".product(name: "RoadmapKit", package: "mobile-developer-roadmap")"#,
            #"let roadmap = try Roadmap.load(from: URL(fileURLWithPath: "roadmap"))"#,
            #"let plan = try roadmap.plan(to: ["flutter/architecture"], knowing: ["foundations/programming"])"#,
            "for (number, topic) in plan.steps.enumerated() {",
        ]
        for line in lines {
            #expect(readme.contains(line.filter { !$0.isWhitespace }), "README.md no longer shows \(line)")
        }
    }

    /// The tests above repeat the article code, so this checks that the articles still show those
    /// calls and results. Whitespace is ignored, so rewrapping an article does not fail it.
    @Test("The articles show the calls and results tested above", arguments: [
        ("RoadmapKit.md", #"roadmap.plan(to: ["ios/swift-6-mode"], knowing: ["foundations/programming", "ios/swift"])"#),
        ("PlanningALearningPath.md", #"roadmap.plan(to: ["ios/swift-6-mode", "flutter/ios-platform"], knowing: ["foundations/programming", "ios/swift"])"#),
        ("PlanningALearningPath.md", #"plan.alreadyKnown // ["foundations/programming", "ios/swift"]"#),
        ("PlanningALearningPath.md", #"let known: Set = ["foundations/programming", "foundations/command-line", "foundations/git"]"#),
        ("PlanningALearningPath.md", "roadmap.nextTopics(knowing: known, track: .reactNative)"),
        ("PlanningALearningPath.md", "print(topic.id) // react-native/javascript"),
        ("GettingStarted.md", "RoadmapLinter().lint(roadmap)"),
        ("GettingStarted.md", "roadmap.filter(TopicFilter(track: .flutter, stage: .beginner))"),
        ("GettingStarted.md", #"roadmap.topic(id: "ios/concurrency")"#),
        ("GettingStarted.md", #"roadmap.dependents(of: "ios/concurrency")"#),
    ])
    func articleShowsTestedCode(article: String, code: String) throws {
        let url = RepositoryRoadmapTests.root
            .appendingPathComponent("Sources/RoadmapKit/RoadmapKit.docc")
            .appendingPathComponent(article)
        let text = try String(contentsOf: url, encoding: .utf8)
        func withoutWhitespace(_ string: String) -> String {
            string.filter { !$0.isWhitespace }
        }
        #expect(withoutWhitespace(text).contains(withoutWhitespace(code)))
    }
}
