import Foundation
@testable import RoadmapKit

/// A folder under the user's temporary directory that is removed when the test ends.
final class TemporaryFolder {
    let url: URL

    init() throws {
        url = FileManager.default.temporaryDirectory
            .appendingPathComponent("RoadmapKitTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    deinit {
        try? FileManager.default.removeItem(at: url)
    }

    @discardableResult
    func write(_ relativePath: String, _ text: String) throws -> URL {
        let file = url.appendingPathComponent(relativePath)
        try FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(text.utf8).write(to: file)
        return file
    }

    /// Writes every track file, with `files` replacing the default one-topic files.
    func writeRoadmap(_ files: [Track: String] = [:]) throws {
        for track in Track.allCases {
            try write(track.fileName, files[track] ?? "# \(track.displayName)\n\n" + Fixtures.topic("\(track.rawValue)/basics"))
        }
    }
}

enum Fixtures {
    static let link = "https://developer.apple.com/documentation/swift"

    /// One topic in the roadmap format.
    static func topic(
        _ id: String,
        title: String? = nil,
        stage: String = "beginner",
        needs: [String] = [],
        summary: String = "- Something to learn.",
        practice: String? = nil,
        links: [String] = [link]
    ) -> String {
        var text = "## \(id): \(title ?? "Topic \(id)")\n\n**Stage:** \(stage)"
        if !needs.isEmpty { text += " · **Needs:** " + needs.joined(separator: ", ") }
        text += "\n\n\(summary)\n"
        if let practice { text += "\n**Practice:** \(practice)\n" }
        if !links.isEmpty {
            text += "\n**Learn from:**\n\n" + links.enumerated().map { "- [Link \($0.offset)](\($0.element))" }.joined(separator: "\n") + "\n"
        }
        return text + "\n"
    }

    /// A roadmap built in memory, every topic in the iOS track unless its ID says otherwise.
    static func roadmap(_ topics: [(id: String, stage: Stage, needs: [String])]) -> Roadmap {
        Roadmap(topics: topics.enumerated().map { index, entry in
            let track = Track(rawValue: String(entry.id.split(separator: "/").first ?? "")) ?? .ios
            return Topic(
                id: entry.id,
                track: track,
                title: "Title of \(entry.id)",
                stage: entry.stage,
                needs: entry.needs,
                summary: "Summary.",
                resources: [Resource(title: "Docs", url: link)],
                location: SourceLocation(file: track.fileName, line: index + 1)
            )
        })
    }
}
