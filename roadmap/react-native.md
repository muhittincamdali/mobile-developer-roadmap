# React Native

Native iOS and Android apps written in TypeScript and React. The track follows the React Native
and Expo documentation for React Native 0.88 and Expo SDK 58: Expo as the recommended way to
start, the New Architecture (the only one since React Native 0.82), and native modules when a
library is missing.

## react-native/javascript: Modern JavaScript

**Stage:** beginner · **Needs:** foundations/programming

- `let` and `const`, arrow functions, destructuring, spread and template strings.
- Arrays and objects, `map`, `filter` and `reduce`.
- Modules (`import` and `export`), and promises with `async`/`await`.

**Practice:** Port the expenses program from the foundations to a Node.js script.

**Learn from:**

- [JavaScript Guide](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide)
- [JavaScript modules](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules)
- [Node.js: Introduction](https://nodejs.org/learn/getting-started/introduction-to-nodejs)

## react-native/typescript: TypeScript

**Stage:** beginner · **Needs:** react-native/javascript

- Types, interfaces, unions and narrowing.
- Generics and typing function props and state.
- `strict` mode, which new React Native projects use.

**Practice:** Convert the expenses script to TypeScript with `strict` enabled.

**Learn from:**

- [The TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
- [Using TypeScript with React Native](https://reactnative.dev/docs/typescript)

## react-native/react: React fundamentals

**Stage:** beginner · **Needs:** react-native/typescript

- Components, props and JSX; rendering lists with keys.
- `useState`, events and lifting state up.
- Thinking in React: splitting a screen into components.

**Practice:** Model a recipe screen as a tree of components on paper, then build it.

**Learn from:**

- [Quick Start](https://react.dev/learn)
- [Thinking in React](https://react.dev/learn/thinking-in-react)

## react-native/setup: Creating an app with Expo

**Stage:** beginner · **Needs:** foundations/command-line, react-native/javascript

- `create-expo-app`, Expo Go and development builds.
- Running on an iOS simulator, an Android emulator and a phone.
- When you need the native projects, and continuous native generation (prebuild).

**Practice:** Create an app, run it on a phone and change it with Fast Refresh.

**Learn from:**

- [Get started with React Native](https://reactnative.dev/docs/environment-setup)
- [Create a project (Expo)](https://docs.expo.dev/get-started/create-a-project/)
- [Development builds](https://docs.expo.dev/develop/development-builds/introduction/)

## react-native/components: Core components and styling

**Stage:** beginner · **Needs:** react-native/react, react-native/setup, foundations/ui-design

- `View`, `Text`, `Image`, `ScrollView`, `Pressable` and `TextInput`.
- `StyleSheet` and Flexbox layout, which defaults to a column.
- Safe areas, the keyboard, and light and dark appearance.

**Practice:** Build a recipe screen with an image, a list of ingredients and a step-by-step section.

**Learn from:**

- [Core components and native components](https://reactnative.dev/docs/intro-react-native-components)
- [Layout with Flexbox](https://reactnative.dev/docs/flexbox)
- [Style](https://reactnative.dev/docs/style)

## react-native/lists: Lists

**Stage:** beginner · **Needs:** react-native/components

- `FlatList` and `SectionList`, keys, and rendering only what is visible.
- Pull to refresh, empty states and loading more on scroll.
- Tuning list performance.

**Practice:** Show two hundred recipes in a list with sections and pull to refresh.

**Learn from:**

- [FlatList](https://reactnative.dev/docs/flatlist)
- [Optimizing FlatList configuration](https://reactnative.dev/docs/optimizing-flatlist-configuration)

## react-native/navigation: Navigation with Expo Router

**Stage:** beginner · **Needs:** react-native/components

- File-based routes, stacks, tabs and modals with Expo Router.
- Route parameters, typed routes and deep links.
- React Navigation, which Expo Router is built on.

**Practice:** Add a list screen, a detail screen and a deep link that opens one recipe.

**Learn from:**

- [Introduction to Expo Router](https://docs.expo.dev/router/introduction/)
- [React Navigation](https://reactnavigation.org/docs/getting-started/)

## react-native/networking: Networking and data loading

**Stage:** beginner · **Needs:** react-native/react, foundations/json

- `fetch`, checking `response.ok`, and parsing JSON.
- Loading data in effects, and why a data-fetching library helps with caching and retries.
- Loading, empty and error states.

**Practice:** Load recipes from a JSON endpoint and show a retry button when the request fails.

**Learn from:**

- [Networking](https://reactnative.dev/docs/network)
- [Synchronizing with Effects](https://react.dev/learn/synchronizing-with-effects)

## react-native/state: Hooks and state management

**Stage:** intermediate · **Needs:** react-native/networking

- `useEffect`, `useMemo`, `useCallback`, `useReducer` and custom hooks.
- Context for values many components need, and when an external store is better.
- Keeping state minimal and deriving the rest.

**Practice:** Share favourites between screens with a reducer and context, then write a custom hook for it.

**Learn from:**

- [Managing state](https://react.dev/learn/managing-state)
- [Built-in React Hooks](https://react.dev/reference/react/hooks)
- [You might not need an effect](https://react.dev/learn/you-might-not-need-an-effect)

## react-native/new-architecture: The New Architecture

**Stage:** intermediate · **Needs:** react-native/setup

- JSI, the Fabric renderer and Turbo Native Modules, replacing the old bridge.
- Since React Native 0.82 the New Architecture is the only one; libraries must support it.
- What changes for app code: synchronous layout, concurrent React features.

**Practice:** Check every dependency of an app against the New Architecture and replace the ones that do not support it.

**Learn from:**

- [About the New Architecture](https://reactnative.dev/architecture/landing-page)
- [React Native 0.82 release notes](https://reactnative.dev/blog/2025/10/08/react-native-0.82)

## react-native/storage: Storage

**Stage:** intermediate · **Needs:** react-native/state

- Key-value storage for settings, SQLite for structured data.
- `expo-secure-store` for tokens, backed by the Keychain and the Android Keystore.
- Caching network data for offline use.

**Practice:** Keep the recipes offline in SQLite and the sign-in token in secure storage.

**Learn from:**

- [Expo SQLite](https://docs.expo.dev/versions/latest/sdk/sqlite/)
- [Expo SecureStore](https://docs.expo.dev/versions/latest/sdk/securestore/)

## react-native/animations: Animations and gestures

**Stage:** intermediate · **Needs:** react-native/components

- The `Animated` API and the native driver.
- Reanimated and Gesture Handler for animations and gestures that run on the UI thread.
- Respecting the reduce-motion setting.

**Practice:** Animate adding a recipe to favourites with a swipe gesture.

**Learn from:**

- [Animations](https://reactnative.dev/docs/animations)
- [React Native Reanimated](https://docs.swmansion.com/react-native-reanimated/)

## react-native/accessibility: Accessibility

**Stage:** intermediate · **Needs:** react-native/components, foundations/accessibility

- `accessibilityLabel`, `accessibilityRole`, `accessibilityState` and hints.
- Font scaling, focus order and announcing changes to screen readers.
- Testing with VoiceOver and TalkBack.

**Practice:** Make the recipe app usable with VoiceOver and TalkBack only.

**Learn from:**

- [Accessibility](https://reactnative.dev/docs/accessibility)

## react-native/platform-code: Platform-specific code

**Stage:** intermediate · **Needs:** react-native/components

- The `Platform` module and `.ios.tsx` / `.android.tsx` files.
- Permissions on both platforms through Expo modules.
- Following each platform's conventions where they differ.

**Practice:** Use a different date picker on iOS and Android behind one component.

**Learn from:**

- [Platform-specific code](https://reactnative.dev/docs/platform-specific-code)
- [Permissions (Expo)](https://docs.expo.dev/guides/permissions/)

## react-native/testing: Testing

**Stage:** intermediate · **Needs:** react-native/state, foundations/testing

- Jest for logic, React Native Testing Library for components.
- Mocking native modules and the network.
- End-to-end tests on a simulator for the few flows that matter most.

**Practice:** Test the favourites reducer and the list screen, including the error state.

**Learn from:**

- [Testing (React Native)](https://reactnative.dev/docs/testing-overview)
- [Getting started with Jest](https://jestjs.io/docs/getting-started)
- [React Native Testing Library](https://oss.callstack.com/react-native-testing-library/)

## react-native/debugging: Debugging

**Stage:** intermediate · **Needs:** react-native/setup

- React Native DevTools: console, breakpoints, React components and the profiler.
- Reading red screens, native crash logs and Metro errors.
- Inspecting network requests.

**Practice:** Set a breakpoint in a component, inspect its props and find a re-render you did not expect.

**Learn from:**

- [Debugging basics](https://reactnative.dev/docs/debugging)
- [React Native DevTools](https://reactnative.dev/docs/react-native-devtools)

## react-native/builds: Building and submitting with EAS

**Stage:** intermediate · **Needs:** react-native/setup, foundations/app-stores

- EAS Build for signed iOS and Android builds without managing the native toolchains yourself.
- Build profiles for development, preview and production.
- EAS Submit to TestFlight and Google Play.

**Practice:** Build the recipe app for both stores and submit it to TestFlight and internal testing.

**Learn from:**

- [EAS Build](https://docs.expo.dev/build/introduction/)
- [EAS Submit](https://docs.expo.dev/deploy/submit-to-app-stores/)
- [Publishing to app stores (React Native)](https://reactnative.dev/docs/publishing-to-app-store)

## react-native/upgrades: Upgrading React Native and Expo

**Stage:** intermediate · **Needs:** react-native/builds, foundations/versioning

- Expo SDK upgrades, which bring a matching React Native version.
- The upgrade helper for projects without Expo.
- Reading release notes and checking libraries before upgrading.

**Practice:** Upgrade an app by one Expo SDK version and fix what the upgrade breaks.

**Learn from:**

- [Upgrade Expo SDK](https://docs.expo.dev/workflow/upgrading-expo-sdk-walkthrough/)
- [Upgrading to new versions](https://reactnative.dev/docs/upgrading)

## react-native/native-modules: Native modules

**Stage:** advanced · **Needs:** react-native/new-architecture, react-native/platform-code

- The Expo Modules API for writing modules in Swift and Kotlin.
- Turbo Native Modules and Codegen in projects without Expo.
- Native views and Fabric components.

**Practice:** Write a module that reads the battery level in Swift and Kotlin and call it from TypeScript.

**Learn from:**

- [Expo Modules API](https://docs.expo.dev/modules/overview/)
- [Turbo Native Modules](https://reactnative.dev/docs/turbo-native-modules-introduction)

## react-native/performance: Performance

**Stage:** advanced · **Needs:** react-native/debugging, react-native/lists

- Hermes, the JavaScript engine, and what affects startup.
- Profiling JavaScript and native work, and finding unneeded re-renders.
- The React Compiler, which memoizes components automatically.

**Practice:** Profile the recipe list, remove the unneeded re-renders and measure again.

**Learn from:**

- [Performance overview](https://reactnative.dev/docs/performance)
- [Using Hermes](https://reactnative.dev/docs/hermes)
- [React Compiler](https://react.dev/learn/react-compiler)

## react-native/updates: Over-the-air updates

**Stage:** advanced · **Needs:** react-native/builds

- EAS Update: shipping JavaScript and assets without a store release.
- Runtime versions, so an update only reaches builds with matching native code.
- Rollouts, rollbacks and the store rules for what an update may change.

**Practice:** Publish an update to a preview channel, roll it out to 10% and roll it back.

**Learn from:**

- [EAS Update](https://docs.expo.dev/eas-update/introduction/)
- [Runtime versions and updates](https://docs.expo.dev/eas-update/runtime-versions/)

## react-native/brownfield: Adding React Native to an existing app

**Stage:** advanced · **Needs:** react-native/native-modules

- Embedding React Native screens in an existing iOS or Android app.
- Sharing navigation and data with the native code.
- Incremental adoption, one screen at a time.

**Practice:** Show one React Native screen inside a native iOS app.

**Learn from:**

- [Integration with existing apps](https://reactnative.dev/docs/integration-with-existing-apps)
