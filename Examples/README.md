# Examples

## RoadmapExplorer

A small iOS and macOS app for following the roadmap: browse the tracks by stage, read a topic
with its practice project, needs and links, mark the topics you know, and get the ordered path to
any goal, which skips what you marked. It uses the `RoadmapKit` library from this checkout (a
local package reference to `../..`) and copies the [`roadmap`](../roadmap) folder into the app,
so it always shows the current files. The topics you mark are stored on the device only.

Run it:

1. Open `Examples/RoadmapExplorer/RoadmapExplorer.xcodeproj` in Xcode 26 or later.
2. Choose the **RoadmapExplorer** scheme and an iPhone simulator or **My Mac** as the run destination.
3. Press **Run** (⌘R).

From the command line:

```sh
cd Examples/RoadmapExplorer
xcodebuild build -scheme RoadmapExplorer -destination 'generic/platform=iOS Simulator'
xcodebuild build -scheme RoadmapExplorer -destination 'platform=macOS'
```

What to look at in the code:

| File                                                                         | Shows                                                                                                            |
| ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| [`ExplorerModel.swift`](RoadmapExplorer/RoadmapExplorer/ExplorerModel.swift) | Loading the bundled folder with `Roadmap.load(from:)`, linting it, and `plan(to:knowing:)` with the known topics |
| [`TracksView.swift`](RoadmapExplorer/RoadmapExplorer/TracksView.swift)       | Value-based `NavigationStack` navigation, progress per track and search                                          |
| [`TopicView.swift`](RoadmapExplorer/RoadmapExplorer/TopicView.swift)         | A topic's summary, practice, needs, dependents and links                                                         |
| [`PlanView.swift`](RoadmapExplorer/RoadmapExplorer/PlanView.swift)           | `nextTopics(knowing:)` and the ordered path to a goal                                                            |

The app is a SwiftUI `App` with a `WindowGroup`, so it uses the scene-based life cycle that the
iOS 27 SDK requires, and it gets the Liquid Glass tab bar and navigation bars from the system
without custom code.

The app starts on the track list. The screenshot script
[`scripts/capture-screens.sh`](../scripts/capture-screens.sh) launches it with
`-screen topic:ios/liquid-glass` or `-screen path:ios/swift-6-mode` to open those screens
directly, and with `-knownTopics` to set the known topics for that run, so the screenshots can be
reproduced.

The project file is made with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from
[`project.yml`](RoadmapExplorer/project.yml) and committed, so you only need XcodeGen after editing
`project.yml`.
