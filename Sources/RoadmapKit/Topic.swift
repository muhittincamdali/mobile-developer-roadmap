/// A place in a roadmap file, used for topics and diagnostics.
public struct SourceLocation: Hashable, Sendable, CustomStringConvertible {
    /// The file path as it was given to the parser, usually relative to the roadmap folder.
    public var file: String
    /// The 1-based line number; 0 stands for the file as a whole.
    public var line: Int

    public init(file: String, line: Int) {
        self.file = file
        self.line = line
    }

    public var description: String { "\(file):\(line)" }
}

/// A link to the material a topic is learned from.
public struct Resource: Hashable, Sendable {
    public var title: String
    public var url: String

    public init(title: String, url: String) {
        self.title = title
        self.url = url
    }
}

/// One thing to learn, such as `ios/swift-concurrency`.
public struct Topic: Identifiable, Hashable, Sendable {
    /// `<track>/<slug>`: lowercase, stable, used by `--known` lists and by other topics' needs.
    public var id: String
    public var track: Track
    public var title: String
    public var stage: Stage
    /// The IDs of the topics to learn first, in the order the file lists them.
    public var needs: [String]
    /// What to learn, in Markdown, without the stage line, the practice line and the resources.
    public var summary: String
    /// A small project that exercises the topic.
    public var practice: String?
    public var resources: [Resource]
    public var location: SourceLocation

    public init(
        id: String,
        track: Track,
        title: String,
        stage: Stage,
        needs: [String] = [],
        summary: String,
        practice: String? = nil,
        resources: [Resource] = [],
        location: SourceLocation
    ) {
        self.id = id
        self.track = track
        self.title = title
        self.stage = stage
        self.needs = needs
        self.summary = summary
        self.practice = practice
        self.resources = resources
        self.location = location
    }
}

/// A problem found while reading or checking the roadmap.
public struct Diagnostic: Hashable, Sendable, CustomStringConvertible {
    public var location: SourceLocation
    public var message: String

    public init(_ message: String, at location: SourceLocation) {
        self.location = location
        self.message = message
    }

    public var description: String { "\(location): \(message)" }
}
