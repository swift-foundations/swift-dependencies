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

public import Dependencies
public import Testing

extension Dependency.Test {
    /// Assert that the current mode matches the expected mode.
    ///
    /// ```swift
    /// Dependency.Test.assertMode(.test)
    /// ```
    ///
    /// - Parameter expected: The expected dependency mode.
    /// - Parameter sourceLocation: The source location for failure reporting.
    @inlinable
    public static func assertMode(
        _ expected: Dependency<Never>.Context.Mode,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        let actual = Dependency<Never>.Context.mode
        #expect(
            actual == expected,
            "Expected mode \(expected) but got \(actual)",
            sourceLocation: sourceLocation
        )
    }

    /// Assert that a dependency has a specific value.
    ///
    /// ```swift
    /// Dependency.Test.assertValue(\.simple, equals: "test-value")
    /// ```
    ///
    /// - Parameters:
    ///   - keyPath: KeyPath to the dependency value.
    ///   - expected: The expected value.
    ///   - sourceLocation: The source location for failure reporting.
    @inlinable
    public static func assertValue<V: Equatable & Sendable>(
        _ keyPath: KeyPath<Dependency<Never>.Values, V>,
        equals expected: V,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        let actual = Dependency<Never>.Context.current[keyPath: keyPath]
        #expect(
            actual == expected,
            "Dependency value mismatch",
            sourceLocation: sourceLocation
        )
    }
}
