# Planning a Learning Path

Turn goals and the topics someone already knows into an ordered list of topics.

## Overview

Every topic lists the topics it needs. Following those needs from a goal gives everything that
has to be learned first; ``Roadmap/plan(to:knowing:)`` collects them and puts them in an order
where each topic comes after all of its needs.

```swift
let plan = try roadmap.plan(
    to: ["ios/swift-6-mode", "flutter/ios-platform"],
    knowing: ["foundations/programming", "ios/swift"]
)
plan.steps        // [Topic], needs first, the goals among them
plan.alreadyKnown // ["foundations/programming", "ios/swift"]
```

### How known topics are skipped

The plan follows needs from the goals and stops at a known topic. A topic you know is left out
together with the needs that only it leads to: if you know `ios/swift`, its own need
`foundations/programming` is not added because of it. The same need is still added when another
topic in the plan needs it, so knowing one topic never hides something the rest of the plan
relies on.

A goal that is known gives an empty plan with the goal in ``LearningPlan/alreadyKnown``.

### The order

Among the topics that are ready at the same time, the plan takes:

1. the earlier ``Stage`` first,
2. then the earlier ``Track`` (foundations, iOS, Android, Flutter, React Native, engineering),
3. then the topic that comes first in its file.

The order depends only on the roadmap files and the input, so two people with the same goals and
the same known topics get the same plan.

### Errors

``PlanError`` tells why there is no plan:

- ``PlanError/noGoals``: the goal list is empty or only contains spaces.
- ``PlanError/unknownTopics(_:)``: a goal is not a topic ID; the IDs are listed.
- ``PlanError/loop(_:)``: the needs of the listed topics form a loop. ``RoadmapLinter`` reports
  where, and the roadmap in this repository has none (a test checks it).

Needs that point at IDs which do not exist do not block a plan: the plan treats them as met, and
the linter reports them.

## What can I start now?

``Roadmap/nextTopics(knowing:track:)`` returns the topics that are not known and whose needs are
all known, in the same order as a plan:

```swift
let known: Set = ["foundations/programming", "foundations/command-line", "foundations/git"]
for topic in roadmap.nextTopics(knowing: known, track: .reactNative) {
    print(topic.id)   // react-native/javascript
}
```

The `roadmap next` command and the Plan tab of the RoadmapExplorer app show this list.

## Keeping progress

The library does not store anything. The command-line tool reads known topics from
`--known-file`, a plain text file you keep yourself:

```text
# My progress
foundations/programming
foundations/command-line   # done in January
ios/swift
```

The RoadmapExplorer app keeps the IDs in `UserDefaults` on the device and drops IDs that are no
longer in the roadmap when it starts.
