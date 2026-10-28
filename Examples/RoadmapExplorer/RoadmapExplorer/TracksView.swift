import RoadmapKit
import SwiftUI

/// The tracks with their progress, and search across every topic.
struct TracksView: View {
    @Environment(ExplorerModel.self) private var model
    @State private var path: [Route]
    @State private var searchText = ""

    init(initialRoute: Route?) {
        _path = State(initialValue: initialRoute.map { [$0] } ?? [])
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                if let error = model.loadError {
                    Section("Problems in the roadmap files") {
                        Text(error).font(.footnote.monospaced()).foregroundStyle(.red)
                    }
                }
                if searchText.isEmpty {
                    Section {
                        ForEach(Track.allCases, id: \.self) { track in
                            NavigationLink(value: Route.track(track.rawValue)) {
                                TrackRow(track: track, known: model.knownCount(in: track), total: model.count(in: track))
                            }
                        }
                    } header: {
                        Text("\(model.roadmap.topics.count) topics")
                    } footer: {
                        Text("Mark the topics you know; the Plan tab skips them.")
                    }
                } else {
                    let results = model.search(searchText)
                    Section("\(results.count) results") {
                        ForEach(results) { topic in
                            NavigationLink(value: Route.topic(topic.id)) {
                                TopicRow(topic: topic, showsTrack: true)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Roadmap")
            .searchable(text: $searchText, prompt: "Search topics")
            .navigationDestination(for: Route.self) { RouteDestination(route: $0) }
        }
    }
}

struct TrackRow: View {
    let track: Track
    let known: Int
    let total: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(track.displayName).font(.headline)
                Spacer()
                Text("\(known) of \(total)").font(.subheadline).foregroundStyle(.secondary).monospacedDigit()
            }
            ProgressView(value: Double(known), total: Double(max(total, 1)))
                .accessibilityHidden(true)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityValue("\(known) of \(total) topics known")
    }
}

/// One track, grouped by stage.
struct TrackView: View {
    @Environment(ExplorerModel.self) private var model
    let track: Track

    var body: some View {
        List {
            ForEach(Stage.allCases, id: \.self) { stage in
                let topics = model.topics(in: track, stage: stage)
                if !topics.isEmpty {
                    Section(stage.rawValue.capitalized) {
                        ForEach(topics) { topic in
                            NavigationLink(value: Route.topic(topic.id)) {
                                TopicRow(topic: topic, showsTrack: false)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(track.displayName)
    }
}

struct TopicRow: View {
    @Environment(ExplorerModel.self) private var model
    let topic: Topic
    let showsTrack: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: model.isKnown(topic) ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(model.isKnown(topic) ? Color.roadmapBlue : .secondary)
                .accessibilityLabel(model.isKnown(topic) ? "Known" : "Not known yet")
            VStack(alignment: .leading, spacing: 2) {
                Text(topic.title)
                Text(showsTrack ? "\(topic.track.displayName) · \(topic.stage.rawValue)" : topic.id)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
