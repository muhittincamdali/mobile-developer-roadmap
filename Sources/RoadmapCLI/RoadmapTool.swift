import Foundation
import RoadmapKit

/// What a run of `roadmap` printed and how it ended.
public struct ToolOutput: Equatable, Sendable {
    public var status: Int32
    public var standardOutput: String
    public var standardError: String
}

/// The `roadmap` command, separated from the process so tests can run it.
public struct RoadmapTool: Sendable {
    public var currentDirectory: URL

    public init(currentDirectory: URL) {
        self.currentDirectory = currentDirectory
    }

    static let usage = """
        Usage: roadmap <command> [options]

        Commands:
          tracks                 Count the topics of each track per stage
          list                   List topics (ID, stage, title)
          show <ID>              Print one topic: what to learn, practice, needs and links
          path <ID>...           The topics to learn, in order, to reach one or more goals
          next                   Topics you can start now, given what you know
          graph --track <track>  Print a track's needs as a Mermaid flowchart
          lint                   Check the roadmap files; exits with 1 on any problem

        Options:
          --roadmap <folder>     Roadmap folder (default: ./roadmap)
          --track <track>        foundations, ios, android, flutter, react-native, engineering
          --stage <stage>        beginner, intermediate or advanced
          --search <text>        Text in the ID, title or summary
          --known <IDs>          Topics you already know, comma-separated (repeatable)
          --known-file <file>    A text file with one known topic ID per line

        Examples:
          swift run roadmap path ios/swift-concurrency --known foundations/programming
          swift run roadmap next --known-file my-progress.txt --track flutter
        """

    public func run(_ arguments: [String]) -> ToolOutput {
        let parsed: Arguments
        do {
            parsed = try Arguments.parse(arguments)
        } catch {
            return usageFailure(error)
        }
        if parsed.command == .help {
            return ToolOutput(status: 0, standardOutput: Self.usage + "\n", standardError: "")
        }
        let folder = (parsed.roadmapFolder.map { URL(fileURLWithPath: $0, relativeTo: currentDirectory) }
            ?? currentDirectory.appendingPathComponent("roadmap")).standardizedFileURL
        var known = parsed.known
        if let path = parsed.knownFile {
            switch KnownTopicsFile.read(URL(fileURLWithPath: path, relativeTo: currentDirectory)) {
            case .success(let ids): known += ids
            case .failure(let error): return usageFailure(error)
            }
        }
        let roadmap: Roadmap
        do {
            roadmap = try Roadmap.load(from: folder)
        } catch {
            return ToolOutput(status: 2, standardOutput: "", standardError: "error: \(error)\n")
        }
        var printer = Printer()
        let status = execute(parsed, known: known, roadmap: roadmap, printer: &printer)
        return ToolOutput(status: status, standardOutput: printer.output, standardError: printer.errors)
    }

    private func usageFailure(_ error: UsageError) -> ToolOutput {
        ToolOutput(status: 2, standardOutput: "", standardError: Printer.terminalSafe("error: \(error.message)") + "\n\nRun `roadmap --help` for usage.\n")
    }

    private func execute(_ arguments: Arguments, known: [String], roadmap: Roadmap, printer: inout Printer) -> Int32 {
        if arguments.command == .path || arguments.command == .next {
            let unknown = roadmap.missingIDs(known)
            guard unknown.isEmpty else {
                printer.error("Unknown known topic\(unknown.count == 1 ? "" : "s"): \(unknown.prefix(10).joined(separator: ", "))\(unknown.count > 10 ? ", …" : ""). Run `roadmap list` to see the IDs.")
                return 1
            }
        }
        switch arguments.command {
        case .tracks:
            printer.tracks(roadmap)
            return 0
        case .list:
            let topics = roadmap.filter(arguments.filter)
            guard !topics.isEmpty else {
                printer.error("No topics match these filters.")
                return 1
            }
            printer.table(topics.map { [$0.id, $0.stage.rawValue, $0.title] })
            printer.line("\n\(topics.count) topic\(topics.count == 1 ? "" : "s")")
            return 0
        case .show:
            guard let id = arguments.topicIDs.first, let topic = roadmap.topic(id: id) else {
                printer.error("No topic with the ID `\(arguments.topicIDs.first ?? "")`. Run `roadmap list` to see the IDs.")
                return 1
            }
            printer.topic(topic, in: roadmap)
            return 0
        case .path:
            do {
                let plan = try roadmap.plan(to: arguments.topicIDs, knowing: Set(known))
                printer.plan(plan)
                return 0
            } catch {
                printer.error(error.description)
                return 1
            }
        case .next:
            let topics = roadmap.nextTopics(knowing: Set(known), track: arguments.filter.track)
            guard !topics.isEmpty else {
                printer.line("Nothing left to start: every topic\(arguments.filter.track.map { " in \($0.displayName)" } ?? "") is known.")
                return 0
            }
            printer.line("You can start \(topics.count) topic\(topics.count == 1 ? "" : "s") now:\n")
            printer.table(topics.map { [$0.id, $0.stage.rawValue, $0.title] })
            return 0
        case .graph:
            guard let track = arguments.filter.track else { return 2 }
            printer.line(MermaidGraph.render(roadmap, track: track), terminator: "")
            return 0
        case .lint:
            let diagnostics = RoadmapLinter().lint(roadmap)
            for diagnostic in diagnostics { printer.line(diagnostic.description) }
            let links = roadmap.topics.reduce(0) { $0 + $1.resources.count }
            printer.line("\(roadmap.topics.count) topics, \(links) links, \(diagnostics.count) problem\(diagnostics.count == 1 ? "" : "s")")
            return diagnostics.isEmpty ? 0 : 1
        case .help:
            return 0
        }
    }
}
