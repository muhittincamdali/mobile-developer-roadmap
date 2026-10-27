/// The lines of a topic until the next heading.
struct TopicDraft {
    var id: String
    var title: String
    var line: Int
    var body: [(Int, Substring)] = []

    func build(track: Track, file: String, limits: RoadmapLimits, diagnostics: inout DiagnosticLog) -> Topic? {
        let headingLocation = SourceLocation(file: file, line: line)
        guard let metaIndex = body.firstIndex(where: { !$0.1.allSatisfy(\.isWhitespace) }) else {
            diagnostics.append(Diagnostic("\(id) has no stage line", at: headingLocation))
            return nil
        }
        let (metaLine, metaText) = body[metaIndex]
        let metaLocation = SourceLocation(file: file, line: metaLine)
        guard let (stage, needs) = parseMeta(metaText, location: metaLocation, limits: limits, diagnostics: &diagnostics) else {
            return nil
        }

        var summary: [Substring] = []
        var practice: String?
        var resources: [Resource] = []
        var inResources = false
        var fence = FenceTracker()
        for (number, text) in body[(metaIndex + 1)...] {
            let location = SourceLocation(file: file, line: number)
            if !inResources, MarkdownLinks.containsLink(text) {
                diagnostics.append(Diagnostic("\(id): \(MarkdownLinks.outsideItemsProblem)", at: location))
            }
            if fence.consume(text) {
                if inResources {
                    diagnostics.append(Diagnostic("\(id): `**Learn from:**` must be the last part of a topic", at: location))
                    return nil
                }
                summary.append(text)
                continue
            }
            if inResources {
                if text.allSatisfy(\.isWhitespace) || text.hasPrefix("  ") {
                    if MarkdownLinks.containsLink(text) {
                        diagnostics.append(Diagnostic("\(id): \(MarkdownLinks.outsideItemsProblem)", at: location))
                    }
                    continue
                }
                guard let (resource, note) = TopicParser.parseResourceItem(text) else {
                    diagnostics.append(Diagnostic("\(id): after `**Learn from:**` only `- [Title](https://…)` items may follow", at: location))
                    continue
                }
                if let problem = MarkdownLinks.itemProblem(resource, note: note) {
                    diagnostics.append(Diagnostic("\(id)\(problem)", at: location))
                    continue
                }
                guard resources.count < limits.maxResourcesPerTopic else {
                    diagnostics.append(Diagnostic("\(id) lists more than \(limits.maxResourcesPerTopic) resources", at: location))
                    continue
                }
                resources.append(resource)
                continue
            }
            if text.trimmingSpaces() == TopicParser.resourcesLine {
                inResources = true
                continue
            }
            if text.hasPrefix(TopicParser.practicePrefix) {
                guard practice == nil else {
                    diagnostics.append(Diagnostic("\(id) has more than one practice line", at: location))
                    continue
                }
                practice = text.dropFirst(TopicParser.practicePrefix.count).trimmingSpaces()
                continue
            }
            summary.append(text)
        }
        if fence.isOpen {
            return nil
        }

        return Topic(
            id: id,
            track: track,
            title: title,
            stage: stage,
            needs: needs,
            summary: Self.trimBlankLines(summary),
            practice: practice?.isEmpty == false ? practice : nil,
            resources: resources,
            location: headingLocation
        )
    }

    /// Joins the lines without the blank lines at the start and the end. Slicing instead of
    /// removing one line at a time keeps a topic followed by many blank lines linear.
    private static func trimBlankLines(_ lines: [Substring]) -> String {
        let isBlank: (Substring) -> Bool = { $0.allSatisfy(\.isWhitespace) }
        guard let first = lines.firstIndex(where: { !isBlank($0) }),
              let last = lines.lastIndex(where: { !isBlank($0) }) else { return "" }
        return lines[first...last].joined(separator: "\n")
    }

    /// `**Stage:** intermediate · **Needs:** ios/swift, foundations/git`.
    private func parseMeta(_ text: Substring, location: SourceLocation, limits: RoadmapLimits, diagnostics: inout DiagnosticLog) -> (Stage, [String])? {
        let parts = text.trimmingSpaces().components(separatedBy: TopicParser.separator)
        guard let first = parts.first, first.hasPrefix(TopicParser.stagePrefix) else {
            diagnostics.append(Diagnostic("\(id) must start with `**Stage:** beginner`, `intermediate` or `advanced`", at: location))
            return nil
        }
        let stageName = first.dropFirst(TopicParser.stagePrefix.count)
        guard let stage = Stage(rawValue: String(stageName)) else {
            diagnostics.append(Diagnostic("\(id) has an unknown stage `\(stageName)`; use beginner, intermediate or advanced", at: location))
            return nil
        }
        guard parts.count > 1 else { return (stage, []) }
        guard parts.count == 2, parts[1].hasPrefix(TopicParser.needsPrefix) else {
            diagnostics.append(Diagnostic("\(id): after the stage only `· **Needs:** track/topic, …` may follow", at: location))
            return nil
        }
        let names = parts[1].dropFirst(TopicParser.needsPrefix.count).split(separator: ",")
        guard names.count <= limits.maxNeedsPerTopic else {
            diagnostics.append(Diagnostic("\(id) needs more than \(limits.maxNeedsPerTopic) topics", at: location))
            return nil
        }
        var needs: [String] = []
        for name in names.map({ $0.trimmingSpaces() }) {
            guard TopicParser.isValidID(name) else {
                diagnostics.append(Diagnostic("\(id): `\(name)` is not a topic ID such as `ios/swift`", at: location))
                return nil
            }
            needs.append(name)
        }
        return (stage, needs)
    }
}
