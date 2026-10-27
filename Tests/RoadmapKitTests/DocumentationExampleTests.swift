import Foundation
import Testing
import RoadmapKit

/// The code shown in the DocC articles, run against this repository's roadmap, with the results
/// the articles state.
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
}
