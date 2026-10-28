/// The topics to learn, in order, to reach one or more goal topics.
public struct LearningPlan: Sendable, Equatable {
    /// The goal IDs as they were found in the roadmap.
    public var goals: [String]
    /// Every topic to learn, each after all of its needs; the goals are among them.
    public var steps: [Topic]
    /// Topics on the way that were skipped because they are already known, in roadmap order.
    public var alreadyKnown: [String]

    public init(goals: [String], steps: [Topic], alreadyKnown: [String]) {
        self.goals = goals
        self.steps = steps
        self.alreadyKnown = alreadyKnown
    }
}

/// Why no plan could be made.
public enum PlanError: Error, Equatable, CustomStringConvertible {
    case noGoals
    case unknownTopics([String])
    /// The needs of these topics form a loop; `roadmap lint` reports where.
    case loop([String])

    public var description: String {
        switch self {
        case .noGoals:
            "Name at least one goal topic."
        case .unknownTopics(let ids):
            "No topic with the ID \(ids.map { "`\($0)`" }.joined(separator: ", ")). Run `roadmap list` to see the IDs."
        case .loop(let ids):
            "The needs of \(ids.joined(separator: ", ")) form a loop. Run `roadmap lint` to find it."
        }
    }
}

extension Roadmap {
    /// The topics to learn to reach `goals`, given the topics in `known`.
    ///
    /// The plan follows the needs of every goal, stopping at known topics: a topic you know is
    /// skipped together with the needs that only it leads to. Topics come after all of their
    /// needs; among the topics that are ready at the same time, an earlier stage comes first,
    /// then the track order of ``Track``, then the order of the roadmap files, so the same input
    /// always gives the same plan.
    public func plan(to goals: [String], knowing known: Set<String> = []) throws(PlanError) -> LearningPlan {
        let goalIDs = Self.unique(goals.map(Self.normalizedID).filter { !$0.isEmpty })
        guard !goalIDs.isEmpty else { throw .noGoals }
        let missing = missingIDs(goalIDs)
        guard missing.isEmpty else { throw .unknownTopics(missing) }
        let knownIDs = Set(known.map(Self.normalizedID))

        // Topics reachable from the goals through needs, without entering known topics.
        var included = Set<String>()
        var skipped = Set<String>()
        var queue = goalIDs
        var head = 0
        while head < queue.count {
            let id = queue[head]
            head += 1
            if knownIDs.contains(id) {
                skipped.insert(id)
                continue
            }
            guard let topic = topic(id: id), included.insert(id).inserted else { continue }
            queue += topic.needs
        }

        let steps = try ordered(included)
        let alreadyKnown = topics.map(\.id).filter { skipped.contains($0) }
        return LearningPlan(goals: goalIDs, steps: steps, alreadyKnown: Self.unique(alreadyKnown))
    }

    /// Topics you can start now: not known, and every need is known. In the order of
    /// ``plan(to:knowing:)``. `track` keeps one track.
    public func nextTopics(knowing known: Set<String>, track: Track? = nil) -> [Topic] {
        let knownIDs = Set(known.map(Self.normalizedID))
        let ready = topics.filter { topic in
            !knownIDs.contains(topic.id)
                && (track == nil || topic.track == track)
                && topic.needs.allSatisfy { knownIDs.contains($0) || self.topic(id: $0) == nil }
        }
        return ready.sorted { order(of: $0) < order(of: $1) }
    }

    /// Kahn's algorithm over `ids`; needs outside `ids` are already satisfied.
    private func ordered(_ ids: Set<String>) throws(PlanError) -> [Topic] {
        var remainingNeeds: [String: Int] = [:]
        var dependents: [String: [String]] = [:]
        for id in ids {
            guard let topic = topic(id: id) else { continue }
            let needs = Set(topic.needs).filter { ids.contains($0) && $0 != id }
            remainingNeeds[id] = needs.count
            for need in needs { dependents[need, default: []].append(id) }
            if topic.needs.contains(id) { remainingNeeds[id, default: 0] += 1 }
        }
        var ready = ids.filter { remainingNeeds[$0] == 0 }.compactMap { topic(id: $0) }
        var steps: [Topic] = []
        steps.reserveCapacity(ids.count)
        while let next = ready.min(by: { order(of: $0) < order(of: $1) }) {
            ready.removeAll { $0.id == next.id }
            steps.append(next)
            for dependent in dependents[next.id] ?? [] {
                remainingNeeds[dependent, default: 0] -= 1
                if remainingNeeds[dependent] == 0, let topic = topic(id: dependent) {
                    ready.append(topic)
                }
            }
        }
        guard steps.count == ids.count else {
            let placed = Set(steps.map(\.id))
            throw .loop(topics.map(\.id).filter { ids.contains($0) && !placed.contains($0) })
        }
        return steps
    }

    /// Stage, then track, then position in the roadmap.
    private func order(of topic: Topic) -> (Int, Int, Int) {
        (topic.stage.rank, topic.track.rank, indexByID[topic.id] ?? Int.max)
    }

    static func unique(_ ids: [String]) -> [String] {
        var seen = Set<String>()
        return ids.filter { seen.insert($0).inserted }
    }
}
