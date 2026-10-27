import Foundation

/// Upper bounds that keep a damaged or hostile roadmap folder from using unbounded memory or time.
public struct RoadmapLimits: Sendable, Equatable {
    /// Largest roadmap file that is read, in bytes.
    public var maxFileBytes: Int
    /// Most entries looked at in the roadmap folder, track files and skipped files together.
    public var maxFolderEntries: Int
    /// Most topics read from one file.
    public var maxTopicsPerFile: Int
    /// Most IDs on one `**Needs:**` line.
    public var maxNeedsPerTopic: Int
    /// Most links under one `**Learn from:**` line.
    public var maxResourcesPerTopic: Int
    /// Most problems reported for one file; one more line says that the rest were not reported.
    public var maxDiagnosticsPerFile: Int

    public init(
        maxFileBytes: Int = 1 << 20,
        maxFolderEntries: Int = 64,
        maxTopicsPerFile: Int = 500,
        maxNeedsPerTopic: Int = 32,
        maxResourcesPerTopic: Int = 16,
        maxDiagnosticsPerFile: Int = 100
    ) {
        self.maxFileBytes = maxFileBytes
        self.maxFolderEntries = maxFolderEntries
        self.maxTopicsPerFile = maxTopicsPerFile
        self.maxNeedsPerTopic = maxNeedsPerTopic
        self.maxResourcesPerTopic = maxResourcesPerTopic
        self.maxDiagnosticsPerFile = maxDiagnosticsPerFile
    }

    /// 1 MiB per file, 64 folder entries, 500 topics per file, 32 needs and 16 resources per
    /// topic, 100 problems per file: far above what the roadmap uses.
    public static let `default` = RoadmapLimits()
}

/// Why a roadmap folder could not be read at all.
public enum RoadmapError: Error, Equatable, CustomStringConvertible {
    case folderNotFound(String)

    public var description: String {
        switch self {
        case .folderNotFound(let path):
            "No roadmap folder at \(path). Run the command from the repository root or pass --roadmap <folder>."
        }
    }
}

/// Every topic of every track, with the problems found while reading them.
public struct Roadmap: Sendable {
    /// Topics in track order, then file order.
    public private(set) var topics: [Topic]
    /// File-level and format problems found by ``load(from:limits:)``; ``RoadmapLinter`` adds
    /// the checks across topics.
    public private(set) var diagnostics: [Diagnostic]
    /// Position of each ID in ``topics``.
    let indexByID: [String: Int]

    public init(topics: [Topic], diagnostics: [Diagnostic] = []) {
        self.topics = topics
        self.diagnostics = diagnostics
        // The first topic wins when an ID is used twice; the linter reports the second one.
        indexByID = Dictionary(topics.enumerated().map { ($1.id, $0) }, uniquingKeysWith: { first, _ in first })
    }

    /// The file names the folder may contain besides the track files.
    static let otherAllowedFiles: Set<String> = ["README.md"]

    /// Reads `<folder>/<track>.md` for every ``Track``, in track order.
    ///
    /// A missing track file, a symbolic link, a file over ``RoadmapLimits/maxFileBytes`` and any
    /// other Markdown file in the folder are reported as diagnostics. The folder listing stops
    /// after ``RoadmapLimits/maxFolderEntries`` entries.
    public static func load(from folder: URL, limits: RoadmapLimits = .default) throws -> Roadmap {
        let manager = FileManager.default
        var isDirectory: ObjCBool = false
        guard manager.fileExists(atPath: folder.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            throw RoadmapError.folderNotFound(folder.path)
        }
        var topics: [Topic] = []
        var diagnostics: [Diagnostic] = []
        let keys: [URLResourceKey] = [.isSymbolicLinkKey, .isRegularFileKey]
        let entries = try manager.contentsOfDirectory(at: folder, includingPropertiesForKeys: keys, options: [.skipsHiddenFiles])
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
        if entries.count > limits.maxFolderEntries {
            diagnostics.append(Diagnostic("the folder has more than \(limits.maxFolderEntries) entries; only the track files were read", at: SourceLocation(file: folder.lastPathComponent, line: 0)))
        }
        let trackFiles = Set(Track.allCases.map(\.fileName))
        for entry in entries.prefix(limits.maxFolderEntries) where entry.pathExtension == "md" {
            let name = entry.lastPathComponent
            if !trackFiles.contains(name) && !otherAllowedFiles.contains(name) {
                diagnostics.append(Diagnostic("`\(name)` is not a track file (\(Track.allCases.map(\.fileName).joined(separator: ", "))); it was not read", at: SourceLocation(file: name, line: 0)))
            }
        }

        for track in Track.allCases {
            let file = folder.appendingPathComponent(track.fileName)
            let location = SourceLocation(file: track.fileName, line: 0)
            guard manager.fileExists(atPath: file.path) else {
                diagnostics.append(Diagnostic("missing track file", at: location))
                continue
            }
            let values = try file.resourceValues(forKeys: Set(keys))
            guard values.isSymbolicLink != true, values.isRegularFile == true else {
                diagnostics.append(Diagnostic("skipped: track files must be regular files, not links or folders", at: location))
                continue
            }
            guard let text = readText(at: file, limit: limits.maxFileBytes) else {
                diagnostics.append(Diagnostic("skipped: larger than \(limits.maxFileBytes) bytes or not UTF-8", at: location))
                continue
            }
            let parsed = TopicParser.parse(text, track: track, file: track.fileName, limits: limits)
            topics += parsed.topics
            diagnostics += parsed.diagnostics
        }
        return Roadmap(topics: topics, diagnostics: diagnostics)
    }

    /// Reads at most `limit` bytes; a longer file returns `nil`, even one that grew after it was
    /// checked.
    static func readText(at url: URL, limit: Int) -> String? {
        // One byte past the limit tells a file of exactly `limit` bytes from a longer one.
        let (probe, overflow) = limit.addingReportingOverflow(1)
        guard limit >= 0, !overflow, let handle = try? FileHandle(forReadingFrom: url) else { return nil }
        defer { try? handle.close() }
        guard let data = try? handle.read(upToCount: probe) ?? Data(), data.count <= limit else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Finding topics

    /// The topic with this ID, ignoring case and surrounding spaces.
    public func topic(id: String) -> Topic? {
        indexByID[Self.normalizedID(id)].map { topics[$0] }
    }

    /// The form IDs are compared in: trimmed and lowercased.
    public static func normalizedID(_ id: String) -> String {
        id.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    /// The IDs in `ids` that are not topics, normalized and each listed once, in input order.
    public func missingIDs(_ ids: [String]) -> [String] {
        Self.unique(ids.map(Self.normalizedID)).filter { indexByID[$0] == nil }
    }

    /// Topics that list `id` in their needs, in roadmap order.
    public func dependents(of id: String) -> [Topic] {
        let wanted = Self.normalizedID(id)
        return topics.filter { $0.needs.contains(wanted) }
    }

    /// Topics that match every filter that is not `nil`.
    public func filter(_ filter: TopicFilter) -> [Topic] {
        topics.filter { filter.matches($0) }
    }

    /// The number of topics per stage in a track.
    public func count(in track: Track, stage: Stage) -> Int {
        topics.count { $0.track == track && $0.stage == stage }
    }
}

/// What ``Roadmap/filter(_:)`` keeps.
public struct TopicFilter: Sendable, Equatable {
    public var track: Track?
    public var stage: Stage?
    /// Text in the ID, the title or the summary, ignoring case and diacritics.
    public var search: String?

    public init(track: Track? = nil, stage: Stage? = nil, search: String? = nil) {
        self.track = track
        self.stage = stage
        self.search = search
    }

    public func matches(_ topic: Topic) -> Bool {
        if let track, topic.track != track { return false }
        if let stage, topic.stage != stage { return false }
        if let search = search?.trimmingCharacters(in: .whitespaces), !search.isEmpty {
            let options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
            return [topic.id, topic.title, topic.summary].contains { $0.range(of: search, options: options) != nil }
        }
        return true
    }
}
