// swift-tools-version: 6.3.3

// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-dependencies open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-dependencies
// project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import PackageDescription

let package = Package(
    name: "swift-dependencies",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Dependencies",
            targets: ["Dependencies"]
        ),
        .library(
            name: "Dependencies Test Support",
            targets: ["Dependencies Test Support"]
        ),
    ],
    traits: [
        // TEMPORARY (dies at the E-program app cutover): no-op trait retained
        // SOLELY for the app's frozen `traits: ["Clocks"]` argument — SwiftPM
        // rejects a trait argument against a package that declares no traits.
        // Every institute consumer dropped its trait argument in W3 R-a
        // (2026-07-14); the app's line is the last holdout and is frozen until
        // its cutover wave.
        .trait(name: "Clocks"),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-foundations/swift-witnesses.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-environment.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Dependencies",
            dependencies: [
                .product(name: "Witnesses", package: "swift-witnesses"),
                .product(name: "Environment", package: "swift-environment"),
            ],
            path: "Sources/Dependencies"
        ),
        .target(
            name: "Dependencies Test Support",
            dependencies: [
                "Dependencies",
                .product(name: "Witnesses", package: "swift-witnesses"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Dependencies Tests",
            dependencies: [
                "Dependencies",
                "Dependencies Test Support",
                .product(name: "Witnesses", package: "swift-witnesses"),
            ],
            path: "Tests/Dependencies Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
