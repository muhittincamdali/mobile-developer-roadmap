# iOS

Native apps for iPhone and iPad with Swift and SwiftUI, as Apple ships them in 2026: Swift 6.4
and Xcode 27, the iOS 27 SDK (which requires the scene-based life cycle) and the Liquid Glass
design. UIKit stays on the path because most existing apps still use it.

## ios/swift: The Swift language

**Stage:** beginner · **Needs:** foundations/programming

- Constants and variables, type inference, strings, collections and control flow.
- Functions, closures and argument labels.
- Running Swift in a playground or with `swift run` before building apps.

**Practice:** Port the expenses program from the foundations to Swift as a Swift package.

**Learn from:**

- [The Swift Programming Language](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/)
- [Swift.org: Getting started](https://www.swift.org/getting-started/)

## ios/xcode: Xcode and the simulator

**Stage:** beginner · **Needs:** foundations/command-line

- Creating a project, targets and schemes, and running on the simulator and a device.
- Previews, the debugger, breakpoints and the console.
- Signing with a free personal team to run on your own iPhone.

**Practice:** Create an app from the template, run it on two simulators and on your phone.

**Learn from:**

- [Xcode documentation](https://developer.apple.com/documentation/xcode)
- [Running your app in Simulator or on a device](https://developer.apple.com/documentation/xcode/running-your-app-on-simulated-or-physical-devices)

## ios/types: Structs, classes, enums and protocols

**Stage:** beginner · **Needs:** ios/swift, foundations/data-structures

- Value types (structs, enums) and reference types (classes), and why SwiftUI prefers values.
- Enums with associated values and `switch` that must cover every case.
- Protocols, extensions and generics as the main way Swift code is shared.

**Practice:** Model a playlist with a struct, an enum for the repeat mode and a protocol for things that can be played.

**Learn from:**

- [Structures and classes](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/classesandstructures/)
- [Enumerations](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/enumerations/)
- [Protocols](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/protocols/)

## ios/optionals-and-errors: Optionals and error handling

**Stage:** beginner · **Needs:** ios/swift

- Optionals, `if let`, `guard let` and why force unwrapping crashes.
- `throws`, `do`/`catch`, typed throws and `Result`.
- Conversions that can fail: `Int(exactly:)` instead of `Int(_:)` for values from outside.

**Practice:** Parse a list of user-typed numbers and report every invalid one instead of crashing.

**Learn from:**

- [Optional chaining](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/optionalchaining/)
- [Error handling](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/errorhandling/)

## ios/swiftui: SwiftUI views and layout

**Stage:** beginner · **Needs:** ios/types, ios/xcode, foundations/ui-design

- Views as values, modifiers, stacks, grids, `List` and `ScrollView`.
- Layout: how a parent proposes a size and a child chooses one; spacers, frames and alignment.
- Previews for every state of a view: empty, loading, long text, dark mode, large type.

**Practice:** Build a recipe screen with an image, a list of ingredients and a step-by-step section.

**Learn from:**

- [SwiftUI tutorials](https://developer.apple.com/tutorials/swiftui)
- [SwiftUI documentation](https://developer.apple.com/documentation/swiftui)

## ios/state: State and data flow

**Stage:** beginner · **Needs:** ios/swiftui

- `@State`, `@Binding` and `@Environment`, and who owns each piece of data.
- `@Observable` models from the Observation framework; `@Bindable` for editing them.
- Keeping one source of truth instead of copying values between views.

**Practice:** Add favourites to the recipe app, shared between a list screen and a detail screen.

**Learn from:**

- [Managing model data in your app](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)
- [Observation](https://developer.apple.com/documentation/observation)

## ios/navigation: Navigation and lists

**Stage:** beginner · **Needs:** ios/state

- `NavigationStack` with value-based `navigationDestination`, and `NavigationSplitView` for iPad and Mac.
- `TabView`, sheets, alerts and confirmation dialogs.
- Restoring where the user was, and opening a screen from a deep link.

**Practice:** Turn the recipe app into a split view on iPad and a stack on iPhone, with a link that opens one recipe.

**Learn from:**

- [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack)
- [NavigationSplitView](https://developer.apple.com/documentation/swiftui/navigationsplitview)

## ios/app-life-cycle: The app and scene life cycle

**Stage:** beginner · **Needs:** ios/swiftui

- An app has one process and one or more scenes (windows); each scene becomes active, inactive
  and enters the background on its own.
- In SwiftUI, `App` and `WindowGroup` are scene-based, and `scenePhase` reports the changes.
- UIKit apps move from `UIApplicationDelegate` window code to `UISceneDelegate`. Apple's TN3187
  says that from the release after iOS 26, an app built with the latest SDK that does not
  adopt the scene life cycle will not launch: with Xcode 27 and the iOS 27 SDK this is required.

**Practice:** Save a draft when the scene goes to the background and restore it on the next launch.

**Learn from:**

- [TN3187: Migrating to the UIKit scene-based life cycle](https://developer.apple.com/documentation/technotes/tn3187-migrating-to-the-uikit-scene-based-life-cycle)
- [Managing your app's life cycle](https://developer.apple.com/documentation/uikit/managing-your-app-s-life-cycle)
- [ScenePhase](https://developer.apple.com/documentation/swiftui/scenephase)

## ios/networking: Networking with URLSession and Codable

**Stage:** beginner · **Needs:** ios/optionals-and-errors, foundations/json

- `URLSession.data(for:)` with `async`/`await`; checking the HTTP status yourself, since a 404 is
  not an error to `URLSession`.
- `Codable`, custom coding keys and date strategies.
- Showing loading, empty and error states in the UI.

**Practice:** Load recipes from a JSON endpoint and show a retry button when the request fails.

**Learn from:**

- [URLSession](https://developer.apple.com/documentation/foundation/urlsession)
- [Encoding and decoding custom types](https://developer.apple.com/documentation/foundation/encoding-and-decoding-custom-types)

## ios/concurrency: Swift concurrency

**Stage:** intermediate · **Needs:** ios/networking, foundations/async

- Tasks, task groups, `async let` and cancellation.
- Actors, `@MainActor` and `Sendable`: how the compiler rules out data races.
- Actor reentrancy: state can change at every `await` inside an actor.

**Practice:** Download twenty images in parallel with a limit of four at a time, and cancel when the screen closes.

**Learn from:**

- [Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/)
- [Migrating to Swift 6](https://www.swift.org/migration/documentation/migrationguide/)

## ios/swift-6-mode: The Swift 6 language mode

**Stage:** intermediate · **Needs:** ios/concurrency

- Complete data-race checking as errors instead of warnings.
- Approachable concurrency: default main-actor isolation for app targets (SE-0466) and
  `nonisolated async` functions that run on the caller's actor unless marked `@concurrent` (SE-0461).
- Migrating a module at a time, and reading the diagnostics instead of silencing them.

**Practice:** Switch an existing app target to the Swift 6 language mode and fix every diagnostic.

**Learn from:**

- [Swift 6 migration guide: data-race safety](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/dataracesafety/)
- [SE-0466: Control default actor isolation inference](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0466-control-default-actor-isolation.md)
- [SE-0461: Run nonisolated async functions on the caller's actor by default](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md)

## ios/persistence: Persistence with SwiftData

**Stage:** intermediate · **Needs:** ios/state

- `@Model` classes, `ModelContainer`, `@Query` and saving changes.
- Relationships, migrations between schema versions, and when files or `UserDefaults` are enough.
- Keeping the store off the main actor for large imports.

**Practice:** Store the recipes offline and keep the favourites after the app is deleted from memory.

**Learn from:**

- [SwiftData](https://developer.apple.com/documentation/swiftdata)
- [Preserving your app's model data across launches](https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches)

## ios/uikit: UIKit and interoperability

**Stage:** intermediate · **Needs:** ios/app-life-cycle, ios/types

- View controllers, Auto Layout and `UICollectionView` with diffable data sources.
- Hosting SwiftUI in UIKit (`UIHostingController`) and UIKit in SwiftUI (`UIViewRepresentable`).
- Reading the code of the many apps that still use UIKit.

**Practice:** Show a SwiftUI detail screen from a UIKit collection view.

**Learn from:**

- [UIKit](https://developer.apple.com/documentation/uikit)
- [UIViewRepresentable](https://developer.apple.com/documentation/swiftui/uiviewrepresentable)
- [UIHostingController](https://developer.apple.com/documentation/swiftui/uihostingcontroller)

## ios/liquid-glass: Liquid Glass

**Stage:** intermediate · **Needs:** ios/navigation

- The design language introduced with iOS 26: standard bars, tab bars, sheets and controls get
  it when the app is built with the new SDK.
- `glassEffect(_:in:)` and `GlassEffectContainer` for custom controls; keeping content, not
  chrome, as the focus.
- The `UIDesignRequiresCompatibility` key that kept the earlier look is ignored when an app is
  built for iOS 27 or later, so every app built with Xcode 27 uses the new design.

**Practice:** Rebuild the recipe app with the iOS 27 SDK and fix every custom control that looks out of place.

**Learn from:**

- [Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/liquid-glass)
- [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views)
- [UIDesignRequiresCompatibility](https://developer.apple.com/documentation/bundleresources/information-property-list/uidesignrequirescompatibility)

## ios/accessibility: Accessibility on iOS

**Stage:** intermediate · **Needs:** ios/swiftui, foundations/accessibility

- Accessibility labels, values, traits and custom actions in SwiftUI.
- Dynamic Type at every size, Reduce Motion and Increase Contrast.
- Checking a screen with the Accessibility Inspector and VoiceOver.

**Practice:** Make the recipe app usable with VoiceOver only, at the largest text size.

**Learn from:**

- [Accessibility (Apple developer documentation)](https://developer.apple.com/documentation/accessibility)
- [Human Interface Guidelines: Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)

## ios/localization: Localization with String Catalogs

**Stage:** intermediate · **Needs:** ios/swiftui

- String Catalogs, plural variants and device-specific strings.
- Formatting dates, numbers and measurements with the user's locale.
- Right-to-left layout and testing with pseudo-languages.

**Practice:** Localize the recipe app into a second language, including plurals.

**Learn from:**

- [Localizing and varying text with a string catalog](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog)
- [Localization](https://developer.apple.com/localization/)

## ios/testing: Testing with Swift Testing and XCTest

**Stage:** intermediate · **Needs:** ios/types, foundations/testing

- `@Test`, `#expect`, `#require`, parameterized tests and traits.
- Testing async code and actors; injecting the network and the clock.
- UI tests with XCTest and the XCUIAutomation framework, kept few and stable.

**Practice:** Test the recipe decoding and the favourites model, including a malformed response.

**Learn from:**

- [Swift Testing](https://developer.apple.com/documentation/testing)
- [XCUIAutomation](https://developer.apple.com/documentation/xcuiautomation)

## ios/packages: Swift Package Manager

**Stage:** intermediate · **Needs:** ios/xcode

- Adding package dependencies and pinning their versions.
- Splitting your own code into local packages with clear public APIs.
- Resources, plugins and the `Package.swift` manifest.

**Practice:** Move the recipe model and networking code into a local package with its own tests.

**Learn from:**

- [Swift Package Manager documentation](https://www.swift.org/documentation/package-manager/)
- [Swift packages in Xcode](https://developer.apple.com/documentation/xcode/swift-packages)

## ios/debugging: Debugging and Instruments

**Stage:** intermediate · **Needs:** ios/xcode

- Breakpoints, LLDB `po` and `p`, the view and memory graph debuggers.
- Instruments: Time Profiler, Allocations, Leaks and the SwiftUI instrument.
- Retain cycles in closures and how `[weak self]` breaks them.

**Practice:** Find a deliberate retain cycle with the memory graph debugger and fix it.

**Learn from:**

- [Debugging](https://developer.apple.com/documentation/xcode/debugging)
- [Instruments tutorials](https://developer.apple.com/tutorials/instruments)

## ios/release: Signing, TestFlight and the App Store

**Stage:** intermediate · **Needs:** ios/xcode, foundations/app-stores, foundations/versioning

- Certificates, provisioning profiles and automatic signing.
- Archiving, uploading and testing with TestFlight before review.
- App Store Connect: privacy details, screenshots, phased release.

**Practice:** Ship a build of the recipe app to TestFlight and invite a tester.

**Learn from:**

- [Distributing your app for beta testing and releases](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)
- [TestFlight](https://developer.apple.com/testflight/)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)

## ios/background-work: Background tasks and notifications

**Stage:** intermediate · **Needs:** ios/app-life-cycle, ios/concurrency

- What iOS lets an app do in the background: background tasks, URL sessions, silent pushes.
- Local and remote notifications, permission prompts and notification actions.
- Testing background work, which the system schedules when it chooses.

**Practice:** Refresh the recipes in the background and notify the user when a new one arrives.

**Learn from:**

- [Background Tasks](https://developer.apple.com/documentation/backgroundtasks)
- [User Notifications](https://developer.apple.com/documentation/usernotifications)

## ios/widgets-and-intents: Widgets, Live Activities and App Intents

**Stage:** intermediate · **Needs:** ios/state

- WidgetKit timelines, widget families and interactive widgets.
- App Intents that make actions available to Shortcuts, Siri, Spotlight and controls.
- Live Activities for events that last minutes or hours.

**Practice:** Add a widget with today's recipe and an intent that marks it as a favourite.

**Learn from:**

- [WidgetKit](https://developer.apple.com/documentation/widgetkit)
- [App Intents](https://developer.apple.com/documentation/appintents)
- [ActivityKit](https://developer.apple.com/documentation/activitykit)

## ios/security: Keychain, privacy and App Transport Security

**Stage:** intermediate · **Needs:** ios/networking, foundations/security

- Storing tokens in the Keychain; Face ID and Touch ID with LocalAuthentication.
- Privacy manifests and required-reason APIs, and purpose strings for every permission.
- App Transport Security and why exceptions need a reason.

**Practice:** Store a sign-in token in the Keychain and protect a settings screen with Face ID.

**Learn from:**

- [Keychain services](https://developer.apple.com/documentation/security/keychain-services)
- [Privacy manifest files](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files)
- [Local Authentication](https://developer.apple.com/documentation/localauthentication)

## ios/performance: Performance and app size

**Stage:** advanced · **Needs:** ios/debugging, ios/concurrency

- Launch time, hangs and hitches; measuring with Instruments and with MetricKit in the field.
- SwiftUI performance: identity, cheap `body` computations and lazy containers.
- Reducing app size and memory use.

**Practice:** Profile the launch of an app, remove the slowest work from the launch path, and measure again.

**Learn from:**

- [Improving your app's performance](https://developer.apple.com/documentation/xcode/improving-your-app-s-performance)
- [MetricKit](https://developer.apple.com/documentation/metrickit)
- [Reducing your app's size](https://developer.apple.com/documentation/xcode/reducing-your-app-s-size)

## ios/advanced-swift: Advanced Swift

**Stage:** advanced · **Needs:** ios/swift-6-mode, ios/packages

- Generics with opaque and existential types (`some` and `any`), and their costs.
- Macros, result builders and property wrappers: how SwiftUI and SwiftData are built.
- Noncopyable types and ownership (`borrowing`, `consuming`) for performance-sensitive code.

**Practice:** Write a small macro in a package and test its expansion.

**Learn from:**

- [Generics](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/generics/)
- [Macros](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros/)
- [SE-0390: Noncopyable structs and enums](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0390-noncopyable-structs-and-enums.md)

## ios/on-device-ai: On-device intelligence

**Stage:** advanced · **Needs:** ios/concurrency

- The Foundation Models framework: prompting the on-device language model, guided generation
  into Swift types, and tool calling.
- Checking model availability, and designing a fallback for devices without it.
- Core ML and Vision for models you bring yourself.

**Practice:** Summarize a recipe into three steps with guided generation, with a plain-text fallback.

**Learn from:**

- [Foundation Models](https://developer.apple.com/documentation/foundationmodels)
- [Core ML](https://developer.apple.com/documentation/coreml)

## ios/multiplatform: iPad, Mac and visionOS

**Stage:** advanced · **Needs:** ios/navigation, ios/app-life-cycle

- Multiple windows and resizable windows on iPad; menus and keyboard shortcuts.
- Running the same SwiftUI code on macOS and visionOS, and where to adapt it.
- Pointer, keyboard and Pencil input.

**Practice:** Run the recipe app in several resizable windows on iPad and as a Mac app.

**Learn from:**

- [Bringing multiple windows to your SwiftUI app](https://developer.apple.com/documentation/swiftui/bringing-multiple-windows-to-your-swiftui-app)
- [visionOS](https://developer.apple.com/documentation/visionos)
