# Foundations

What every mobile developer needs, whatever the platform: a first programming language, the
tools you work in every day, how apps talk to servers, and the basics of design, accessibility,
testing, security and shipping. Start here, then pick a platform track.

## foundations/programming: Programming fundamentals

**Stage:** beginner

- Values, variables, types, conditions, loops and functions.
- Collections (arrays, maps, sets) and when to use each.
- Reading error messages and stepping through code with a debugger.
- Pick the language of your first platform: Swift for iOS, Kotlin for Android, Dart for Flutter,
  JavaScript and TypeScript for React Native. The ideas carry over to the others.

**Practice:** Write a small command-line program that reads a list of expenses and prints the total per category.

**Learn from:**

- [A Swift Tour](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/guidedtour/)
- [Kotlin tour](https://kotlinlang.org/docs/kotlin-tour-welcome.html)
- [Introduction to Dart](https://dart.dev/language)
- [JavaScript Guide](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide)

## foundations/command-line: The command line

**Stage:** beginner

- Moving around folders, listing, copying and removing files, and reading a file.
- Running a program with arguments, environment variables, exit codes and pipes.
- Every platform's build tools (`xcodebuild`, `gradlew`, `flutter`, `npx expo`) run here first.

**Practice:** Create a project folder, a few files and a script that prints how many lines each file has.

**Learn from:**

- [Command line crash course](https://developer.mozilla.org/en-US/docs/Learn_web_development/Getting_started/Environment_setup/Command_line)

## foundations/git: Git and pull requests

**Stage:** beginner · **Needs:** foundations/command-line

- Commits, branches, merging and rebasing; reading `git log` and `git diff`.
- Remotes, pushing and opening a pull request; resolving a merge conflict.
- Small commits with messages that say why the change was made.

**Practice:** Put your expenses program under Git, change it on a branch and merge it through a pull request.

**Learn from:**

- [Pro Git](https://git-scm.com/book/en/v2)
- [About pull requests](https://docs.github.com/en/pull-requests/reference/pull-requests)

## foundations/data-structures: Data structures and complexity

**Stage:** beginner · **Needs:** foundations/programming

- Arrays, dictionaries and sets, and the cost of looking up, inserting and removing in each.
- Value and reference semantics: what is copied when you pass a value around.
- Sorting, searching and big-O notation at the level you need to pick the right collection.

**Practice:** Count the words of a long text with an array and with a dictionary, and compare the run times.

**Learn from:**

- [Swift collection types](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/collectiontypes/)
- [Kotlin collections overview](https://kotlinlang.org/docs/collections-overview.html)
- [Dart collections](https://dart.dev/language/collections)

## foundations/http: HTTP and web APIs

**Stage:** beginner · **Needs:** foundations/programming

- Requests and responses: methods, URLs, headers, status codes and bodies.
- What a REST API looks like, and how pagination, caching and errors are expressed.
- HTTPS and why apps must not talk to servers in plain HTTP.

**Practice:** Call a public API with `curl`, read the headers, and explain each status code you get.

**Learn from:**

- [An overview of HTTP](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Overview)
- [HTTP response status codes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status)
- [RFC 9110: HTTP Semantics](https://www.rfc-editor.org/rfc/rfc9110)

## foundations/json: JSON and data formats

**Stage:** beginner · **Needs:** foundations/http

- JSON values, objects and arrays, and how they map to your language's types.
- Dates, numbers and missing fields: the usual sources of decoding bugs.
- Validating what a server sends instead of trusting it.

**Practice:** Decode a JSON response with an optional field and a date into your own types.

**Learn from:**

- [Working with JSON](https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Scripting/JSON)
- [RFC 8259: The JSON Data Interchange Format](https://www.rfc-editor.org/rfc/rfc8259)

## foundations/async: Asynchronous code and the main thread

**Stage:** beginner · **Needs:** foundations/programming

- Why the UI runs on one main thread and must never wait for the network or the disk.
- Callbacks, promises and futures, and `async`/`await`, which all four platforms now use.
- Cancellation, and what happens when two tasks change the same data.

**Practice:** Load two URLs one after the other and then in parallel, and measure the difference.

**Learn from:**

- [Introducing asynchronous JavaScript](https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Async_JS/Introducing)
- [Swift concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/)
- [Asynchronous programming in Dart](https://dart.dev/libraries/async/async-await)

## foundations/ui-design: Mobile design principles

**Stage:** beginner

- Hierarchy, spacing, typography and colour; touch target sizes; light and dark appearance.
- The conventions of each platform: Apple's Human Interface Guidelines and Material Design.
- Designing for small screens first, then larger ones.

**Practice:** Sketch three screens of a to-do app for a phone and a tablet, following one platform's guidelines.

**Learn from:**

- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines)
- [Material Design 3](https://m3.material.io/)

## foundations/accessibility: Accessibility basics

**Stage:** beginner · **Needs:** foundations/ui-design

- Screen readers (VoiceOver, TalkBack), labels, and the order elements are read in.
- Text that scales with the user's font size, colour contrast, and not relying on colour alone.
- WCAG as the shared vocabulary that accessibility requirements are written in.

**Practice:** Use your phone with the screen reader on for ten minutes and note what is hard.

**Learn from:**

- [Web Content Accessibility Guidelines (WCAG) 2.2](https://www.w3.org/TR/WCAG22/)
- [Accessibility on Apple platforms](https://developer.apple.com/documentation/accessibility)
- [Make apps more accessible (Android)](https://developer.android.com/guide/topics/ui/accessibility)

## foundations/testing: Testing basics

**Stage:** beginner · **Needs:** foundations/programming

- Unit, integration and UI tests, and why most tests should be small and fast.
- Arrange, act, assert; testing behaviour instead of implementation details.
- Test doubles (fakes, stubs) for the network and the clock.

**Practice:** Write tests for the expenses program, including an empty list and a negative amount.

**Learn from:**

- [Fundamentals of testing Android apps](https://developer.android.com/training/testing/fundamentals)
- [Swift Testing](https://developer.apple.com/documentation/testing/)

## foundations/security: Security and privacy basics

**Stage:** beginner · **Needs:** foundations/http

- Secrets do not belong in an app: anything shipped in the binary can be read.
- Storing tokens in the Keychain or the Android Keystore, not in plain preferences.
- Asking only for the permissions and data you need, and saying why.

**Practice:** List every piece of personal data an app you use collects, and where it should be stored.

**Learn from:**

- [OWASP Mobile Top 10](https://owasp.org/projects/mobile-top-10)
- [OWASP MASVS](https://mas.owasp.org/MASVS/)

## foundations/versioning: Versioning and release notes

**Stage:** beginner · **Needs:** foundations/git

- Semantic versions for libraries; version name and build number for apps.
- Commit messages and changelogs that readers, not only tools, can follow.

**Practice:** Tag a release of your project and write its changelog entry.

**Learn from:**

- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)

## foundations/app-stores: How the app stores work

**Stage:** beginner

- Developer accounts, app records, screenshots, privacy details and review.
- Test tracks before release: TestFlight on iOS, internal and closed testing on Google Play.
- The review guidelines that most often reject a first submission.

**Practice:** Read both stores' guidelines and list the five rules a simple app is most likely to break.

**Learn from:**

- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Google Play Developer Program Policy](https://play.google/developer-content-policy/)
