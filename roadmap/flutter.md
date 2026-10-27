# Flutter

Apps for iOS, Android, web and desktop from one Dart codebase. The track follows the Flutter
documentation for Flutter 3.47 and Dart 3.13: widgets, the recommended MVVM-style architecture,
Dart 3 patterns, testing, and the platform work that is still yours, such as the iOS scene life
cycle and Swift Package Manager.

## flutter/dart: The Dart language

**Stage:** beginner · **Needs:** foundations/programming

- Variables, types, functions, collections and control flow.
- Sound null safety: `?`, `!`, `late` and `required`.
- Classes, constructors, mixins and enums.

**Practice:** Port the expenses program from the foundations to a Dart command-line app.

**Learn from:**

- [Introduction to Dart](https://dart.dev/language)
- [Sound null safety](https://dart.dev/null-safety)

## flutter/setup: Installing Flutter and the tools

**Stage:** beginner · **Needs:** foundations/command-line

- Installing the SDK, `flutter doctor`, and running on an iOS simulator and an Android emulator.
- Hot reload and hot restart, and what each one keeps.
- Flutter DevTools for inspecting widgets, performance and memory.

**Practice:** Create an app with `flutter create`, run it on two platforms and change it with hot reload.

**Learn from:**

- [Get started with Flutter](https://docs.flutter.dev/install)
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools)

## flutter/widgets: Widgets and layout

**Stage:** beginner · **Needs:** flutter/dart, flutter/setup, foundations/ui-design

- Everything is a widget: `StatelessWidget`, `StatefulWidget`, `const` constructors.
- Layout with `Row`, `Column`, `Stack`, `Expanded` and lists; constraints go down, sizes go up.
- Material and Cupertino widgets.

**Practice:** Build a recipe screen with an image, a list of ingredients and a step-by-step section.

**Learn from:**

- [Building user interfaces with Flutter](https://docs.flutter.dev/ui)
- [Layouts in Flutter](https://docs.flutter.dev/ui/layout)
- [Understanding constraints](https://docs.flutter.dev/ui/layout/constraints)

## flutter/state: State basics

**Stage:** beginner · **Needs:** flutter/widgets

- `setState`, lifting state up, and passing callbacks down.
- Ephemeral state inside a widget versus app state shared between screens.
- `ChangeNotifier` with `ListenableBuilder` before reaching for a package.

**Practice:** Add favourites to the recipe app, shared between a list screen and a detail screen.

**Learn from:**

- [State management](https://docs.flutter.dev/data-and-backend/state-mgmt/intro)
- [Simple app state management](https://docs.flutter.dev/data-and-backend/state-mgmt/simple)

## flutter/navigation: Navigation and routing

**Stage:** beginner · **Needs:** flutter/state

- `Navigator` push and pop, and passing data between screens.
- Declarative routing with `go_router` for deep links and the web.
- Tabs and nested navigation.

**Practice:** Add a list screen, a detail screen and a deep link that opens one recipe.

**Learn from:**

- [Navigation and routing](https://docs.flutter.dev/ui/navigation)
- [go_router](https://pub.dev/packages/go_router)

## flutter/async: Futures, streams and isolates

**Stage:** beginner · **Needs:** flutter/dart, foundations/async

- `Future`, `async`/`await` and error handling.
- `Stream` and `StreamBuilder`; `FutureBuilder` for one-off loads.
- Isolates for heavy work that would block the UI.

**Practice:** Parse a large JSON file in an isolate and show a progress indicator meanwhile.

**Learn from:**

- [Asynchronous programming: futures, async, await](https://dart.dev/libraries/async/async-await)
- [Using streams](https://dart.dev/libraries/async/using-streams)
- [Isolates](https://dart.dev/language/isolates)

## flutter/networking: Networking and JSON

**Stage:** beginner · **Needs:** flutter/async, foundations/json

- Fetching data with the `http` package and checking status codes.
- Turning JSON into Dart classes by hand or with code generation.
- Loading, empty and error states.

**Practice:** Load recipes from a JSON endpoint and show a retry button when the request fails.

**Learn from:**

- [Fetch data from the internet](https://docs.flutter.dev/cookbook/networking/fetch-data)
- [JSON and serialization](https://docs.flutter.dev/data-and-backend/serialization/json)

## flutter/dart-3: Records, patterns and class modifiers

**Stage:** intermediate · **Needs:** flutter/dart

- Records for returning several values; destructuring with patterns.
- `switch` expressions and exhaustiveness over `sealed` class hierarchies.
- Class modifiers (`final`, `interface`, `base`) and extension types.

**Practice:** Model the loading, loaded and failed states of a screen as a sealed class and switch over it.

**Learn from:**

- [Patterns](https://dart.dev/language/patterns)
- [Records](https://dart.dev/language/records)
- [Class modifiers](https://dart.dev/language/class-modifiers)
- [Extension types](https://dart.dev/language/extension-types)

## flutter/architecture: App architecture

**Stage:** intermediate · **Needs:** flutter/state, flutter/networking

- The architecture the Flutter team recommends: views and view models in the UI layer,
  repositories and services in the data layer.
- Commands for user actions, and results instead of exceptions across layers.
- Dependency injection with constructors or a small package.

**Practice:** Restructure the recipe app into views, view models, a repository and an API service.

**Learn from:**

- [Guide to app architecture](https://docs.flutter.dev/app-architecture/guide)
- [Architecture concepts](https://docs.flutter.dev/app-architecture/concepts)
- [Architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)

## flutter/state-management: Choosing a state management approach

**Stage:** intermediate · **Needs:** flutter/architecture

- What the common packages solve: Provider, Riverpod, Bloc and others.
- Picking one for the team and using it the same way everywhere.
- Keeping business logic testable without widgets.

**Practice:** Rewrite the favourites feature with one state management package and compare the code.

**Learn from:**

- [List of state management approaches](https://docs.flutter.dev/data-and-backend/state-mgmt/options)
- [provider](https://pub.dev/packages/provider)

## flutter/persistence: Local storage

**Stage:** intermediate · **Needs:** flutter/architecture

- `shared_preferences` for small settings.
- SQLite for structured data, and caching network results.
- Secure storage for tokens.

**Practice:** Keep the recipes and favourites offline in SQLite.

**Learn from:**

- [Store key-value data on disk](https://docs.flutter.dev/cookbook/persistence/key-value)
- [Persist data with SQLite](https://docs.flutter.dev/cookbook/persistence/sqlite)
- [Offline-first support](https://docs.flutter.dev/app-architecture/design-patterns/offline-first)

## flutter/theming: Theming and adaptive design

**Stage:** intermediate · **Needs:** flutter/widgets

- `ThemeData`, `ColorScheme.fromSeed` and Material 3.
- Adapting layouts to phones, tablets and desktop windows.
- Platform-appropriate behaviour on iOS and Android.

**Practice:** Give the recipe app a light and dark theme and a two-pane layout on wide screens.

**Learn from:**

- [Use themes to share colors and font styles](https://docs.flutter.dev/cookbook/design/themes)
- [Adaptive and responsive design](https://docs.flutter.dev/ui/adaptive-responsive)

## flutter/animations: Animations

**Stage:** intermediate · **Needs:** flutter/widgets

- Implicit animations (`AnimatedContainer`, `AnimatedOpacity`) first.
- Explicit animations with `AnimationController`, and hero transitions.
- Respecting the user's reduce-motion setting.

**Practice:** Animate adding a recipe to favourites, and turn it off when animations are disabled.

**Learn from:**

- [Introduction to animations](https://docs.flutter.dev/ui/animations)
- [Implicit animations](https://docs.flutter.dev/ui/animations/implicit-animations)

## flutter/testing: Testing Flutter apps

**Stage:** intermediate · **Needs:** flutter/architecture, foundations/testing

- Unit tests for view models and repositories with fakes.
- Widget tests with `WidgetTester`, finders and `pumpAndSettle`.
- Integration tests on a device or simulator.

**Practice:** Test the recipe view model with a fake repository and the list screen with a widget test.

**Learn from:**

- [Testing Flutter apps](https://docs.flutter.dev/testing/overview)
- [An introduction to widget testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration testing](https://docs.flutter.dev/testing/integration-tests)

## flutter/accessibility-and-i18n: Accessibility and internationalization

**Stage:** intermediate · **Needs:** flutter/widgets, foundations/accessibility

- `Semantics` widgets, labels and checking with the screen readers.
- Text scaling and contrast.
- Localizing with ARB files and `gen-l10n`.

**Practice:** Make the recipe app work with VoiceOver and TalkBack, and add a second language.

**Learn from:**

- [Accessibility](https://docs.flutter.dev/ui/accessibility)
- [Internationalizing Flutter apps](https://docs.flutter.dev/ui/internationalization)

## flutter/platform-integration: Platform channels and native code

**Stage:** intermediate · **Needs:** flutter/async

- Method channels to call Swift and Kotlin code.
- Pigeon for type-safe channels generated from one definition.
- Using existing plugins first, and reading their native code when they fail.

**Practice:** Read the battery level through a Pigeon-generated channel on iOS and Android.

**Learn from:**

- [Writing custom platform-specific code](https://docs.flutter.dev/platform-integration/platform-channels)
- [pigeon](https://pub.dev/packages/pigeon)

## flutter/ios-platform: The iOS side of a Flutter app

**Stage:** intermediate · **Needs:** flutter/platform-integration

- The `UIScene` life cycle, which apps built with the iOS 27 SDK must adopt: since Flutter 3.41
  `flutter build ios` migrates an unchanged `AppDelegate` by itself; customized app delegates
  and plugins that use app life-cycle events are migrated by hand.
- Swift Package Manager for iOS plugins next to CocoaPods.
- Signing, capabilities and the Info.plist entries your plugins need.

**Practice:** Migrate the iOS runner of an older Flutter app to the scene life cycle and Swift Package Manager.

**Learn from:**

- [Migration guide for adding UISceneDelegate](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate)
- [TN3187: Migrating to the UIKit scene-based life cycle](https://developer.apple.com/documentation/technotes/tn3187-migrating-to-the-uikit-scene-based-life-cycle)
- [Swift Package Manager for app developers](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers)

## flutter/release: Building and releasing

**Stage:** intermediate · **Needs:** flutter/setup, foundations/app-stores

- Release builds, app icons, version numbers and build numbers.
- Signing and uploading to Google Play and App Store Connect.
- Flavors for development, staging and production.

**Practice:** Ship a build of the recipe app to TestFlight and to the Play internal testing track.

**Learn from:**

- [Build and release an Android app](https://docs.flutter.dev/deployment/android)
- [Build and release an iOS app](https://docs.flutter.dev/deployment/ios)
- [Set up Flutter flavors for Android](https://docs.flutter.dev/deployment/flavors)

## flutter/packages: Using and writing packages

**Stage:** intermediate · **Needs:** flutter/dart, foundations/versioning

- Choosing packages on pub.dev: maintenance, platforms, licence and score.
- Version constraints and `pubspec.lock`.
- Writing and publishing a Dart package or a plugin.

**Practice:** Extract the recipe model into a local package with its own tests.

**Learn from:**

- [How to use packages](https://dart.dev/tools/pub/packages)
- [Developing packages and plugins](https://docs.flutter.dev/packages-and-plugins/developing-packages)

## flutter/upgrades: Keeping up with Flutter releases

**Stage:** intermediate · **Needs:** flutter/release

- Stable releases arrive about once a quarter; read the breaking changes before upgrading.
- `dart fix` for automated migrations.
- Pinning the SDK version in CI so every build uses the same one.

**Practice:** Upgrade an older project to the current stable release and apply `dart fix --apply`.

**Learn from:**

- [Breaking changes and migration guides](https://docs.flutter.dev/release/breaking-changes)
- [Flutter release notes](https://docs.flutter.dev/release/release-notes)
- [Upgrading Flutter](https://docs.flutter.dev/install/upgrade)

## flutter/performance: Performance

**Stage:** advanced · **Needs:** flutter/testing

- Profile mode, the performance view in DevTools, and frame build and raster times.
- Impeller, the rendering engine on iOS and Android.
- Avoiding expensive rebuilds, layouts and `saveLayer` calls.

**Practice:** Find and fix the slowest frame of a long scrolling list in profile mode.

**Learn from:**

- [Performance](https://docs.flutter.dev/perf)
- [Performance best practices](https://docs.flutter.dev/perf/best-practices)
- [Impeller rendering engine](https://docs.flutter.dev/perf/impeller)

## flutter/native-interop: FFI and direct native interop

**Stage:** advanced · **Needs:** flutter/platform-integration

- `dart:ffi` for calling C libraries.
- Generated bindings to Objective-C, Swift and Java/Kotlin APIs.
- When interop is better than a platform channel.

**Practice:** Call a small C function from Dart through FFI and measure the cost against a channel.

**Learn from:**

- [C interop using dart:ffi](https://dart.dev/interop/c-interop)
- [Objective-C and Swift interop](https://dart.dev/interop/objective-c-interop)
- [Java and Kotlin interop](https://dart.dev/interop/java-interop)

## flutter/add-to-app: Adding Flutter to an existing app

**Stage:** advanced · **Needs:** flutter/platform-integration

- Embedding a Flutter module in an iOS or Android app.
- Engine start-up cost and pre-warming.
- Sharing navigation and data with the host app.

**Practice:** Show one Flutter screen inside a native iOS app.

**Learn from:**

- [Add Flutter to an existing app](https://docs.flutter.dev/add-to-app)

## flutter/ci-cd: Continuous delivery

**Stage:** advanced · **Needs:** flutter/release, engineering/ci-cd

- Running analysis and tests on every pull request.
- Building and signing release builds in CI.
- Uploading to the stores from CI with fastlane or the stores' APIs.

**Practice:** Build and test the app in CI on every push, and upload tagged builds to the test tracks.

**Learn from:**

- [Continuous delivery with Flutter](https://docs.flutter.dev/deployment/cd)
