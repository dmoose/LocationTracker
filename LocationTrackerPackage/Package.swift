// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LocationTracker",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .watchOS(.v10),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "LocationTracker",
            targets: ["LocationTracker"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(path: "../../UtilityDesignSystem/UtilityDesignSystemPackage"),
        .package(path: "../../DefaultLogger")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "LocationTracker",
            dependencies: [
                .product(name: "UtilityDesignSystem", package: "UtilityDesignSystemPackage"),
                .product(name: "DefaultLogger", package: "DefaultLogger")
            ]
        ),
        .testTarget(
            name: "LocationTracker-tests",
            dependencies: ["LocationTracker"]),
    ]
)
