# Engineering practice

The topics that decide whether an app keeps working after the first release, whatever it is
built with: architecture, delivery, observability, security, privacy and the way a team makes
decisions. Most of them build on one platform track; the resources come from the platforms and
from standards bodies.

## engineering/code-review: Code review

**Stage:** intermediate · **Needs:** foundations/git

- What a reviewer looks for: correctness, design, tests, naming and comments.
- Small pull requests with a description that explains why.
- Giving and receiving comments that are about the code, not the person.

**Practice:** Review three open pull requests in a project you use and compare your notes with the maintainers' comments.

**Learn from:**

- [Google engineering practices: code review](https://google.github.io/eng-practices/review/)
- [About pull request reviews](https://docs.github.com/en/pull-requests/reference/pull-request-reviews)

## engineering/architecture: Architecture patterns

**Stage:** intermediate · **Needs:** foundations/data-structures, foundations/testing

- Separating UI, state and data; a single source of truth; unidirectional data flow.
- MVVM as the platforms describe it, and when more layers (use cases, modules) pay off.
- Dependency injection through initializers, so code can be tested.

**Practice:** Draw the layers of an app you built, mark every place that knows about the network, and reduce them to one.

**Learn from:**

- [Guide to app architecture (Android)](https://developer.android.com/topic/architecture)
- [Flutter architecture concepts](https://docs.flutter.dev/app-architecture/concepts)
- [Model data (SwiftUI)](https://developer.apple.com/documentation/swiftui/model-data)

## engineering/ci-cd: Continuous integration and delivery

**Stage:** intermediate · **Needs:** foundations/git, foundations/testing

- Building and testing every pull request on a clean machine.
- Signing in CI with secrets that never reach the repository.
- Automating store uploads and release notes.

**Practice:** Add a workflow that builds and tests your app on every pull request and fails on any warning.

**Learn from:**

- [GitHub Actions documentation](https://docs.github.com/en/actions)
- [Xcode Cloud](https://developer.apple.com/xcode-cloud/)
- [fastlane documentation](https://docs.fastlane.tools/)

## engineering/dependencies: Managing dependencies

**Stage:** intermediate · **Needs:** foundations/versioning

- Choosing a dependency: maintenance, licence, size and what it would take to replace it.
- Version ranges, lockfiles and reproducible builds.
- Automated update pull requests and reading their changelogs.

**Practice:** List every dependency of an app with its licence and last release date, and remove one you do not need.

**Learn from:**

- [Secure your supply chain with Dependabot](https://docs.github.com/en/code-security/how-tos/secure-your-supply-chain)
- [Semantic Versioning](https://semver.org/)

## engineering/api-design: Working with APIs

**Stage:** intermediate · **Needs:** foundations/http, foundations/json

- Pagination, idempotent requests and retries with backoff.
- Error responses that clients can act on.
- Versioning an API while old app versions are still installed.

**Practice:** Design the API of a small app with pagination and errors, and write how version 2 stays compatible.

**Learn from:**

- [RFC 9457: Problem Details for HTTP APIs](https://www.rfc-editor.org/rfc/rfc9457)
- [RFC 9110: HTTP Semantics](https://www.rfc-editor.org/rfc/rfc9110)
- [HTTP caching](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Caching)

## engineering/offline-first: Offline-first apps

**Stage:** intermediate · **Needs:** engineering/architecture, engineering/api-design

- The local database as the source of truth, synced in the background.
- Queues of pending changes, retries and conflict resolution.
- Showing the user what is saved and what is still waiting.

**Practice:** Make an app usable in airplane mode and sync its changes when the network returns.

**Learn from:**

- [Build an offline-first app (Android)](https://developer.android.com/topic/architecture/data-layer/offline-first)
- [Offline-first support (Flutter)](https://docs.flutter.dev/app-architecture/design-patterns/offline-first)

## engineering/authentication: Sign-in and authorization

**Stage:** intermediate · **Needs:** foundations/security, foundations/http

- OAuth 2.0 for native apps: the system browser and PKCE, never an embedded web view.
- Access and refresh tokens, and where to store them.
- Passkeys as the replacement for passwords.

**Practice:** Sign in to an OAuth provider with PKCE from a mobile app and refresh the token when it expires.

**Learn from:**

- [RFC 8252: OAuth 2.0 for Native Apps](https://www.rfc-editor.org/rfc/rfc8252)
- [RFC 7636: Proof Key for Code Exchange](https://www.rfc-editor.org/rfc/rfc7636)
- [Passkeys (Apple)](https://developer.apple.com/passkeys/)
- [Passkeys (Android)](https://developer.android.com/identity/passkeys)

## engineering/observability: Crashes, logs and metrics

**Stage:** intermediate · **Needs:** foundations/app-stores

- Crash reports with symbols, and the crash-free rate as a release gate.
- Structured logs without personal data, and on-device metrics such as hangs and launch time.
- Alerting on regressions after a release.

**Practice:** Add crash reporting to an app, upload its symbols, and read a symbolicated crash.

**Learn from:**

- [MetricKit](https://developer.apple.com/documentation/metrickit)
- [Android vitals](https://developer.android.com/google/play/vitals)
- [Firebase Crashlytics](https://firebase.google.com/docs/crashlytics)
- [OpenTelemetry documentation](https://opentelemetry.io/docs/)

## engineering/privacy: Privacy and data protection

**Stage:** intermediate · **Needs:** foundations/security, foundations/app-stores

- Collecting only the data a feature needs, and deleting it when asked.
- The App Store privacy details, App Tracking Transparency and the Play data safety section.
- Third-party SDKs: you answer for the data they collect.

**Practice:** Fill in the App Store privacy details and the Play data safety form for an app you built.

**Learn from:**

- [User privacy and data use](https://developer.apple.com/app-store/user-privacy-and-data-use/)
- [Data safety section in Google Play](https://support.google.com/googleplay/android-developer/answer/10787469)

## engineering/rollouts: Feature flags and staged rollouts

**Stage:** advanced · **Needs:** engineering/observability, engineering/ci-cd

- Phased releases on the App Store and staged rollouts on Google Play.
- Remote configuration and feature flags, with safe defaults when the fetch fails.
- Halting a rollout, and forcing an update when an old version must stop working.

**Practice:** Put a new screen behind a remote flag, release it to 5% of users and compare their crash rate.

**Learn from:**

- [Release a version update in phases](https://developer.apple.com/help/app-store-connect/update-your-app/release-a-version-update-in-phases)
- [Release app updates with staged rollouts](https://support.google.com/googleplay/android-developer/answer/6346149)
- [Firebase Remote Config](https://firebase.google.com/docs/remote-config)

## engineering/mobile-security: Mobile application security

**Stage:** advanced · **Needs:** engineering/authentication, foundations/security

- The OWASP MASVS as a checklist of requirements, and the MASTG for how to test them.
- Secure storage, network security, platform interaction and code integrity.
- Threat modelling a feature before it is built.

**Practice:** Check an app against the MASVS storage and network categories and fix what fails.

**Learn from:**

- [OWASP MASVS](https://mas.owasp.org/MASVS/)
- [OWASP MASTG](https://mas.owasp.org/MASTG/)
- [Mobile Application Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Mobile_Application_Security_Cheat_Sheet.html)

## engineering/performance-budgets: Performance budgets

**Stage:** advanced · **Needs:** engineering/observability

- Budgets for launch time, app size, memory and frame rate, checked in CI.
- Measuring on low-end devices, not only on your own phone.
- Energy use and network data as parts of performance.

**Practice:** Set a launch-time and size budget for an app and fail CI when a change exceeds it.

**Learn from:**

- [Improving your app's performance (Apple)](https://developer.apple.com/documentation/xcode/improving-your-app-s-performance)
- [App performance guide (Android)](https://developer.android.com/topic/performance/overview)
- [Reduce your app size (Android)](https://developer.android.com/topic/performance/reduce-apk-size)

## engineering/accessibility-audits: Accessibility audits

**Stage:** advanced · **Needs:** foundations/accessibility, foundations/testing

- Auditing a whole app against WCAG success criteria.
- Automated checks in UI tests, and manual testing with screen readers.
- Tracking accessibility bugs like any other bug, with an owner and a release.

**Practice:** Audit an app's three main flows and file one issue per failed criterion.

**Learn from:**

- [Performing accessibility testing for your app (Apple)](https://developer.apple.com/documentation/accessibility/performing-accessibility-testing-for-your-app)
- [Test your app's accessibility (Android)](https://developer.android.com/guide/topics/ui/accessibility/testing)
- [Understanding WCAG 2.2](https://www.w3.org/WAI/WCAG22/Understanding/)

## engineering/modular-codebase: Modular codebases

**Stage:** advanced · **Needs:** engineering/architecture, engineering/dependencies

- Splitting an app into feature and core modules with explicit dependencies.
- Faster builds and clearer ownership, against the cost of more configuration.
- Sharing code between platforms only where it pays off.

**Practice:** Split one feature of an app into its own module with its own tests.

**Learn from:**

- [Guide to Android app modularization](https://developer.android.com/topic/modularization)
- [Swift packages in Xcode](https://developer.apple.com/documentation/xcode/swift-packages)

## engineering/system-design: Mobile system design

**Stage:** advanced · **Needs:** engineering/offline-first, engineering/rollouts

- Designing a feature end to end: client, API, storage, sync, push and analytics.
- Trade-offs that are specific to mobile: battery, flaky networks, old app versions in the field.
- Drawing the design at the level of detail your audience needs.

**Practice:** Design a chat feature with offline sending and push notifications, and draw its containers.

**Learn from:**

- [Architecture recommendations (Android)](https://developer.android.com/topic/architecture/recommendations)
- [The C4 model](https://c4model.com/)

## engineering/decisions: Design documents and decision records

**Stage:** advanced · **Needs:** engineering/code-review

- Writing a design document before a large change: context, options, decision, risks.
- Architecture decision records that keep the reasons after the people who decided move on.
- Reviewing designs as a team.

**Practice:** Write a decision record for a library or architecture choice in an app you work on.

**Learn from:**

- [Architectural Decision Records](https://adr.github.io/)
