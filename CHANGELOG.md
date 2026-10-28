# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-10-28

The roadmap is rewritten as structured topic files with primary sources, and becomes a Swift
package with a path planner, a command-line tool and an example app.

### Added

- `roadmap/`: 124 topics in six tracks (foundations, iOS, Android, Flutter, React Native,
  engineering practice), each with a stage, the topics it needs, a practice project and 301 links
  to primary sources in total. Current for October 2026: Swift 6.4 and Xcode 27, the iOS 27 SDK
  with the required scene life cycle and Liquid Glass, Android 16, Flutter 3.47 / Dart 3.13,
  React Native 0.88 / Expo SDK 58.
- `RoadmapKit` library: a bounded parser that reports problems with file and line, a linter for
  unique IDs, missing or later-stage needs, loops and non-primary links, a learning-path planner
  that skips known topics, `nextTopics(knowing:)`, and a Mermaid graph of a track.
- Links are checked as GitHub renders them: a resource URL may not contain `.` or `..` path
  segments (also as `%2e`), backslashes, character references such as `&#46;` or `&period;`, or
  the `<…>` form, since GitHub and browsers decode them into another address; a link title may not
  contain `[`, `]`, backticks, `<` or `\`; and a link anywhere other than a `**Learn from:**`
  item, including bare `https://…`, `www.…` and e-mail addresses and autolinks such as
  `<!@host>` whose local part uses any character CommonMark allows, raw HTML tags with
  attributes such as `<img src=…>`, or a line that starts an HTML block such as `- <div>`, where
  GitHub's HTML parser also reads `<img 1 src=…>` as an image, is reported. Numeric character references count without the
  `;` too (`&#47`), since browsers decode them that way inside an HTML attribute.
- `roadmap` command: `tracks`, `list`, `show`, `path`, `next`, `graph` and `lint`, with
  `--known` and `--known-file` for progress kept in a plain text file.
- RoadmapExplorer, a SwiftUI app for iPhone, iPad and Mac that browses the tracks, marks known
  topics and shows the path to a goal; README screenshots taken from it by
  `scripts/capture-screens.sh`.
- DocC documentation with three articles: Getting Started, Planning a Learning Path, Writing
  Topics.
- Tests (Swift Testing) for every limit and error path, a lint of the repository's own roadmap,
  a plan to every topic, and checks that the README examples and counts match the files.
- CI through the shared workflows: build and test on macOS and an iOS simulator, the example app,
  DocC on GitHub Pages, a weekly link check of every resource, and hygiene checks.

### Changed

- The README is a short overview with a three-step quick start; the roadmap itself moved to
  `roadmap/`.

### Removed

- The "interactive tracker" script, which printed a fixed message instead of scanning anything,
  the progress-tracker templates, and the tracker listings in `Examples/` that nothing compiled.
- The week-by-week guides in `docs/`, the interview guide, and the books and courses lists, which
  had no links to check.
- Links that promoted the author's own packages as the recommended stack, the salary table and
  other numbers without a source.
- The markdown lint workflow, which ran with `continue-on-error` and could not fail.

## [1.0.0] - 2026-02-03

First tag: the repository files (license, contributing guide, security policy, issue templates and
a markdown lint workflow). The roadmap content was added after it in untagged commits and is
replaced by 2.0.0.

[2.0.0]: https://github.com/muhittincamdali/mobile-developer-roadmap/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/muhittincamdali/mobile-developer-roadmap/releases/tag/v1.0.0
