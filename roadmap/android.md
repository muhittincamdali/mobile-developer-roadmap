# Android

Native Android apps with Kotlin and Jetpack Compose, following the architecture guidance on
developer.android.com: Kotlin 2.x, coroutines and Flow, Compose with Material 3, and the
large-screen, edge-to-edge and predictive-back behaviour of recent Android versions.

## android/kotlin: The Kotlin language

**Stage:** beginner · **Needs:** foundations/programming

- Variables, null safety (`?`, `?.`, `?:`), functions, lambdas and collections.
- Classes, data classes, sealed classes and interfaces.
- Extension functions and scope functions (`let`, `apply`, `also`) without overusing them.

**Practice:** Port the expenses program from the foundations to Kotlin.

**Learn from:**

- [Kotlin tour](https://kotlinlang.org/docs/kotlin-tour-welcome.html)
- [Null safety](https://kotlinlang.org/docs/null-safety.html)
- [Learn Kotlin for Android](https://developer.android.com/kotlin/learn)

## android/studio: Android Studio, the emulator and Gradle basics

**Stage:** beginner · **Needs:** foundations/command-line

- Creating a project, the module structure, and running on the emulator and a device.
- What Gradle does: build files, dependencies, and the version catalog in `libs.versions.toml`.
- Logcat, the debugger and the Layout Inspector.

**Practice:** Create an app from the Compose template and run it on a phone emulator and a tablet emulator.

**Learn from:**

- [Meet Android Studio](https://developer.android.com/studio/intro)
- [Run apps on the Android Emulator](https://developer.android.com/studio/run/emulator)
- [Configure your build](https://developer.android.com/build)

## android/compose: Jetpack Compose basics

**Stage:** beginner · **Needs:** android/kotlin, android/studio, foundations/ui-design

- Composable functions, modifiers, `Row`, `Column`, `Box` and lazy lists.
- Material 3 components and theming.
- Previews for different screen sizes, font scales and dark theme.

**Practice:** Build a recipe screen with an image, a list of ingredients and a step-by-step section.

**Learn from:**

- [Jetpack Compose](https://developer.android.com/develop/ui/compose/documentation)
- [Android Basics with Compose](https://developer.android.com/courses/android-basics-compose/course)
- [Material Design 3 in Compose](https://developer.android.com/develop/ui/compose/designsystems/material3)

## android/compose-state: State in Compose

**Stage:** beginner · **Needs:** android/compose

- `remember`, `mutableStateOf` and `rememberSaveable`.
- State hoisting: stateless composables that receive state and send events up.
- Recomposition, and why composables must be free of side effects.

**Practice:** Add favourites to the recipe app with the state hoisted to the screen level.

**Learn from:**

- [State and Jetpack Compose](https://developer.android.com/develop/ui/compose/state)
- [Thinking in Compose](https://developer.android.com/develop/ui/compose/mental-model)

## android/lifecycle: Activities, lifecycle and configuration changes

**Stage:** beginner · **Needs:** android/compose

- The activity lifecycle and what happens on rotation, resizing and process death.
- Saving state so the user does not lose work.
- Since Android 16, apps targeting API 36 cannot lock orientation or resizability on large
  screens (smallest width 600dp and up), so every screen has to handle being resized.

**Practice:** Rotate, resize and kill the recipe app in the background and make sure nothing is lost.

**Learn from:**

- [The activity lifecycle](https://developer.android.com/guide/components/activities/activity-lifecycle)
- [Handle configuration changes](https://developer.android.com/guide/topics/resources/runtime-changes)
- [Android 16 behavior changes](https://developer.android.com/about/versions/16/behavior-changes-16)

## android/navigation: Navigation

**Stage:** beginner · **Needs:** android/compose-state

- Moving between screens with typed destinations and arguments.
- The back stack, deep links and bottom navigation.
- Navigation 3, the Compose-first library where you own the back stack as state.

**Practice:** Add a list screen, a detail screen and a deep link that opens one recipe.

**Learn from:**

- [Navigation](https://developer.android.com/guide/navigation)
- [Navigation 3](https://developer.android.com/guide/navigation/navigation-3)

## android/networking: Networking and serialization

**Stage:** beginner · **Needs:** android/kotlin, foundations/json

- Making requests off the main thread, the `INTERNET` permission, and checking connectivity.
- Turning JSON into Kotlin classes with kotlinx.serialization.
- Loading, empty and error states in the UI.

**Practice:** Load recipes from a JSON endpoint and show a retry button when the request fails.

**Learn from:**

- [Connect to the network](https://developer.android.com/develop/connectivity/network-ops/connecting)
- [Kotlin serialization](https://kotlinlang.org/docs/serialization.html)

## android/coroutines: Coroutines and Flow

**Stage:** intermediate · **Needs:** android/networking, foundations/async

- `suspend` functions, scopes, dispatchers and structured concurrency.
- Cancellation, and why `viewModelScope` and `lifecycleScope` exist.
- `Flow`, `StateFlow` and collecting safely with the lifecycle.

**Practice:** Search recipes as the user types, cancelling the previous request each time.

**Learn from:**

- [Coroutines guide](https://kotlinlang.org/docs/coroutines-guide.html)
- [Kotlin coroutines on Android](https://developer.android.com/kotlin/coroutines)
- [Kotlin flows on Android](https://developer.android.com/kotlin/flow)

## android/architecture: App architecture

**Stage:** intermediate · **Needs:** android/coroutines, android/compose-state

- UI layer, data layer and the optional domain layer; one source of truth per piece of data.
- `ViewModel` holding UI state as a `StateFlow`; unidirectional data flow.
- Repositories that hide where data comes from.

**Practice:** Restructure the recipe app into a UI layer with a ViewModel and a data layer with a repository.

**Learn from:**

- [Guide to app architecture](https://developer.android.com/topic/architecture)
- [ViewModel overview](https://developer.android.com/topic/libraries/architecture/viewmodel)
- [Architecture recommendations](https://developer.android.com/topic/architecture/recommendations)

## android/persistence: Room and DataStore

**Stage:** intermediate · **Needs:** android/architecture

- Room entities, DAOs, `Flow` queries and migrations.
- DataStore for small key-value settings instead of SharedPreferences.
- Offline-first: the database as the source of truth, synced with the network.

**Practice:** Store recipes offline in Room and sync them when the network is back.

**Learn from:**

- [Save data in a local database using Room](https://developer.android.com/training/data-storage/room)
- [DataStore](https://developer.android.com/topic/libraries/architecture/datastore)
- [Build an offline-first app](https://developer.android.com/topic/architecture/data-layer/offline-first)

## android/dependency-injection: Dependency injection with Hilt

**Stage:** intermediate · **Needs:** android/architecture

- Why classes should receive their dependencies instead of creating them.
- Hilt modules, scopes and injecting into ViewModels.
- Swapping real implementations for fakes in tests.

**Practice:** Inject the repository and the HTTP client with Hilt, and replace them with fakes in a test.

**Learn from:**

- [Dependency injection in Android](https://developer.android.com/training/dependency-injection)
- [Dependency injection with Hilt](https://developer.android.com/training/dependency-injection/hilt-android)

## android/background-work: Background work and notifications

**Stage:** intermediate · **Needs:** android/coroutines, android/lifecycle

- WorkManager for work that must finish even if the app closes.
- Foreground services and their types, and what Android restricts in the background.
- Notifications, channels and the runtime notification permission.

**Practice:** Refresh the recipes once a day with WorkManager and post a notification for new ones.

**Learn from:**

- [Background work overview](https://developer.android.com/develop/background-work/background-tasks)
- [Persistent work with WorkManager](https://developer.android.com/develop/background-work/background-tasks/persistent)
- [Create a notification](https://developer.android.com/develop/ui/compose/notifications/create-notification)

## android/permissions: Permissions and privacy

**Stage:** intermediate · **Needs:** android/lifecycle, foundations/security

- Runtime permissions, asking in context, and handling "deny" and "don't ask again".
- The photo picker and other ways to avoid broad storage permissions.
- The data safety form on Google Play.

**Practice:** Let the user attach a photo to a recipe with the photo picker, without any storage permission.

**Learn from:**

- [Permissions on Android](https://developer.android.com/guide/topics/permissions/overview)
- [Photo picker](https://developer.android.com/training/data-storage/shared/photo-picker)

## android/adaptive-ui: Adaptive layouts, edge-to-edge and predictive back

**Stage:** intermediate · **Needs:** android/navigation, android/lifecycle

- Window size classes and list-detail layouts for tablets, foldables and desktop windows.
- Drawing edge to edge and handling window insets, which apps targeting API 35 and later get by default.
- Predictive back: handling back with the system animation instead of overriding it.

**Practice:** Show the recipe list and detail side by side on a tablet, and test the back gesture.

**Learn from:**

- [Adaptive layouts in Compose](https://developer.android.com/develop/ui/compose/layouts/adaptive/get-started-with-adaptive-apps)
- [Edge-to-edge in Compose](https://developer.android.com/develop/ui/compose/system/insets)
- [Predictive back](https://developer.android.com/guide/navigation/custom-back/predictive-back-gesture)

## android/accessibility: Accessibility on Android

**Stage:** intermediate · **Needs:** android/compose, foundations/accessibility

- Semantics in Compose: content descriptions, roles, merged nodes and headings.
- Touch target size, font scaling and TalkBack navigation order.
- Checking with Accessibility Scanner and Compose UI tests.

**Practice:** Make the recipe app usable with TalkBack only, at the largest font size.

**Learn from:**

- [Accessibility in Jetpack Compose](https://developer.android.com/develop/ui/compose/accessibility)
- [Test your app's accessibility](https://developer.android.com/guide/topics/ui/accessibility/testing)

## android/testing: Testing Android apps

**Stage:** intermediate · **Needs:** android/architecture, foundations/testing

- Local unit tests for ViewModels and repositories, with coroutine test dispatchers.
- Compose UI tests with semantics matchers.
- Instrumented tests on devices, and screenshot tests for UI regressions.

**Practice:** Test the recipe ViewModel with a fake repository, and the list screen with a Compose test.

**Learn from:**

- [Test apps on Android](https://developer.android.com/training/testing)
- [Testing your Compose layout](https://developer.android.com/develop/ui/compose/testing)
- [Testing Kotlin coroutines on Android](https://developer.android.com/kotlin/coroutines/test)

## android/release: App bundles, signing and Google Play

**Stage:** intermediate · **Needs:** android/studio, foundations/app-stores, foundations/versioning

- Android App Bundles, Play App Signing and upload keys.
- R8 shrinking and the rules that keep reflection-based code working.
- Internal, closed and open testing tracks, staged rollouts, and the target API level Google Play
  requires, which is raised every year.

**Practice:** Upload a signed bundle of the recipe app to the internal testing track.

**Learn from:**

- [About Android App Bundles](https://developer.android.com/guide/app-bundle)
- [Sign your app](https://developer.android.com/studio/publish/app-signing)
- [Target API level requirements for Google Play](https://developer.android.com/google/play/requirements/target-sdk)

## android/performance: Performance

**Stage:** advanced · **Needs:** android/testing, android/release

- Baseline Profiles and startup time; measuring with Macrobenchmark.
- Compose performance: stability, deferring reads and lazy list keys.
- Android vitals in Play Console: ANRs, crashes, excessive wake-ups.

**Practice:** Add a Baseline Profile to the recipe app and measure startup before and after.

**Learn from:**

- [Baseline Profiles overview](https://developer.android.com/topic/performance/baselineprofiles/overview)
- [Compose performance](https://developer.android.com/develop/ui/compose/performance)
- [Android vitals](https://developer.android.com/google/play/vitals)

## android/security: Keystore, network security and app integrity

**Stage:** advanced · **Needs:** android/permissions, android/networking

- Android Keystore for keys and the Credential Manager for passkeys and sign-in.
- Network security configuration and certificate pinning trade-offs.
- Play Integrity API to check requests come from your genuine app.

**Practice:** Sign the user in with Credential Manager and keep the token encrypted with a Keystore key.

**Learn from:**

- [Android Keystore system](https://developer.android.com/privacy-and-security/keystore)
- [Network security configuration](https://developer.android.com/privacy-and-security/security-config)
- [Credential Manager](https://developer.android.com/identity/credential-manager)

## android/modularization: Modularization and build performance

**Stage:** advanced · **Needs:** android/architecture, android/studio

- Feature and core modules, and which module may depend on which.
- Convention plugins for shared Gradle setup; build cache and configuration cache.
- Keeping build times down as the project grows.

**Practice:** Split the recipe app into a data module, a UI module per feature and an app module.

**Learn from:**

- [Guide to Android app modularization](https://developer.android.com/topic/modularization)
- [Optimize your build speed](https://developer.android.com/build/optimize-your-build)

## android/kotlin-multiplatform: Kotlin Multiplatform

**Stage:** advanced · **Needs:** android/architecture

- Sharing business logic between Android and iOS in Kotlin, with native UI on each side.
- `expect`/`actual` declarations and the libraries that support multiplatform.
- When sharing helps, and when two native implementations are simpler.

**Practice:** Move the recipe repository into a shared module and call it from a small iOS app.

**Learn from:**

- [Kotlin Multiplatform](https://kotlinlang.org/docs/multiplatform/get-started.html)
- [Kotlin Multiplatform on Android](https://developer.android.com/kotlin/multiplatform)

## android/on-device-ai: On-device AI

**Stage:** advanced · **Needs:** android/coroutines

- Gemini Nano through the ML Kit GenAI APIs for summarizing, proofreading and rewriting on the device.
- Checking feature availability and downloading the model.
- Cloud models for devices or tasks the on-device model does not cover.

**Practice:** Summarize a recipe on the device, with a fallback when the model is not available.

**Learn from:**

- [Gemini Nano](https://developer.android.com/ai/gemini-nano)
- [AI on Android](https://developer.android.com/ai)
