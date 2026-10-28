# Contributing

Thanks for helping to keep the roadmap correct and current. A fix to an outdated topic or a moved
link is as valuable as a new topic: a learner who follows a stale path loses weeks.

## Reporting an outdated topic or a broken link

Open an issue with the **Topic correction** template and include:

- the topic ID (for example `ios/app-life-cycle`),
- what is wrong or outdated, and a primary source that shows it: Apple, Android, Kotlin, Flutter,
  Dart, React, React Native or Expo documentation, a Swift Evolution proposal, an RFC or OWASP,
- for version-specific changes, the OS, SDK or framework version they apply to.

## Adding or changing a topic

1. Fork the repository and branch from `main`. Keep each pull request to one track.
2. Edit `roadmap/<track>.md`. The format is described in [roadmap/README.md](roadmap/README.md) and
   in the [Writing Topics](Sources/RoadmapKit/RoadmapKit.docc/WritingTopics.md) article:
    - never rename a published ID: progress files and other topics refer to it,
    - give a stage and list the topics to learn first under **Needs**; a topic may only need
      topics of the same or an earlier stage,
    - keep the summary to what to learn, in a few bullets, and add a practice project that fits in
      a day or two,
    - link primary sources only. The accepted hosts are in
      [SourcePolicy.swift](Sources/RoadmapKit/SourcePolicy.swift); to propose a new one, explain in
      the pull request why it is the primary source for the topic. Blogs, courses, videos and
      personal or company repositories are not accepted, including our own.
3. Update the topic counts in [roadmap/README.md](roadmap/README.md) and the README table if they
   change; `swift test` checks both.
4. Run the checks:

    ```sh
    swift run roadmap lint
    swift test
    lychee roadmap/*.md
    ```

    `lychee` is the link checker that CI runs; install it with `brew install lychee`. For changes
    to the example app, also build it:

    ```sh
    cd Examples/RoadmapExplorer
    xcodebuild build -scheme RoadmapExplorer -destination 'generic/platform=iOS Simulator'
    ```

5. If the app's screens change, regenerate the screenshots with `scripts/capture-screens.sh`.
6. `README.md` will have translations (`README.<language>.md`), each recording the version of
   `README.md` it follows; CI fails while a translation is behind. If you change `README.md` and
   cannot update the translations, say so in the pull request.

## Code style

- Swift follows the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
  and builds in the Swift 6 language mode without warnings. Document public API with DocC
  comments (`///`).
- Every limit and error path in `RoadmapKit` has a test; add one with any new rule or option.
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/)
  (`feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `ci:`, `chore:`).

## Conduct and security

This project follows the [code of conduct](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)
of all `muhittincamdali` repositories; it lists a private address for reports. Report security
issues, including a link that now leads to a malicious page, privately as described in the
[security policy](SECURITY.md), not in a public issue.

## License

By contributing you agree that your contributions are licensed under the MIT License.
