import Foundation

/// Which links a topic may use as resources.
///
/// The roadmap points to primary sources: the documentation of the platform, language or tool a
/// topic is about, standards bodies and the projects' own repositories. Blogs, courses, videos
/// behind sign-up walls and personal repositories are not accepted, so a resource list cannot
/// turn into advertising and every link stays as current as the documentation it points to.
public struct SourcePolicy: Sendable, Equatable {
    /// Hosts whose every page is accepted. A host matches itself only, not its subdomains.
    public var hosts: Set<String>
    /// `host/path` prefixes for hosts that also serve unrelated pages, such as `github.com/swiftlang/`.
    public var pathPrefixes: [String]

    public init(hosts: Set<String>, pathPrefixes: [String] = []) {
        self.hosts = hosts
        self.pathPrefixes = pathPrefixes
    }

    /// The sources the roadmap files use.
    public static let primarySources = SourcePolicy(
        hosts: [
            // Apple and Swift
            "developer.apple.com", "docs.swift.org", "www.swift.org",
            // Android and Kotlin
            "developer.android.com", "source.android.com", "kotlinlang.org", "docs.gradle.org",
            "firebase.google.com", "m3.material.io",
            // Flutter and Dart
            "docs.flutter.dev", "dart.dev", "pub.dev",
            // React Native, React, Expo and the web platform
            "reactnative.dev", "react.dev", "docs.expo.dev", "developer.mozilla.org",
            "www.typescriptlang.org", "nodejs.org", "jestjs.io", "reactnavigation.org",
            "docs.swmansion.com",
            // Tools, standards and security
            "git-scm.com", "docs.github.com", "semver.org", "www.w3.org", "www.rfc-editor.org",
            "mas.owasp.org", "owasp.org", "cheatsheetseries.owasp.org", "opentelemetry.io",
            "docs.fastlane.tools", "www.conventionalcommits.org", "c4model.com", "adr.github.io",
        ],
        pathPrefixes: [
            "github.com/swiftlang/",
            "github.com/apple/",
            "github.com/android/",
            "github.com/flutter/",
            "github.com/facebook/react-native/",
            "github.com/react-native-community/",
            "github.com/OWASP/",
            "play.google/developer-content-policy",
            "support.google.com/googleplay/",
            "google.github.io/eng-practices/",
            "oss.callstack.com/react-native-testing-library/",
        ]
    )

    /// Why `url` is not accepted, or `nil` when it is.
    public func problem(with url: String) -> String? {
        guard let components = URLComponents(string: url), components.scheme == "https",
              let host = components.host?.lowercased(), !host.isEmpty else {
            return "must be an https URL"
        }
        if components.user != nil || components.password != nil {
            return "must not contain a user name or password"
        }
        if let items = components.queryItems, items.contains(where: { $0.name.lowercased().hasPrefix("utm_") }) {
            return "must not carry tracking parameters (utm_…)"
        }
        if components.port != nil {
            return "must not name a port"
        }
        // Browsers resolve `.` and `..` segments, also when written as `%2e`, before sending the
        // request, so `github.com/apple/../evil` would open `github.com/evil` while still matching
        // the `github.com/apple/` prefix. `path` is already percent-decoded.
        if components.path.split(separator: "/", omittingEmptySubsequences: false)
            .contains(where: { $0 == "." || $0 == ".." }) {
            return "must not contain `.` or `..` path segments"
        }
        if hosts.contains(host) { return nil }
        let hostAndPath = host + components.path
        if pathPrefixes.contains(where: { hostAndPath.hasPrefix($0) }) { return nil }
        return "is not a primary source (see SourcePolicy in Sources/RoadmapKit/SourcePolicy.swift)"
    }
}
