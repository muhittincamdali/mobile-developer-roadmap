/// Checks the rules that `swift run roadmap lint` and CI enforce across topics.
///
/// On top of the format problems the loader reports, every topic must have:
/// - an ID that is unique in the roadmap,
/// - a summary and at least one resource,
/// - needs that exist, are not the topic itself, are listed once and are not at a later stage,
/// - no chain of needs that leads back to itself,
/// - resources from ``SourcePolicy``, each listed once.
public struct RoadmapLinter: Sendable {
    public var policy: SourcePolicy
    public var limits: RoadmapLimits

    public init(policy: SourcePolicy = .primarySources, limits: RoadmapLimits = .default) {
        self.policy = policy
        self.limits = limits
    }

    /// The loader's diagnostics followed by the content problems, with at most
    /// ``RoadmapLimits/maxDiagnosticsPerFile`` problems for each file.
    public func lint(_ roadmap: Roadmap) -> [Diagnostic] {
        var report = Report(diagnostics: roadmap.diagnostics, limit: limits.maxDiagnosticsPerFile)
        var firstUse: [String: SourceLocation] = [:]
        for topic in roadmap.topics {
            if let earlier = firstUse[topic.id] {
                report.add("\(topic.id) is already used at \(earlier)", at: topic.location)
                continue
            }
            firstUse[topic.id] = topic.location
            checkContent(of: topic, report: &report)
            checkNeeds(of: topic, in: roadmap, report: &report)
        }
        // One loop more than can be reported, so the "more than … problems" line appears when
        // there are more.
        for cycle in Self.cycles(in: roadmap, maxCount: limits.maxDiagnosticsPerFile + 1) {
            let location = roadmap.topic(id: cycle[0])?.location ?? SourceLocation(file: "", line: 0)
            report.add("needs form a loop: \(cycle.joined(separator: " → ")) → \(cycle[0])", at: location)
        }
        return report.diagnostics
    }

    private func checkContent(of topic: Topic, report: inout Report) {
        if topic.summary.allSatisfy(\.isWhitespace) {
            report.add("\(topic.id) has no summary of what to learn", at: topic.location)
        }
        if topic.resources.isEmpty {
            report.add("\(topic.id) needs a `**Learn from:**` list with at least one link", at: topic.location)
        }
        var seen = Set<String>()
        for resource in topic.resources {
            if let problem = policy.problem(with: resource.url) {
                report.add("\(topic.id): `\(resource.url)` \(problem)", at: topic.location)
            }
            if !seen.insert(resource.url).inserted {
                report.add("\(topic.id) lists `\(resource.url)` twice", at: topic.location)
            }
        }
    }

    private func checkNeeds(of topic: Topic, in roadmap: Roadmap, report: inout Report) {
        var seen = Set<String>()
        for need in topic.needs {
            if need == topic.id {
                report.add("\(topic.id) needs itself", at: topic.location)
                continue
            }
            if !seen.insert(need).inserted {
                report.add("\(topic.id) lists `\(need)` twice in its needs", at: topic.location)
                continue
            }
            guard let needed = roadmap.topic(id: need) else {
                report.add("\(topic.id) needs `\(need)`, which is not a topic", at: topic.location)
                continue
            }
            if needed.stage > topic.stage {
                report.add("\(topic.id) is \(topic.stage.rawValue) but needs \(need), which is \(needed.stage.rawValue)", at: topic.location)
            }
        }
    }

    /// Loops of needs, each reported once, at most `maxCount` of them.
    ///
    /// Depth-first search with an explicit stack, so a long chain of needs in a hostile file
    /// cannot overflow the call stack, and a stop after `maxCount` loops, so a file built to
    /// contain many loops cannot make the result grow with the number of its edges.
    static func cycles(in roadmap: Roadmap, maxCount: Int) -> [[String]] {
        enum Mark { case visiting, done }
        var marks: [String: Mark] = [:]
        var found: [[String]] = []
        var reported = Set<[String]>()

        for start in roadmap.topics where marks[start.id] == nil && found.count < maxCount {
            // Each frame is a topic and the index of the next need to follow.
            var stack: [(id: String, next: Int)] = [(start.id, 0)]
            marks[start.id] = .visiting
            while let frame = stack.last, found.count < maxCount {
                let needs = roadmap.topic(id: frame.id)?.needs ?? []
                guard frame.next < needs.count else {
                    marks[frame.id] = .done
                    stack.removeLast()
                    continue
                }
                stack[stack.count - 1].next += 1
                let need = needs[frame.next]
                guard need != frame.id, roadmap.topic(id: need) != nil else { continue }
                switch marks[need] {
                case .visiting:
                    guard let from = stack.firstIndex(where: { $0.id == need }) else { continue }
                    let loop = stack[from...].map(\.id)
                    // The same loop entered at another topic is reported once.
                    let key = loop.sorted()
                    if reported.insert(key).inserted { found.append(loop) }
                case .done:
                    continue
                case nil:
                    marks[need] = .visiting
                    stack.append((need, 0))
                }
            }
        }
        return found
    }
}

/// Diagnostics with a per-file limit shared by the loader and the linter.
private struct Report {
    var diagnostics: [Diagnostic]
    let limit: Int
    private var counts: [String: Int]

    init(diagnostics: [Diagnostic], limit: Int) {
        self.diagnostics = diagnostics
        self.limit = max(limit, 0)
        counts = Dictionary(diagnostics.map { ($0.location.file, 1) }, uniquingKeysWith: +)
    }

    mutating func add(_ message: String, at location: SourceLocation) {
        let count = counts[location.file, default: 0]
        counts[location.file] = count + 1
        if count < limit {
            diagnostics.append(Diagnostic(message, at: location))
        } else if count == limit {
            diagnostics.append(DiagnosticLog.overflow(limit: limit, at: location))
        }
    }
}
