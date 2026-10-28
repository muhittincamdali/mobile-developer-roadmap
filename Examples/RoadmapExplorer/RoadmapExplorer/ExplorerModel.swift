import Foundation
import Observation
import RoadmapKit

/// The roadmap the app shows and the topics the user marked as known.
@MainActor
@Observable
final class ExplorerModel {
    /// The UserDefaults key of the known topics, one ID per line. Passing
    /// `-knownTopics "ios/swift,ios/xcode"` at launch sets them for that run, which the screenshot
    /// script uses.
    static let knownKey = "knownTopics"

    let roadmap: Roadmap
    /// Shown above the tracks when the bundled roadmap could not be read cleanly.
    let loadError: String?
    private(set) var known: Set<String>
    private let defaults: UserDefaults

    init(roadmap: Roadmap, loadError: String? = nil, defaults: UserDefaults = .standard) {
        self.roadmap = roadmap
        self.loadError = loadError
        self.defaults = defaults
        let stored = defaults.string(forKey: Self.knownKey) ?? ""
        let ids = stored.split(whereSeparator: { $0 == "\n" || $0 == "," }).map { Roadmap.normalizedID(String($0)) }
        // IDs that are no longer in the roadmap are dropped instead of being kept forever.
        known = Set(ids.filter { roadmap.topic(id: $0) != nil })
    }

    /// Loads the `roadmap` folder that the Xcode project copies into the app bundle.
    static func bundled(_ bundle: Bundle = .main) -> ExplorerModel {
        guard let folder = bundle.url(forResource: "roadmap", withExtension: nil) else {
            return ExplorerModel(roadmap: Roadmap(topics: []), loadError: "The app bundle has no roadmap folder.")
        }
        do {
            let roadmap = try Roadmap.load(from: folder)
            let problems = RoadmapLinter().lint(roadmap).map(\.description)
            return ExplorerModel(roadmap: roadmap, loadError: problems.isEmpty ? nil : problems.joined(separator: "\n"))
        } catch {
            return ExplorerModel(roadmap: Roadmap(topics: []), loadError: String(describing: error))
        }
    }

    func topics(in track: Track, stage: Stage) -> [Topic] {
        roadmap.filter(TopicFilter(track: track, stage: stage))
    }

    func knownCount(in track: Track) -> Int {
        roadmap.topics.count { $0.track == track && known.contains($0.id) }
    }

    func count(in track: Track) -> Int {
        roadmap.topics.count { $0.track == track }
    }

    func isKnown(_ topic: Topic) -> Bool {
        known.contains(topic.id)
    }

    func setKnown(_ isKnown: Bool, for topic: Topic) {
        if isKnown { known.insert(topic.id) } else { known.remove(topic.id) }
        defaults.set(known.sorted().joined(separator: "\n"), forKey: Self.knownKey)
    }

    /// The path to `goal`; `nil` only when the bundled roadmap is broken.
    func plan(to goal: String) -> LearningPlan? {
        try? roadmap.plan(to: [goal], knowing: known)
    }

    var nextTopics: [Topic] {
        roadmap.nextTopics(knowing: known)
    }

    func search(_ text: String) -> [Topic] {
        roadmap.filter(TopicFilter(search: text))
    }
}
