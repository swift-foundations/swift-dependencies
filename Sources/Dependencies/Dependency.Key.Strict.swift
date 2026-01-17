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

public import Witnesses

/// Hoisted protocol for fail-fast dependency keys.
///
/// - Note: Use ``Dependency.Key.Strict`` in user code.
public protocol __DependencyKeyStrict: Witness.Key {}

extension __DependencyKeyStrict {
    /// Default testValue triggers a fatal error.
    ///
    /// Override `testValue` with `.unimplemented()` for proper source tracking:
    ///
    /// ```swift
    /// extension PaymentProcessor: Dependency.Key.Strict {
    ///     static var liveValue: PaymentProcessor { .live }
    ///     static var testValue: PaymentProcessor { .unimplemented() }
    /// }
    /// ```
    public static var testValue: Value {
        fatalError(
            """
            '\(Self.self)' is a strict dependency that must be explicitly overridden in tests.

            Override in your test:
                withDependencies {
                    $0[\(Self.self).self] = .testDouble
                } operation: {
                    // ...
                }
            """
        )
    }
}

extension Dependency.Key {
    /// Marker protocol for dependencies that must be explicitly overridden in tests.
    ///
    /// Unlike standard `Dependency.Key` which falls back to `liveValue`,
    /// `Strict` keys trigger a fatal error in test mode if accessed without
    /// an explicit override.
    ///
    /// ## When to Use
    ///
    /// Use `Strict` for dependencies that:
    /// - Should never use live implementations in tests
    /// - Require explicit test doubles
    /// - Have side effects that must be controlled
    ///
    /// ## Example
    ///
    /// ```swift
    /// @Witness
    /// struct PaymentProcessor {
    ///     var charge: (Amount) async throws(Dependency.Error) -> Receipt
    /// }
    ///
    /// extension PaymentProcessor: Dependency.Key.Strict {
    ///     static var liveValue: PaymentProcessor { .live }
    ///     // testValue defaults to fatalError - must override in tests
    /// }
    ///
    /// // In tests - must override or test fails immediately
    /// withDependencies {
    ///     $0.paymentProcessor = .mock  // Required!
    /// } operation: {
    ///     // ...
    /// }
    /// ```
    ///
    /// ## Source Tracking
    ///
    /// For proper source location tracking in test failures, override
    /// `testValue` with `.unimplemented()`:
    ///
    /// ```swift
    /// extension PaymentProcessor: Dependency.Key.Strict {
    ///     static var liveValue: PaymentProcessor { .live }
    ///     static var testValue: PaymentProcessor { .unimplemented() }
    /// }
    /// ```
    public typealias Strict = __DependencyKeyStrict
}
