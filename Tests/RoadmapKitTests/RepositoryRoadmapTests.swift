import Foundation
import Testing
@testable import RoadmapKit

/// Checks the roadmap files of this repository, so a pull request that breaks the format, a
/// need or a count fails the test run, not only the lint step.
@Suite("This repository's roadmap")
struct RepositoryRoadmapTests {
    static let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    static let folder = root.appendingPathComponent("roadmap")

    @Test("Passes the linter")
    func lint() throws {
        let roadmap = try Roadmap.load(from: Self.folder)
        let problems = RoadmapLinter().lint(roadmap)
        #expect(problems.isEmpty, "\(problems.map(\.description).joined(separator: "\n"))")
        #expect(roadmap.topics.count >= 100)
    }

    @Test("Every track has topics, and every topic can be planned")
    func everyTopicPlans() throws {
        let roadmap = try Roadmap.load(from: Self.folder)
        for track in Track.allCases {
            #expect(roadmap.topics.contains { $0.track == track }, "\(track.rawValue) has no topics")
        }
        for topic in roadmap.topics {
            let plan = try roadmap.plan(to: [topic.id])
            #expect(plan.steps.last?.id == topic.id)
            let position = Dictionary(uniqueKeysWithValues: plan.steps.enumerated().map { ($1.id, $0) })
            for step in plan.steps {
                for need in step.needs {
                    #expect((position[need] ?? Int.max) < (position[step.id] ?? -1), "\(need) must come before \(step.id)")
                }
            }
        }
    }

    @Test("The table in roadmap/README.md shows the real topic counts")
    func readmeCounts() throws {
        let roadmap = try Roadmap.load(from: Self.folder)
        let readme = try String(contentsOf: Self.folder.appendingPathComponent("README.md"), encoding: .utf8)
        for track in Track.allCases {
            let row = try #require(readme.split(separator: "\n").first { $0.hasPrefix("| [\(track.fileName)]") })
            let count = row.split(separator: "|").last?.trimmingCharacters(in: .whitespaces)
            #expect(count == String(roadmap.topics.count { $0.track == track }), "row for \(track.fileName)")
        }
    }
}
