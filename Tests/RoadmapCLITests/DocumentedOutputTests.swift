import Foundation
import RoadmapKit
import Testing
@testable import RoadmapCLI

/// Runs every `$ swift run roadmap …` example in the README and the DocC articles against the
/// repository's roadmap and compares the output, so the documentation cannot drift from the tool.
@Suite("Documented output")
struct DocumentedOutputTests {
    static let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

    static let documents = [
        "README.md",
        "Sources/RoadmapKit/RoadmapKit.docc/GettingStarted.md",
    ]

    /// The `console` blocks of a document: the command after `$ swift run roadmap ` and the
    /// lines printed below it.
    static func examples(in text: String) -> [(arguments: [String], output: String)] {
        var examples: [(arguments: [String], output: String)] = []
        var lines: [Substring]?
        for line in text.split(separator: "\n", omittingEmptySubsequences: false) {
            if line.hasPrefix("```console") {
                lines = []
            } else if line.hasPrefix("```"), let block = lines {
                lines = nil
                guard let command = block.first, command.hasPrefix("$ swift run roadmap ") else { continue }
                let arguments = command.dropFirst("$ swift run roadmap ".count).split(separator: " ").map(String.init)
                examples.append((arguments, block.dropFirst().joined(separator: "\n") + "\n"))
            } else {
                lines?.append(line)
            }
        }
        return examples
    }

    @Test("Each documented command prints what the document shows", arguments: documents)
    func documentedOutput(document: String) throws {
        let text = try String(contentsOf: Self.root.appendingPathComponent(document), encoding: .utf8)
        let examples = Self.examples(in: text)
        #expect(!examples.isEmpty, "\(document) has no `$ swift run roadmap` example")
        for example in examples {
            let output = RoadmapTool(currentDirectory: Self.root).run(example.arguments)
            #expect(output.status == 0, "\(example.arguments)")
            #expect(output.standardOutput == example.output, "\(document): roadmap \(example.arguments.joined(separator: " "))")
        }
    }

    @Test("The topic quoted in the README is the one in roadmap/ios.md")
    func quotedTopic() throws {
        let readme = try String(contentsOf: Self.root.appendingPathComponent("README.md"), encoding: .utf8)
        let ios = try String(contentsOf: Self.root.appendingPathComponent("roadmap/ios.md"), encoding: .utf8)
        let start = try #require(readme.range(of: "```markdown\n"))
        let end = try #require(readme.range(of: "\n```", range: start.upperBound..<readme.endIndex))
        let quoted = String(readme[start.upperBound..<end.lowerBound])
        #expect(quoted.hasPrefix("## ios/"))
        #expect(ios.contains(quoted + "\n"))
    }

    @Test("The README track table shows the real counts")
    func trackTable() throws {
        let readme = try String(contentsOf: Self.root.appendingPathComponent("README.md"), encoding: .utf8)
        let roadmap = try Roadmap.load(from: Self.root.appendingPathComponent("roadmap"))
        for track in Track.allCases {
            let row = try #require(readme.split(separator: "\n").first { $0.hasPrefix("| [\(track.displayName)](roadmap/\(track.fileName))") })
            let cells = row.split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }
            let expected = [roadmap.topics.count { $0.track == track }] + Stage.allCases.map { roadmap.count(in: track, stage: $0) }
            #expect(cells.suffix(4) == expected.map(String.init), "\(track.displayName) row")
        }
        let links = roadmap.topics.reduce(0) { $0 + $1.resources.count }
        #expect(readme.contains("\(links) links to official documentation"))
        #expect(readme.contains("It\nhas \(roadmap.topics.count) topics.") || readme.contains("It has \(roadmap.topics.count) topics."))
    }
}
