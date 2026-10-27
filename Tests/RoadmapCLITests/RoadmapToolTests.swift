import Foundation
import Testing
@testable import RoadmapCLI

/// A small roadmap folder in the user's temporary directory, removed when the test ends.
final class ToolFixture {
    let url: URL

    init() throws {
        url = FileManager.default.temporaryDirectory
            .appendingPathComponent("RoadmapCLITests-\(UUID().uuidString)", isDirectory: true)
        let roadmap = url.appendingPathComponent("roadmap")
        try FileManager.default.createDirectory(at: roadmap, withIntermediateDirectories: true)
        let files: [String: String] = [
            "foundations": Self.topic("foundations/programming", "Programming", "beginner", needs: []),
            "ios": Self.topic("ios/swift", "The Swift language", "beginner", needs: ["foundations/programming"])
                + Self.topic("ios/concurrency", "Swift \u{1B}[31mconcurrency", "intermediate", needs: ["ios/swift"]),
            "android": Self.topic("android/kotlin", "Kotlin", "beginner", needs: ["foundations/programming"]),
            "flutter": Self.topic("flutter/dart", "Dart", "beginner", needs: []),
            "react-native": Self.topic("react-native/react", "React", "beginner", needs: []),
            "engineering": Self.topic("engineering/ci", "CI", "intermediate", needs: ["foundations/programming"]),
        ]
        for (name, body) in files {
            try Data("# \(name)\n\n\(body)".utf8).write(to: roadmap.appendingPathComponent("\(name).md"))
        }
    }

    deinit {
        try? FileManager.default.removeItem(at: url)
    }

    static func topic(_ id: String, _ title: String, _ stage: String, needs: [String]) -> String {
        let meta = needs.isEmpty ? "" : " · **Needs:** " + needs.joined(separator: ", ")
        return """
            ## \(id): \(title)

            **Stage:** \(stage)\(meta)

            What to learn about \(title).

            **Practice:** Build something.

            **Learn from:**

            - [Docs](https://developer.apple.com/documentation/swift)


            """
    }

    func run(_ arguments: String...) -> ToolOutput {
        RoadmapTool(currentDirectory: url).run(arguments)
    }

    @discardableResult
    func write(_ name: String, _ data: Data) throws -> URL {
        let file = url.appendingPathComponent(name)
        try data.write(to: file)
        return file
    }
}

@Suite("roadmap command")
struct RoadmapToolTests {
    @Test("Prints usage for no arguments and --help")
    func help() throws {
        let fixture = try ToolFixture()
        for output in [fixture.run(), fixture.run("--help"), fixture.run("path", "-h")] {
            #expect(output.status == 0)
            #expect(output.standardOutput.hasPrefix("Usage: roadmap <command> [options]"))
        }
    }

    @Test("Rejects bad command lines with status 2", arguments: [
        (["fly"], "unknown command `fly`"),
        (["list", "--stage", "expert"], "unknown stage `expert`; use beginner, intermediate or advanced"),
        (["list", "--track", "web"], "unknown track `web`; use foundations, ios, android, flutter, react-native, engineering"),
        (["list", "--track"], "--track needs a value"),
        (["list", "--track", "--stage"], "--track needs a value"),
        (["list", "--known", "ios/swift"], "--known does not work with `list`"),
        (["list", "extra"], "unexpected argument `extra`"),
        (["list", "-x"], "unknown option `-x`"),
        (["show"], "`show` needs a topic ID, such as `roadmap show ios/swift`"),
        (["show", "ios/swift", "ios/concurrency"], "unexpected argument `ios/concurrency`"),
        (["path"], "`path` needs one or more goal topics, such as `roadmap path ios/swift-concurrency`"),
        (["graph"], "`graph` needs --track, such as `roadmap graph --track ios`"),
        (["next", "--known-file", "a.txt", "--known-file", "b.txt"], "--known-file can be given once"),
    ])
    func usageErrors(arguments: [String], message: String) throws {
        let output = RoadmapTool(currentDirectory: try ToolFixture().url).run(arguments)
        #expect(output.status == 2)
        #expect(output.standardOutput.isEmpty)
        #expect(output.standardError == "error: \(message)\n\nRun `roadmap --help` for usage.\n")
    }

    @Test("Limits the number of goals and known IDs")
    func argumentLimits() throws {
        let fixture = try ToolFixture()
        let goals = (0...Arguments.maxGoals).map { "ios/t\($0)" }
        let tooMany = RoadmapTool(currentDirectory: fixture.url).run(["path"] + goals)
        #expect(tooMany.status == 2)
        #expect(tooMany.standardError.contains("`path` takes at most 32 goal topics"))

        let known = (0...Arguments.maxKnownOnCommandLine).map { "ios/t\($0)" }.joined(separator: ",")
        let output = fixture.run("next", "--known", known)
        #expect(output.status == 2)
        #expect(output.standardError.contains("--known takes at most 1000 IDs; use --known-file for more"))
    }

    @Test("Reports a missing roadmap folder")
    func missingFolder() throws {
        let fixture = try ToolFixture()
        let output = fixture.run("list", "--roadmap", "nowhere")
        #expect(output.status == 2)
        #expect(output.standardError == "error: No roadmap folder at \(fixture.url.appendingPathComponent("nowhere").standardizedFileURL.path). Run the command from the repository root or pass --roadmap <folder>.\n")
    }

    @Test("Prints a plan with the goal marked and known topics skipped")
    func path() throws {
        let output = try ToolFixture().run("path", "IOS/Concurrency", "--known", "foundations/programming")
        #expect(output.status == 0)
        #expect(output.standardOutput == """
            Path to ios/concurrency: 2 topics

            1. ios/swift · beginner · The Swift language
            2. ios/concurrency · intermediate · Swift [31mconcurrency  ← goal

            Skipped, already known: foundations/programming

            """)
    }

    @Test("Rejects unknown goals and unknown known topics with status 1")
    func unknownTopics() throws {
        let fixture = try ToolFixture()
        let goal = fixture.run("path", "ios/nope")
        #expect(goal.status == 1)
        #expect(goal.standardError == "No topic with the ID `ios/nope`. Run `roadmap list` to see the IDs.\n")
        let known = fixture.run("next", "--known", "ios/swift,ios/typo")
        #expect(known.status == 1)
        #expect(known.standardError == "Unknown known topic: ios/typo. Run `roadmap list` to see the IDs.\n")
    }

    @Test("Lists what can be started next, reading a known-topics file")
    func next() throws {
        let fixture = try ToolFixture()
        try fixture.write("progress.txt", Data("\u{FEFF}# done\r\nfoundations/programming   # first\n\n IOS/swift \n".utf8))
        let output = fixture.run("next", "--known-file", "progress.txt", "--track", "ios")
        #expect(output.status == 0)
        #expect(output.standardOutput == "You can start 1 topic now:\n\nios/concurrency  intermediate  Swift [31mconcurrency\n")

        let all = fixture.run("next", "--known", "foundations/programming,ios/swift", "--known", "ios/concurrency", "--track", "ios")
        #expect(all.standardOutput == "Nothing left to start: every topic in iOS is known.\n")
    }

    @Test("Rejects known-topics files it cannot use")
    func badKnownFiles() throws {
        let fixture = try ToolFixture()
        try fixture.write("big.txt", Data(repeating: 0x61, count: 64 * 1024 + 1))
        try fixture.write("latin1.txt", Data([0x69, 0x6F, 0x73, 0xE9]))
        try fixture.write("typo.txt", Data("ios/swift\nios swift\n".utf8))
        try fixture.write("many.txt", Data((0...2_000).map { "ios/t\($0)" }.joined(separator: "\n").utf8))
        try FileManager.default.createDirectory(at: fixture.url.appendingPathComponent("folder.txt"), withIntermediateDirectories: true)
        let cases: [(String, String)] = [
            ("big.txt", "the known-topics file is larger than 65536 bytes"),
            ("latin1.txt", "the known-topics file is not UTF-8 text"),
            ("typo.txt", "line 2 of the known-topics file is not a topic ID such as `ios/swift`"),
            ("many.txt", "the known-topics file has more than 2000 IDs"),
            ("folder.txt", "is missing or is not a regular file"),
            ("missing.txt", "is missing or is not a regular file"),
        ]
        for (name, message) in cases {
            let output = fixture.run("path", "ios/swift", "--known-file", name)
            #expect(output.status == 2, "\(name)")
            #expect(output.standardError.contains(message), "\(name): \(output.standardError)")
        }
    }

    @Test("Does not wait on a named pipe given as the known-topics file")
    func namedPipe() throws {
        let fixture = try ToolFixture()
        let pipe = fixture.url.appendingPathComponent("pipe")
        #expect(mkfifo(pipe.path, 0o600) == 0)
        let output = fixture.run("next", "--known-file", pipe.path)
        #expect(output.status == 2)
        #expect(output.standardError.contains("is missing or is not a regular file"))
    }

    @Test("Shows a topic with its needs, what it leads to and its links")
    func show() throws {
        let output = try ToolFixture().run("show", "ios/swift")
        #expect(output.status == 0)
        #expect(output.standardOutput == """
            ios/swift: The Swift language
            iOS · beginner

            What to learn about The Swift language.

            Practice: Build something.

            Needs:
              foundations/programming — Programming

            Leads to:
              ios/concurrency — Swift [31mconcurrency

            Learn from:
              Docs
                https://developer.apple.com/documentation/swift

            """)
    }

    @Test("Lists, counts and filters topics")
    func listAndTracks() throws {
        let fixture = try ToolFixture()
        let list = fixture.run("list", "--track", "ios", "--stage", "beginner")
        #expect(list.standardOutput == "ios/swift  beginner  The Swift language\n\n1 topic\n")
        let none = fixture.run("list", "--search", "nothing like this")
        #expect(none.status == 1)
        #expect(none.standardError == "No topics match these filters.\n")
        let tracks = fixture.run("tracks")
        #expect(tracks.standardOutput.split(separator: "\n").last == "all           5         2             0         7")
    }

    @Test("Lint passes on a clean folder and fails with the problems listed")
    func lint() throws {
        let fixture = try ToolFixture()
        let clean = fixture.run("lint")
        #expect(clean.status == 0)
        #expect(clean.standardOutput == "7 topics, 7 links, 0 problems\n")

        try fixture.write("roadmap/flutter.md", Data("# Flutter\n\n\(ToolFixture.topic("flutter/dart", "Dart", "beginner", needs: ["flutter/missing"]))".utf8))
        let broken = fixture.run("lint")
        #expect(broken.status == 1)
        #expect(broken.standardOutput == "flutter.md:3: flutter/dart needs `flutter/missing`, which is not a topic\n7 topics, 7 links, 1 problem\n")
    }

    @Test("Prints a Mermaid graph of one track")
    func graph() throws {
        let output = try ToolFixture().run("graph", "--track", "ios")
        #expect(output.status == 0)
        #expect(output.standardOutput.hasPrefix("flowchart TD\n"))
        #expect(output.standardOutput.contains("  foundations_programming --> ios_swift\n"))
        #expect(output.standardOutput.contains("ios_concurrency[\"Swift [31mconcurrency\"]"), "the escape character is removed")
    }

    @Test("Removes terminal control and bidirectional characters")
    func terminalSafe() {
        #expect(Printer.terminalSafe("a\u{1B}]0;title\u{07}b\u{9B}c\td\ne\u{202E}f\u{2066}g\u{7F}") == "a]0;titlebc\td\nefg")
        #expect(Printer.terminalSafe("plain · text ← goal") == "plain · text ← goal")
    }
}
