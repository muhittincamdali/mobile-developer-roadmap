import RoadmapKit

/// Collects the text a command prints.
///
/// Roadmap files can come from any folder passed with `--roadmap`, so everything is printed
/// through ``terminalSafe(_:)``: an escape sequence in a title or a summary must not reach the
/// terminal.
struct Printer {
    private(set) var output = ""
    private(set) var errors = ""

    mutating func line(_ text: String, terminator: String = "\n") {
        output += Self.terminalSafe(text) + terminator
    }

    mutating func error(_ text: String) {
        errors += Self.terminalSafe(text) + "\n"
    }

    /// Removes control characters (C0, DEL and C1, which include ESC and CSI) except line feed
    /// and tab, so printed text cannot move the cursor, clear the screen or set the window title.
    /// Bidirectional controls are removed too: they reorder the text around them, so a line
    /// could show something other than it says.
    static func terminalSafe(_ text: String) -> String {
        let isUnsafe: (Unicode.Scalar) -> Bool = { scalar in
            if scalar.properties.isBidiControl { return true }
            return scalar.properties.generalCategory == .control && scalar != "\n" && scalar != "\t"
        }
        guard text.unicodeScalars.contains(where: isUnsafe) else { return text }
        var scalars = String.UnicodeScalarView()
        scalars.append(contentsOf: text.unicodeScalars.filter { !isUnsafe($0) })
        return String(scalars)
    }

    /// Left-aligned columns; the last column is not padded.
    mutating func table(_ rows: [[String]]) {
        // Cleaned before measuring, so removed characters do not throw the columns off.
        let rows = rows.map { $0.map(Self.terminalSafe) }
        guard let columns = rows.first?.count else { return }
        let widths = (0..<columns).map { column in rows.map { $0[column].count }.max() ?? 0 }
        for row in rows {
            let cells = row.enumerated().map { index, cell in
                index == columns - 1 ? cell : cell.padding(toLength: widths[index], withPad: " ", startingAt: 0)
            }
            line(cells.joined(separator: "  "))
        }
    }

    mutating func tracks(_ roadmap: Roadmap) {
        var rows = [["Track"] + Stage.allCases.map(\.rawValue) + ["total"]]
        for track in Track.allCases {
            let counts = Stage.allCases.map { roadmap.count(in: track, stage: $0) }
            rows.append([track.rawValue] + counts.map(String.init) + [String(counts.reduce(0, +))])
        }
        let totals = Stage.allCases.map { stage in roadmap.topics.count { $0.stage == stage } }
        rows.append(["all"] + totals.map(String.init) + [String(roadmap.topics.count)])
        table(rows)
    }

    mutating func topic(_ topic: Topic, in roadmap: Roadmap) {
        line("\(topic.id): \(topic.title)")
        line("\(topic.track.displayName) · \(topic.stage.rawValue)\n")
        line(topic.summary)
        if let practice = topic.practice {
            line("\nPractice: \(practice)")
        }
        if !topic.needs.isEmpty {
            line("\nNeeds:")
            for need in topic.needs {
                line("  \(need)\(roadmap.topic(id: need).map { " — \($0.title)" } ?? "")")
            }
        }
        let next = roadmap.dependents(of: topic.id)
        if !next.isEmpty {
            line("\nLeads to:")
            for dependent in next { line("  \(dependent.id) — \(dependent.title)") }
        }
        if !topic.resources.isEmpty {
            line("\nLearn from:")
            for resource in topic.resources { line("  \(resource.title)\n    \(resource.url)") }
        }
    }

    mutating func plan(_ plan: LearningPlan) {
        let goals = plan.goals.joined(separator: ", ")
        line("Path to \(goals): \(plan.steps.count) topic\(plan.steps.count == 1 ? "" : "s")\n")
        let width = String(plan.steps.count).count
        for (index, step) in plan.steps.enumerated() {
            let number = String(index + 1)
            let padded = String(repeating: " ", count: width - number.count) + number
            let marker = plan.goals.contains(step.id) ? "  ← goal" : ""
            line("\(padded). \(step.id) · \(step.stage.rawValue) · \(step.title)\(marker)")
        }
        if !plan.alreadyKnown.isEmpty {
            line("\nSkipped, already known: \(plan.alreadyKnown.joined(separator: ", "))")
        }
    }
}
