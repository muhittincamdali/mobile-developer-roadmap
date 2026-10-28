/// A part of the roadmap with its own file, `roadmap/<rawValue>.md`.
///
/// The cases are in reading order: the shared foundations first, then the four platforms, then
/// the engineering topics that apply to all of them. Learning plans use this order to break ties.
public enum Track: String, CaseIterable, Sendable, Codable, Comparable {
    case foundations
    case ios
    case android
    case flutter
    case reactNative = "react-native"
    case engineering

    /// The name shown to people.
    public var displayName: String {
        switch self {
        case .foundations: "Foundations"
        case .ios: "iOS"
        case .android: "Android"
        case .flutter: "Flutter"
        case .reactNative: "React Native"
        case .engineering: "Engineering practice"
        }
    }

    /// The file name inside the roadmap folder, such as `react-native.md`.
    public var fileName: String { rawValue + ".md" }

    var rank: Int { Self.allCases.firstIndex(of: self) ?? 0 }

    public static func < (lhs: Track, rhs: Track) -> Bool {
        lhs.rank < rhs.rank
    }
}

/// How far into the roadmap a topic sits. A topic may only need topics of the same or an earlier
/// stage, so following the stages in order never asks for something that comes later.
public enum Stage: String, CaseIterable, Sendable, Codable, Comparable {
    case beginner
    case intermediate
    case advanced

    var rank: Int { Self.allCases.firstIndex(of: self) ?? 0 }

    public static func < (lhs: Stage, rhs: Stage) -> Bool {
        lhs.rank < rhs.rank
    }
}
