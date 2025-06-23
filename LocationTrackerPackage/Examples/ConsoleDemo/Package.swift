// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LocationTrackerConsoleDemo",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "LocationTrackerConsoleDemo",
            targets: ["LocationTrackerConsoleDemo"]
        )
    ],
    dependencies: [
        .package(name: "LocationTracker", path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "LocationTrackerConsoleDemo",
            dependencies: [
                .product(name: "location-tracker", package: "location-tracker")
            ],
            path: "."
        )
    ]
)
