# Writing Topics

The file format, the rules the linter enforces, and which links are accepted.

## The format

Each track is one file, `roadmap/<track>.md`. A file has one `# ` title, an optional
introduction, and topics that start with a `## ` heading:

```markdown
# React Native

An introduction to the track.

## react-native/new-architecture: The New Architecture

**Stage:** intermediate · **Needs:** react-native/setup

- JSI, the Fabric renderer and Turbo Native Modules.

**Practice:** Check every dependency of an app against the New Architecture.

**Learn from:**

- [About the New Architecture](https://reactnative.dev/architecture/landing-page)
```

- The heading is `<ID>: <Title>`. The ID is `<track>/<name>`: the track is the file name, the
  name uses lowercase ASCII letters, digits and single hyphens, starts with a letter and is at
  most 48 characters. ``TopicParser/isValidID(_:)`` checks it. The title is at most 120
  characters.
- The first line under the heading is the stage, optionally followed by `· **Needs:**` and a
  comma-separated list of up to 32 IDs from any track.
- The summary is free Markdown. Headings and resource lines inside fenced code blocks are read as
  code.
- `**Practice:**` is one optional line.
- `**Learn from:**` comes last and is followed only by `- [Title](URL)` items, up to 16. A note
  after the link and indented continuation lines are allowed.

## What the linter checks

``TopicParser`` reports format problems as it reads. ``RoadmapLinter`` then checks:

| Rule                                            | Message, without the code quotes                                                 |
| ----------------------------------------------- | --------------------------------------------------------------- |
| IDs are unique                                  | `ios/swift is already used at ios.md:12`                        |
| Needs exist                                     | `ios/ui needs ios/swiftu, which is not a topic`             |
| No topic needs itself, or lists a need twice    | `ios/ui needs itself`                                           |
| Needs are not at a later stage                  | `ios/ui is beginner but needs ios/advanced, which is advanced`  |
| Needs do not form loops                         | `needs form a loop: ios/a → ios/b → ios/a`                      |
| A summary and at least one link                 | `ios/x needs a **Learn from:** list with at least one link` |
| Links follow ``SourcePolicy`` and are listed once | `ios/x: https://medium.com/… is not a primary source …`     |

At most 100 problems are reported per file, then one line says that the rest were not reported.

## Accepted links

``SourcePolicy/primarySources`` accepts `https` links to:

- platform and language documentation: Apple, Swift, Android, Kotlin, Flutter, Dart, React,
  React Native, Expo, MDN, TypeScript, Node.js and the documentation of the libraries the
  platforms recommend;
- standards and security bodies: W3C, the RFC Editor, OWASP;
- the platforms' own GitHub organisations, such as `github.com/swiftlang/` and
  `github.com/android/`.

It rejects every other host, look-alike hosts (`developer.apple.com.example`), other paths on
shared hosts (`github.com/someone/…`), user names or passwords in the URL, explicit ports and
`utm_` tracking parameters. Blogs, courses and personal repositories are not accepted, which keeps
the resource lists free of advertising and as current as the documentation they point to.

Whether a link still works is checked separately: the link checker in CI requests every URL in the
repository and fails on anything but a 2xx answer.

## Before opening a pull request

```sh
swift run roadmap lint
swift test
```

The test suite lints the repository's own roadmap, plans a path to every topic, and compares the
topic counts in `roadmap/README.md` with the files.
