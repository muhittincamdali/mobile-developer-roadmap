import Foundation
import RoadmapKit

/// A plain text file of the topics someone knows: one ID per line, `#` starts a comment.
///
/// ```text
/// # Done in 2026
/// foundations/programming
/// ios/swift   # the Swift book, chapters 1–15
/// ```
enum KnownTopicsFile {
    /// Largest file that is read, in bytes.
    static let maxBytes = 64 * 1024
    /// Most IDs read from one file.
    static let maxIDs = 2_000

    /// The IDs in `text`, or a message that names the first line that is not an ID.
    static func parse(_ text: String) -> Result<[String], UsageError> {
        var ids: [String] = []
        var number = 0
        var rest = Substring(text)
        if rest.first == "\u{FEFF}" { rest = rest.dropFirst() }
        for line in rest.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline) {
            number += 1
            let content = line.split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false).first ?? ""
            let id = Roadmap.normalizedID(String(content))
            guard !id.isEmpty else { continue }
            guard TopicParser.isValidID(id) else {
                return .failure(UsageError(message: "line \(number) of the known-topics file is not a topic ID such as `ios/swift`"))
            }
            guard ids.count < maxIDs else {
                return .failure(UsageError(message: "the known-topics file has more than \(maxIDs) IDs"))
            }
            ids.append(id)
        }
        return .success(ids)
    }

    /// Reads at most ``maxBytes`` bytes of UTF-8 text.
    static func read(_ url: URL) -> Result<[String], UsageError> {
        // Only regular files: opening a named pipe would wait for a writer, and a device such as
        // /dev/zero has no end. The check follows symbolic links to what they point at.
        let resolved = url.resolvingSymlinksInPath()
        guard (try? resolved.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true else {
            return .failure(UsageError(message: "the known-topics file \(url.path) is missing or is not a regular file"))
        }
        guard let handle = try? FileHandle(forReadingFrom: resolved) else {
            return .failure(UsageError(message: "cannot read the known-topics file \(url.path)"))
        }
        defer { try? handle.close() }
        guard let data = try? handle.read(upToCount: maxBytes + 1) ?? Data() else {
            return .failure(UsageError(message: "cannot read the known-topics file \(url.path)"))
        }
        guard data.count <= maxBytes else {
            return .failure(UsageError(message: "the known-topics file is larger than \(maxBytes) bytes"))
        }
        guard let text = String(data: data, encoding: .utf8) else {
            return .failure(UsageError(message: "the known-topics file is not UTF-8 text"))
        }
        return parse(text)
    }
}
