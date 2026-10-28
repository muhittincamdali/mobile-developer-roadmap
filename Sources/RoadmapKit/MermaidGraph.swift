/// Draws the needs of a track as a Mermaid flowchart, which GitHub renders in Markdown.
public enum MermaidGraph {
    /// A `flowchart` with one node per topic of `track`, grouped by stage, and an arrow from each
    /// need to the topic that needs it. Needs from other tracks appear in an extra group so the
    /// arrows into the track stay visible.
    public static func render(_ roadmap: Roadmap, track: Track) -> String {
        let inTrack = roadmap.topics.filter { $0.track == track }
        let inTrackIDs = Set(inTrack.map(\.id))
        let outside = Roadmap.unique(inTrack.flatMap(\.needs).filter { !inTrackIDs.contains($0) })
            .compactMap { roadmap.topic(id: $0) }

        var lines = ["flowchart TD"]
        if !outside.isEmpty {
            lines.append("  subgraph other[\"From other tracks\"]")
            for topic in outside { lines.append("    \(node(topic, qualified: true))") }
            lines.append("  end")
        }
        for stage in Stage.allCases {
            let topics = inTrack.filter { $0.stage == stage }
            guard !topics.isEmpty else { continue }
            lines.append("  subgraph \(stage.rawValue)[\"\(stage.rawValue.capitalized)\"]")
            for topic in topics { lines.append("    \(node(topic, qualified: false))") }
            lines.append("  end")
        }
        for topic in inTrack {
            for need in Roadmap.unique(topic.needs) where roadmap.topic(id: need) != nil {
                lines.append("  \(nodeName(need)) --> \(nodeName(topic.id))")
            }
        }
        return lines.joined(separator: "\n") + "\n"
    }

    /// `ios/swift-concurrency` → `ios_swift_concurrency`. Slugs only contain lowercase letters,
    /// digits and single hyphens, so two IDs cannot map to the same name.
    static func nodeName(_ id: String) -> String {
        String(id.map { $0.isLetter || $0.isNumber ? $0 : "_" })
    }

    private static func node(_ topic: Topic, qualified: Bool) -> String {
        let label = qualified ? "\(topic.track.displayName): \(topic.title)" : topic.title
        return "\(nodeName(topic.id))[\"\(escape(label))\"]"
    }

    /// Mermaid labels are quoted; quotes, angle brackets and the entity marker are written as
    /// entities, and line breaks as spaces, so a title cannot end the label or add markup.
    static func escape(_ text: String) -> String {
        var result = ""
        for character in text {
            switch character {
            case "\"": result += "#quot;"
            case "#": result += "#35;"
            case "<": result += "#lt;"
            case ">": result += "#gt;"
            case "\n", "\r", "\r\n": result += " "
            default: result.append(character)
            }
        }
        return result
    }
}
