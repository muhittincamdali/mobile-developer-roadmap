import RoadmapKit
import SwiftUI

/// What the user can start now, and a goal picker that leads to a learning path.
struct PlanView: View {
    @Environment(ExplorerModel.self) private var model
    @State private var path: [Route]
    @State private var searchText = ""

    init(initialRoute: Route?) {
        _path = State(initialValue: initialRoute.map { [$0] } ?? [])
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                if searchText.isEmpty {
                    Section {
                        ForEach(model.nextTopics.prefix(8)) { topic in
                            NavigationLink(value: Route.topic(topic.id)) {
                                TopicRow(topic: topic, showsTrack: true)
                            }
                        }
                    } header: {
                        Text("Start now")
                    } footer: {
                        Text("Topics whose needs you already know. Search for a goal to see the whole path to it.")
                    }
                } else {
                    Section("Choose a goal") {
                        ForEach(model.search(searchText)) { topic in
                            NavigationLink(value: Route.path(topic.id)) {
                                TopicRow(topic: topic, showsTrack: true)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Plan")
            .searchable(text: $searchText, prompt: "Goal, such as Swift concurrency")
            .navigationDestination(for: Route.self) { RouteDestination(route: $0) }
        }
    }
}

/// The ordered topics to reach a goal, skipping what the user knows.
struct PathView: View {
    @Environment(ExplorerModel.self) private var model
    let goal: String

    var body: some View {
        if let plan = model.plan(to: goal), let target = model.roadmap.topic(id: goal) {
            List {
                Section {
                    ForEach(Array(plan.steps.enumerated()), id: \.element.id) { index, topic in
                        NavigationLink(value: Route.topic(topic.id)) {
                            HStack(alignment: .firstTextBaseline, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.subheadline.monospacedDigit().bold())
                                    .foregroundStyle(Color.roadmapBlue)
                                    .frame(minWidth: 24, alignment: .trailing)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(topic.title)
                                    Text("\(topic.track.displayName) · \(topic.stage.rawValue)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                } header: {
                    Text(plan.steps.isEmpty ? "You know this already" : "\(plan.steps.count) topics to \(target.title)")
                } footer: {
                    if !plan.alreadyKnown.isEmpty {
                        Text("Skipped because you know them: \(plan.alreadyKnown.compactMap { model.roadmap.topic(id: $0)?.title }.joined(separator: ", ")).")
                    }
                }
            }
            .navigationTitle("Path")
        } else {
            ContentUnavailableView("No path to \(goal)", systemImage: "exclamationmark.triangle")
        }
    }
}
