import RoadmapKit
import SwiftUI

/// What to learn, the practice project, the needs, what the topic leads to and the links.
struct TopicView: View {
    @Environment(ExplorerModel.self) private var model
    let topic: Topic

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(topic.track.displayName) · \(topic.stage.rawValue.capitalized)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    ForEach(Array(SummaryLine.lines(of: topic.summary).enumerated()), id: \.offset) { _, line in
                        SummaryLineView(line: line)
                    }
                }
                .padding(.vertical, 4)
                Toggle("I know this", isOn: Binding(
                    get: { model.isKnown(topic) },
                    set: { model.setKnown($0, for: topic) }
                ))
            }
            if let practice = topic.practice {
                Section("Practice") {
                    Text(practice)
                }
            }
            if !topic.needs.isEmpty {
                Section("Learn first") {
                    ForEach(topic.needs, id: \.self) { id in
                        if let need = model.roadmap.topic(id: id) {
                            NavigationLink(value: Route.topic(need.id)) {
                                TopicRow(topic: need, showsTrack: need.track != topic.track)
                            }
                        }
                    }
                    NavigationLink(value: Route.path(topic.id)) {
                        Label("Plan the path to this topic", systemImage: "list.number")
                    }
                }
            }
            let next = model.roadmap.dependents(of: topic.id)
            if !next.isEmpty {
                Section("Leads to") {
                    ForEach(next) { dependent in
                        NavigationLink(value: Route.topic(dependent.id)) {
                            TopicRow(topic: dependent, showsTrack: dependent.track != topic.track)
                        }
                    }
                }
            }
            Section("Learn from") {
                ForEach(topic.resources, id: \.url) { resource in
                    if let url = URL(string: resource.url) {
                        Link(destination: url) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(resource.title)
                                Text(url.host() ?? resource.url).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(topic.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

/// A summary line: a list item or a paragraph line, with inline Markdown (code, emphasis, links).
enum SummaryLine: Equatable {
    case bullet(String)
    case text(String)

    /// Joins wrapped lines back to the item or paragraph they belong to.
    static func lines(of summary: String) -> [SummaryLine] {
        var result: [SummaryLine] = []
        for raw in summary.split(separator: "\n", omittingEmptySubsequences: false) {
            let line = raw.trimmingCharacters(in: .whitespaces)
            if line.isEmpty { continue }
            if line.hasPrefix("- ") {
                result.append(.bullet(String(line.dropFirst(2))))
            } else if raw.hasPrefix("  "), case .bullet(let text)? = result.last {
                result[result.count - 1] = .bullet(text + " " + line)
            } else {
                result.append(.text(line))
            }
        }
        return result
    }
}

struct SummaryLineView: View {
    let line: SummaryLine

    var body: some View {
        switch line {
        case .bullet(let text):
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("•").foregroundStyle(Color.roadmapBlue).accessibilityHidden(true)
                Text(Self.markdown(text))
            }
        case .text(let text):
            Text(Self.markdown(text))
        }
    }

    static func markdown(_ text: String) -> AttributedString {
        (try? AttributedString(markdown: text, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
            ?? AttributedString(text)
    }
}
