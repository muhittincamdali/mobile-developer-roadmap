import Foundation
import Testing
@testable import RoadmapKit

@Suite("Loading a roadmap folder")
struct RoadmapTests {
    @Test("Reads the track files in track order")
    func loadsTracks() throws {
        let folder = try TemporaryFolder()
        try folder.writeRoadmap([.ios: "# iOS\n\n" + Fixtures.topic("ios/b") + Fixtures.topic("ios/a")])
        try folder.write("README.md", "# Not a track\n\n## not/a-topic: ignored\n")
        let roadmap = try Roadmap.load(from: folder.url)
        #expect(roadmap.diagnostics.isEmpty)
        #expect(roadmap.topics.map(\.id) == [
            "foundations/basics", "ios/b", "ios/a", "android/basics", "flutter/basics",
            "react-native/basics", "engineering/basics",
        ])
    }

    @Test("Throws for a missing folder")
    func missingFolder() throws {
        let folder = try TemporaryFolder()
        let missing = folder.url.appendingPathComponent("nope")
        #expect(throws: RoadmapError.folderNotFound(missing.path)) {
            try Roadmap.load(from: missing)
        }
        let file = try folder.write("file.md", "# Not a folder")
        #expect(throws: RoadmapError.folderNotFound(file.path)) {
            try Roadmap.load(from: file)
        }
    }

    @Test("Reports missing, unknown, linked and oversized files")
    func fileProblems() throws {
        let folder = try TemporaryFolder()
        try folder.writeRoadmap()
        try FileManager.default.removeItem(at: folder.url.appendingPathComponent("android.md"))
        try folder.write("kotlin.md", "# Kotlin")
        let target = try folder.write("elsewhere/flutter.md", "# Flutter\n\n" + Fixtures.topic("flutter/basics"))
        try FileManager.default.removeItem(at: folder.url.appendingPathComponent("flutter.md"))
        try FileManager.default.createSymbolicLink(at: folder.url.appendingPathComponent("flutter.md"), withDestinationURL: target)
        try folder.write("engineering.md", "# Engineering\n\n" + String(repeating: "x", count: 2_000))

        let roadmap = try Roadmap.load(from: folder.url, limits: RoadmapLimits(maxFileBytes: 1_000))
        let found = Set(roadmap.diagnostics.map(\.description))
        #expect(found == [
            "kotlin.md:0: `kotlin.md` is not a track file (foundations.md, ios.md, android.md, flutter.md, react-native.md, engineering.md); it was not read",
            "android.md:0: missing track file",
            "flutter.md:0: skipped: track files must be regular files, not links or folders",
            "engineering.md:0: skipped: larger than 1000 bytes or not UTF-8",
        ])
        #expect(roadmap.topics.map(\.track) == [.foundations, .ios, .reactNative])
    }

    @Test("A file of exactly the byte limit is read, one byte more is not")
    func byteLimit() throws {
        let folder = try TemporaryFolder()
        let file = try folder.write("ios.md", String(repeating: "a", count: 100))
        #expect(Roadmap.readText(at: file, limit: 100)?.count == 100)
        #expect(Roadmap.readText(at: file, limit: 99) == nil)
        #expect(Roadmap.readText(at: file, limit: Int.max) == nil, "the probe size would overflow")
        #expect(Roadmap.readText(at: file, limit: -1) == nil)
        let invalid = folder.url.appendingPathComponent("latin1.md")
        try Data([0x23, 0x20, 0xE9]).write(to: invalid)
        #expect(Roadmap.readText(at: invalid, limit: 100) == nil)
    }

    @Test("Stops listing after the folder entry limit")
    func folderLimit() throws {
        let folder = try TemporaryFolder()
        try folder.writeRoadmap()
        for index in 0..<10 { try folder.write("extra-\(index).txt", "") }
        let roadmap = try Roadmap.load(from: folder.url, limits: RoadmapLimits(maxFolderEntries: 4))
        #expect(roadmap.diagnostics.map(\.message).contains("the folder has more than 4 entries; only the track files were read"))
        #expect(roadmap.topics.count == Track.allCases.count, "track files are read by name, whatever the listing shows")
    }

    @Test("Finds topics by ID, ignoring case and spaces")
    func findByID() {
        let roadmap = Fixtures.roadmap([("ios/swift", .beginner, []), ("ios/swiftui", .beginner, ["ios/swift"])])
        #expect(roadmap.topic(id: " iOS/Swift ")?.id == "ios/swift")
        #expect(roadmap.topic(id: "ios/kotlin") == nil)
        #expect(roadmap.dependents(of: "IOS/SWIFT").map(\.id) == ["ios/swiftui"])
        #expect(roadmap.missingIDs(["ios/swift", "IOS/nope", "ios/nope", "android/x"]) == ["ios/nope", "android/x"])
    }

    @Test("Filters by track, stage and text without case or diacritics")
    func filters() {
        var roadmap = Fixtures.roadmap([("ios/swift", .beginner, []), ("android/kotlin", .intermediate, [])])
        #expect(roadmap.filter(TopicFilter(track: .android)).map(\.id) == ["android/kotlin"])
        #expect(roadmap.filter(TopicFilter(stage: .beginner)).map(\.id) == ["ios/swift"])
        #expect(roadmap.filter(TopicFilter(search: "KOTLIN")).map(\.id) == ["android/kotlin"])
        #expect(roadmap.filter(TopicFilter(search: "kotlin")).map(\.id) == ["android/kotlin"])
        #expect(roadmap.filter(TopicFilter(search: "   ")).count == 2)
        roadmap = Roadmap(topics: [Topic(id: "ios/cafe", track: .ios, title: "Café", stage: .beginner, summary: "", location: SourceLocation(file: "ios.md", line: 1))])
        #expect(roadmap.filter(TopicFilter(search: "cafe")).map(\.id) == ["ios/cafe"])
        #expect(roadmap.count(in: .ios, stage: .beginner) == 1)
    }
}
