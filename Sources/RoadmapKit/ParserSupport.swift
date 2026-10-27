/// The problems of one file: at most `limit`, then one line that says the rest were not
/// reported, so a file of the same mistake on every line cannot fill memory with diagnostics.
struct DiagnosticLog {
    let limit: Int
    private(set) var entries: [Diagnostic] = []
    private var isFull = false

    init(limit: Int) {
        self.limit = max(limit, 0)
    }

    mutating func append(_ diagnostic: Diagnostic) {
        guard !isFull else { return }
        guard entries.count < limit else {
            isFull = true
            entries.append(Self.overflow(limit: limit, at: diagnostic.location))
            return
        }
        entries.append(diagnostic)
    }

    static func overflow(limit: Int, at location: SourceLocation) -> Diagnostic {
        Diagnostic("more than \(limit) problems in this file; the rest were not reported", at: location)
    }
}

/// Follows fenced code blocks (three or more backticks or tildes) so that headings and the lines
/// inside code are read as code.
struct FenceTracker {
    private var open: Substring?

    var isOpen: Bool { open != nil }

    /// Returns `true` when the line opens, closes or is inside a code block.
    mutating func consume(_ line: Substring) -> Bool {
        let trimmed = line.drop { $0 == " " }
        guard let first = trimmed.first, first == "`" || first == "~" else { return isOpen }
        let run = trimmed.prefix { $0 == first }
        guard run.count >= 3 else { return isOpen }
        guard let opener = open else {
            open = run
            return true
        }
        // A closing fence uses the same character, is at least as long and has no info string.
        if opener.first == first && run.count >= opener.count && trimmed.dropFirst(run.count).allSatisfy(\.isWhitespace) {
            open = nil
        }
        return true
    }
}

extension StringProtocol {
    func trimmingSpaces() -> String {
        String(drop(while: \.isWhitespace).reversed().drop(while: \.isWhitespace).reversed())
    }
}
