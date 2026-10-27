// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MobileDeveloperRoadmap",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(name: "RoadmapKit", targets: ["RoadmapKit"])
    ],
    targets: [
        .target(name: "RoadmapKit"),
        .testTarget(name: "RoadmapKitTests", dependencies: ["RoadmapKit"])
    ]
)
