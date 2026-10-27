import Testing
@testable import RoadmapKit

@Suite("Learning plans")
struct LearningPlanTests {
    /// foundations/programming ← ios/swift ← ios/swiftui ← ios/navigation
    ///                          ← ios/xcode ←──┘
    /// foundations/http ← ios/networking (needs ios/swift too)
    private let roadmap = Fixtures.roadmap([
        ("foundations/programming", .beginner, []),
        ("foundations/http", .beginner, ["foundations/programming"]),
        ("ios/swift", .beginner, ["foundations/programming"]),
        ("ios/xcode", .beginner, []),
        ("ios/swiftui", .beginner, ["ios/swift", "ios/xcode"]),
        ("ios/navigation", .beginner, ["ios/swiftui"]),
        ("ios/networking", .beginner, ["ios/swift", "foundations/http"]),
        ("ios/concurrency", .intermediate, ["ios/networking"]),
        ("android/kotlin", .beginner, ["foundations/programming"]),
    ])

    private func ids(_ plan: LearningPlan) -> [String] { plan.steps.map(\.id) }

    @Test("Puts every topic after its needs and breaks ties by stage, track and file order")
    func order() throws {
        let plan = try roadmap.plan(to: ["ios/concurrency", "ios/navigation"])
        #expect(ids(plan) == [
            "foundations/programming", "foundations/http", "ios/swift", "ios/xcode",
            "ios/swiftui", "ios/navigation", "ios/networking", "ios/concurrency",
        ])
        #expect(plan.goals == ["ios/concurrency", "ios/navigation"])
        #expect(plan.alreadyKnown.isEmpty)
    }

    @Test("An earlier stage comes first even when it is later in the file")
    func stageFirst() throws {
        let roadmap = Fixtures.roadmap([
            ("ios/goal", .advanced, ["ios/late", "ios/early"]),
            ("ios/late", .intermediate, []),
            ("ios/early", .beginner, []),
        ])
        #expect(ids(try roadmap.plan(to: ["ios/goal"])) == ["ios/early", "ios/late", "ios/goal"])
    }

    @Test("Skips known topics and what only they lead to")
    func known() throws {
        let plan = try roadmap.plan(to: ["ios/navigation"], knowing: ["ios/swiftui"])
        #expect(ids(plan) == ["ios/navigation"])
        #expect(plan.alreadyKnown == ["ios/swiftui"])

        // ios/swift is known, but foundations/programming is still needed by foundations/http.
        let networking = try roadmap.plan(to: ["ios/networking"], knowing: ["IOS/SWIFT "])
        #expect(ids(networking) == ["foundations/programming", "foundations/http", "ios/networking"])
        #expect(networking.alreadyKnown == ["ios/swift"])
    }

    @Test("A known goal leaves nothing to learn")
    func knownGoal() throws {
        let plan = try roadmap.plan(to: ["ios/swift"], knowing: ["ios/swift"])
        #expect(plan.steps.isEmpty)
        #expect(plan.alreadyKnown == ["ios/swift"])
    }

    @Test("Normalizes and deduplicates goals")
    func goals() throws {
        let plan = try roadmap.plan(to: [" iOS/Swift", "ios/swift"])
        #expect(plan.goals == ["ios/swift"])
        #expect(ids(plan) == ["foundations/programming", "ios/swift"])
    }

    @Test("Throws for no goals, unknown goals and loops")
    func errors() {
        #expect(throws: PlanError.noGoals) { try roadmap.plan(to: []) }
        #expect(throws: PlanError.noGoals) { try roadmap.plan(to: ["  "]) }
        #expect(throws: PlanError.unknownTopics(["ios/kotlin", "web/react"])) {
            try roadmap.plan(to: ["ios/swift", "ios/kotlin", "web/react"])
        }
        let looped = Fixtures.roadmap([
            ("ios/a", .beginner, ["ios/b"]),
            ("ios/b", .beginner, ["ios/a"]),
            ("ios/c", .beginner, ["ios/c"]),
            ("ios/d", .beginner, ["ios/a"]),
        ])
        #expect(throws: PlanError.loop(["ios/a", "ios/b", "ios/d"])) { try looped.plan(to: ["ios/d"]) }
        #expect(throws: PlanError.loop(["ios/c"])) { try looped.plan(to: ["ios/c"]) }
    }

    @Test("Needs that are not topics do not block a plan")
    func missingNeed() throws {
        let roadmap = Fixtures.roadmap([("ios/a", .beginner, ["ios/missing"])])
        #expect(ids(try roadmap.plan(to: ["ios/a"])) == ["ios/a"])
        #expect(roadmap.nextTopics(knowing: []).map(\.id) == ["ios/a"])
    }

    @Test("Next topics are the ones whose needs are all known")
    func next() {
        #expect(roadmap.nextTopics(knowing: []).map(\.id) == ["foundations/programming", "ios/xcode"])
        #expect(roadmap.nextTopics(knowing: ["foundations/programming"]).map(\.id) == [
            "foundations/http", "ios/swift", "ios/xcode", "android/kotlin",
        ])
        #expect(roadmap.nextTopics(knowing: ["foundations/programming"], track: .android).map(\.id) == ["android/kotlin"])
        let all = Set(roadmap.topics.map(\.id))
        #expect(roadmap.nextTopics(knowing: all).isEmpty)
    }

    @Test("A plan over 3,000 chained topics finishes")
    func largePlan() throws {
        let count = 3_000
        let roadmap = Fixtures.roadmap((0..<count).map { index in
            (id: "ios/t\(index)", stage: Stage.beginner, needs: index > 0 ? ["ios/t\(index - 1)"] : [])
        })
        let plan = try roadmap.plan(to: ["ios/t\(count - 1)"])
        #expect(plan.steps.count == count)
        #expect(plan.steps.first?.id == "ios/t0")
    }
}

@Suite("Mermaid graph")
struct MermaidGraphTests {
    @Test("Groups a track by stage and shows needs from other tracks")
    func render() {
        let roadmap = Fixtures.roadmap([
            ("foundations/programming", .beginner, []),
            ("ios/swift", .beginner, ["foundations/programming"]),
            ("ios/concurrency", .intermediate, ["ios/swift", "ios/swift", "ios/missing"]),
        ])
        #expect(MermaidGraph.render(roadmap, track: .ios) == """
            flowchart TD
              subgraph other["From other tracks"]
                foundations_programming["Foundations: Title of foundations/programming"]
              end
              subgraph beginner["Beginner"]
                ios_swift["Title of ios/swift"]
              end
              subgraph intermediate["Intermediate"]
                ios_concurrency["Title of ios/concurrency"]
              end
              foundations_programming --> ios_swift
              ios_swift --> ios_concurrency

            """)
    }

    @Test("Escapes text that would end a label or add markup")
    func escaping() {
        #expect(MermaidGraph.escape("Say \"hi\" <b>#1</b>\nnext") == "Say #quot;hi#quot; #lt;b#gt;#35;1#lt;/b#gt; next")
        #expect(MermaidGraph.nodeName("react-native/new-architecture") == "react_native_new_architecture")
    }
}
