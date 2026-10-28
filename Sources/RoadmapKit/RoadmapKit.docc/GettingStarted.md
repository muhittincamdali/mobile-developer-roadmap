# Getting Started

Follow the roadmap with the command-line tool, or add the library to your own Swift code.

## Use the command-line tool

Clone the repository and run the tool from its root, where it finds the `roadmap` folder:

```sh
git clone https://github.com/muhittincamdali/mobile-developer-roadmap.git
cd mobile-developer-roadmap
swift run roadmap tracks
```

Swift 6.2 or later is needed (Xcode 26 or later on a Mac, or a Swift toolchain on Linux). The
first run builds the tool, which takes a few seconds. The commands:

| Command                                     | What it does                                                                          |
| ------------------------------------------- | ------------------------------------------------------------------------------------- |
| `roadmap tracks`                            | Counts the topics of each track per stage                                             |
| `roadmap list --track ios --stage beginner` | Lists IDs, stages and titles; also `--search`                                         |
| `roadmap show ios/liquid-glass`             | Prints what to learn, the practice project, the needs, what it leads to and the links |
| `roadmap path <ID>...`                      | Orders the topics needed to reach one or more goals                                   |
| `roadmap next`                              | Lists the topics whose needs you already know                                         |
| `roadmap graph --track flutter`             | Prints a track as a Mermaid flowchart                                                 |
| `roadmap lint`                              | Checks the files and exits with status 1 on any problem                               |

`path` and `next` take the topics you know with `--known` (comma-separated, repeatable) or
`--known-file` (one ID per line, `#` for comments):

```console
$ swift run roadmap path ios/swift-6-mode --known foundations/programming,ios/swift
Path to ios/swift-6-mode: 7 topics

1. foundations/http · beginner · HTTP and web APIs
2. foundations/json · beginner · JSON and data formats
3. foundations/async · beginner · Asynchronous code and the main thread
4. ios/optionals-and-errors · beginner · Optionals and error handling
5. ios/networking · beginner · Networking with URLSession and Codable
6. ios/concurrency · intermediate · Swift concurrency
7. ios/swift-6-mode · intermediate · The Swift 6 language mode  ← goal

Skipped, already known: foundations/programming, ios/swift
```

Invalid input, such as an unknown track or a line in the known-topics file that is not an ID, is
reported with exit status 2; an ID that is well-formed but not in the roadmap, with exit status 1.

## Add the library

Add the package with Swift Package Manager and depend on the `RoadmapKit` product:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/mobile-developer-roadmap.git", from: "2.0.0")
],
targets: [
    .target(name: "MyLearningTool", dependencies: [
        .product(name: "RoadmapKit", package: "mobile-developer-roadmap")
    ])
]
```

Then load a roadmap folder and query it:

```swift
import Foundation
import RoadmapKit

let roadmap = try Roadmap.load(from: URL(fileURLWithPath: "roadmap"))

// Everything the loader and the linter found, with file and line.
for problem in RoadmapLinter().lint(roadmap) {
    print(problem)
}

let beginnerFlutter = roadmap.filter(TopicFilter(track: .flutter, stage: .beginner))
let concurrency = roadmap.topic(id: "ios/concurrency")
let unlocked = roadmap.dependents(of: "ios/concurrency")
```

``Roadmap/load(from:limits:)`` throws only when the folder does not exist. Every other problem,
from a missing track file to a heading it cannot read, is a ``Diagnostic`` in
``Roadmap/diagnostics``, and ``RoadmapLinter`` adds the checks that need the whole roadmap.
