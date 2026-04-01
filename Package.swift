// swift-tools-version: 6.3

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
        .library(
            name: "Clocks Dependency",
            targets: ["Clocks Dependency"]
        ),
    ],
    traits: [
        .trait(name: "Clocks"),
    ],
    dependencies: [
        .package(path: "../swift-witnesses"),
        .package(path: "../swift-environment"),
        .package(path: "../../swift-primitives/swift-clock-primitives"),
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
        // MARK: - Integration
        .target(
            name: "Clocks Dependency",
            dependencies: [
                "Dependencies",
                .product(name: "Clock Primitives", package: "swift-clock-primitives",
                         condition: .when(traits: ["Clocks"])),
            ]
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
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
