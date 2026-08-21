// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-dependencies",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
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
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
