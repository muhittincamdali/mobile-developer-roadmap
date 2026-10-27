# The roadmap files

One Markdown file per track. Each topic says what to learn, which topics to learn first, a small
project to practise with, and where to learn it from. The `roadmap` command and the
`RoadmapKit` library read these files, so they follow a fixed format, and `swift run roadmap
lint` checks it.

| File                               | Track                                                                         | Topics |
| ---------------------------------- | ----------------------------------------------------------------------------- | -----: |
| [foundations.md](foundations.md)   | Programming, Git, HTTP, design, accessibility, testing, security, the stores  |     13 |
| [ios.md](ios.md)                   | Swift 6, SwiftUI, the scene life cycle, Liquid Glass, SwiftData, release      |     27 |
| [android.md](android.md)           | Kotlin, Jetpack Compose, coroutines, architecture, adaptive UI, Play          |     22 |
| [flutter.md](flutter.md)           | Dart 3, widgets, architecture, testing, the iOS platform side, release        |     24 |
| [react-native.md](react-native.md) | TypeScript, React, Expo, the New Architecture, EAS                            |     22 |
| [engineering.md](engineering.md)   | Architecture, CI/CD, sign-in, observability, privacy, security, system design |     16 |

## Format

```markdown
# iOS

An introduction to the track.

## ios/concurrency: Swift concurrency

**Stage:** intermediate · **Needs:** ios/networking, foundations/async

- What to learn, as a short list or paragraphs.

**Practice:** A small project that uses the topic.

**Learn from:**

- [Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/)
```

- **ID**: `<track>/<name>`, where the track is the file name and the name uses lowercase ASCII
  letters, digits and single hyphens, starts with a letter and is at most 48 characters long.
  IDs are stable: progress files and other topics refer to them.
- **Stage**: `beginner`, `intermediate` or `advanced`. A topic may only need topics of the same
  or an earlier stage.
- **Needs** (optional): the topics to learn first, from any track. They must exist, may not
  form a loop, and list each topic once.
- **Practice** (optional): one line.
- **Learn from**: the last part of the topic, with at least one link. Links are primary sources:
  the documentation of the platform, language or tool, a standards body, or the project's own
  repository. The accepted hosts are listed in
  [SourcePolicy.swift](../Sources/RoadmapKit/SourcePolicy.swift). Blogs, courses, videos and
  personal repositories are not accepted.

Every link is checked by the link checker in CI; a page that moves or disappears fails the build.
