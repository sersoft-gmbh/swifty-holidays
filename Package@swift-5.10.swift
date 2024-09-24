// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let swiftSettings: Array<SwiftSetting> = [
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("BareSlashRegexLiterals"),
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableUpcomingFeature("IsolatedDefaultValues"),
    .enableUpcomingFeature("DeprecateApplicationMain"),
    .enableExperimentalFeature("StrictConcurrency"),
    .enableExperimentalFeature("GlobalConcurrency"),
    .enableExperimentalFeature("AccessLevelOnImport"),
]

let package = Package(
    name: "swifty-holidays",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v12),
        .tvOS(.v12),
        .watchOS(.v4),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SwiftyHolidays",
            targets: ["SwiftyHolidays"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SwiftyHolidays",
            swiftSettings: swiftSettings),
        .testTarget(
            name: "SwiftyHolidaysTests",
            dependencies: ["SwiftyHolidays"],
            swiftSettings: swiftSettings),
    ]
)
