// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MobileDeveloperRoadmap",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(name: "RoadmapKit", targets: ["RoadmapKit"]),
        .executable(name: "roadmap", targets: ["roadmap"])
    ],
    targets: [
        .target(name: "RoadmapKit"),
        .target(name: "RoadmapCLI", dependencies: ["RoadmapKit"]),
        .executableTarget(name: "roadmap", dependencies: ["RoadmapCLI"]),
        .testTarget(name: "RoadmapKitTests", dependencies: ["RoadmapKit"]),
        .testTarget(name: "RoadmapCLITests", dependencies: ["RoadmapCLI"])
    ]
)
