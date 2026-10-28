import RoadmapKit
import SwiftUI

@main
struct RoadmapExplorerApp: App {
    @State private var model = ExplorerModel.bundled()

    var body: some Scene {
        WindowGroup {
            RootView(initialScreen: LaunchScreen(arguments: UserDefaults.standard))
                .environment(model)
                .tint(.roadmapBlue)
        }
    }
}

/// Which screen to open at launch. The screenshot script passes `-screen topic:ios/liquid-glass`
/// or `-screen path:ios/swift-6-mode`; a normal launch opens the track list.
enum LaunchScreen: Equatable {
    case tracks
    case topic(String)
    case path(String)

    init(arguments: UserDefaults) {
        let value = arguments.string(forKey: "screen") ?? ""
        if value.hasPrefix("topic:") {
            self = .topic(String(value.dropFirst("topic:".count)))
        } else if value.hasPrefix("path:") {
            self = .path(String(value.dropFirst("path:".count)))
        } else {
            self = .tracks
        }
    }
}

extension Color {
    /// The brand blue (#0071E3) used across the repository's graphics.
    static let roadmapBlue = Color(red: 0, green: 0x71 / 255, blue: 0xE3 / 255)
}

/// Navigation targets shared by both tabs.
enum Route: Hashable {
    case track(String)
    case topic(String)
    case path(String)
}

struct RootView: View {
    let initialScreen: LaunchScreen
    @State private var tab: Tab

    enum Tab: Hashable { case tracks, plan }

    init(initialScreen: LaunchScreen) {
        self.initialScreen = initialScreen
        if case .path = initialScreen {
            _tab = State(initialValue: .plan)
        } else {
            _tab = State(initialValue: .tracks)
        }
    }

    var body: some View {
        TabView(selection: $tab) {
            SwiftUI.Tab("Tracks", systemImage: "map", value: Tab.tracks) {
                TracksView(initialRoute: initialScreen.topicRoute)
            }
            SwiftUI.Tab("Plan", systemImage: "list.number", value: Tab.plan) {
                PlanView(initialRoute: initialScreen.pathRoute)
            }
        }
    }
}

private extension LaunchScreen {
    var topicRoute: Route? {
        if case .topic(let id) = self { return .topic(id) }
        return nil
    }

    var pathRoute: Route? {
        if case .path(let id) = self { return .path(id) }
        return nil
    }
}

/// The destination of every ``Route``.
struct RouteDestination: View {
    @Environment(ExplorerModel.self) private var model
    let route: Route

    var body: some View {
        switch route {
        case .track(let rawValue):
            if let track = Track(rawValue: rawValue) {
                TrackView(track: track)
            }
        case .topic(let id):
            if let topic = model.roadmap.topic(id: id) {
                TopicView(topic: topic)
            } else {
                ContentUnavailableView("No topic \(id)", systemImage: "questionmark.folder")
            }
        case .path(let id):
            PathView(goal: id)
        }
    }
}
