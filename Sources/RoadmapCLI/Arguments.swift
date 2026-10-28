import RoadmapKit

/// A command line that could not be understood; exits with status 2.
struct UsageError: Error, Equatable {
    var message: String
}

/// The parsed command line of `roadmap`.
struct Arguments: Equatable {
    enum Command: String, CaseIterable {
        case tracks, list, show, path, next, graph, lint, help
    }

    /// Most goal topics in one `path` command.
    static let maxGoals = 32
    /// Most IDs given with `--known` in total.
    static let maxKnownOnCommandLine = 1_000

    var command: Command
    /// Topic IDs: one for `show`, the goals for `path`.
    var topicIDs: [String] = []
    var roadmapFolder: String?
    var filter = TopicFilter()
    var known: [String] = []
    var knownFile: String?

    /// Options that take a value, and the commands that accept each of them.
    private static let valueOptions: [String: Set<Command>] = [
        "--roadmap": Set(Command.allCases),
        "--track": [.list, .next, .graph],
        "--stage": [.list],
        "--search": [.list],
        "--known": [.path, .next],
        "--known-file": [.path, .next],
    ]

    static func parse(_ arguments: [String]) throws(UsageError) -> Arguments {
        guard let first = arguments.first else { return Arguments(command: .help) }
        if first == "--help" || first == "-h" { return Arguments(command: .help) }
        guard let command = Command(rawValue: first) else {
            throw UsageError(message: "unknown command `\(first)`")
        }
        var result = Arguments(command: command)
        var rest = arguments.dropFirst()

        while let argument = rest.popFirst() {
            if argument == "--help" || argument == "-h" {
                return Arguments(command: .help)
            }
            if let allowed = valueOptions[argument] {
                guard allowed.contains(command) else {
                    throw UsageError(message: "\(argument) does not work with `\(command.rawValue)`")
                }
                guard let value = rest.popFirst(), !value.hasPrefix("--") else {
                    throw UsageError(message: "\(argument) needs a value")
                }
                try result.set(argument, to: value)
                continue
            }
            if argument.hasPrefix("-") {
                throw UsageError(message: "unknown option `\(argument)`")
            }
            try result.addTopicID(argument)
        }
        try result.checkRequiredValues()
        return result
    }

    private mutating func addTopicID(_ argument: String) throws(UsageError) {
        switch command {
        case .show where topicIDs.isEmpty:
            topicIDs.append(argument)
        case .path:
            guard topicIDs.count < Self.maxGoals else {
                throw UsageError(message: "`path` takes at most \(Self.maxGoals) goal topics")
            }
            topicIDs.append(argument)
        default:
            throw UsageError(message: "unexpected argument `\(argument)`")
        }
    }

    private func checkRequiredValues() throws(UsageError) {
        switch command {
        case .show where topicIDs.isEmpty:
            throw UsageError(message: "`show` needs a topic ID, such as `roadmap show ios/swift`")
        case .path where topicIDs.isEmpty:
            throw UsageError(message: "`path` needs one or more goal topics, such as `roadmap path ios/swift-concurrency`")
        case .graph where filter.track == nil:
            throw UsageError(message: "`graph` needs --track, such as `roadmap graph --track ios`")
        default:
            break
        }
    }

    private mutating func set(_ option: String, to value: String) throws(UsageError) {
        switch option {
        case "--roadmap":
            roadmapFolder = value
        case "--track":
            guard let track = Track(rawValue: value.lowercased()) else {
                throw UsageError(message: "unknown track `\(value)`; use \(Track.allCases.map(\.rawValue).joined(separator: ", "))")
            }
            filter.track = track
        case "--stage":
            guard let stage = Stage(rawValue: value.lowercased()) else {
                throw UsageError(message: "unknown stage `\(value)`; use beginner, intermediate or advanced")
            }
            filter.stage = stage
        case "--search":
            filter.search = value
        case "--known":
            let ids = value.split(separator: ",").map { Roadmap.normalizedID(String($0)) }.filter { !$0.isEmpty }
            guard known.count + ids.count <= Self.maxKnownOnCommandLine else {
                throw UsageError(message: "--known takes at most \(Self.maxKnownOnCommandLine) IDs; use --known-file for more")
            }
            known += ids
        case "--known-file":
            guard knownFile == nil else { throw UsageError(message: "--known-file can be given once") }
            knownFile = value
        default:
            throw UsageError(message: "unknown option `\(option)`")
        }
    }
}
