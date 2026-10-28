# `RoadmapKit`

Read, check and plan the mobile developer roadmap of this repository: foundations, iOS, Android,
Flutter, React Native and engineering practice.

## Overview

The roadmap is a set of Markdown files in the repository's `roadmap` folder, one file per track.
Each topic has an ID, a stage, the topics it needs, a summary, a practice project and links to
primary sources. This library reads the files into ``Topic`` values, reports every format problem
as a ``Diagnostic`` with a file and line, checks the rules across topics with ``RoadmapLinter``,
and orders the topics needed for a goal with ``Roadmap/plan(to:knowing:)``. The `roadmap`
command-line tool and the RoadmapExplorer example app are built on it.

```swift
import Foundation
import RoadmapKit

let roadmap = try Roadmap.load(from: URL(fileURLWithPath: "roadmap"))

let plan = try roadmap.plan(
    to: ["ios/swift-6-mode"],
    knowing: ["foundations/programming", "ios/swift"]
)
for (number, topic) in plan.steps.enumerated() {
    print(number + 1, topic.id, topic.stage.rawValue)
}
```

Reading is bounded by ``RoadmapLimits``: a damaged or very large folder produces diagnostics, not
unbounded memory use or a crash.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:PlanningALearningPath>
- <doc:WritingTopics>

### Reading the roadmap

- ``Roadmap``
- ``TopicParser``
- ``ParsedFile``
- ``RoadmapLimits``
- ``RoadmapError``

### Topics

- ``Topic``
- ``Track``
- ``Stage``
- ``Resource``
- ``SourceLocation``
- ``TopicFilter``

### Planning

- ``LearningPlan``
- ``PlanError``
- ``MermaidGraph``

### Checking content

- ``RoadmapLinter``
- ``SourcePolicy``
- ``Diagnostic``
