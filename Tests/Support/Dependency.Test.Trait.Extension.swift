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

#if canImport(Testing) && compiler(>=6)
public import Testing
public import Dependencies
internal import Reference_Primitives

extension Trait where Self == __DependencyTestTrait {
    /// Isolates a test's dependencies from other tests.
    ///
    /// When applied to a `@Suite` or `@Test`, dependencies are reset
    /// and kept separate from any other suites/tests running in parallel.
    ///
    /// This is recommended for base suites to ensure test isolation:
    ///
    /// ```swift
    /// @Suite(.dependencies)
    /// struct FeatureTests {
    ///     @Test func feature() async {
    ///         // Dependencies are isolated
    ///     }
    /// }
    /// ```
    public static var dependencies: Self {
        Self { _ in }
    }

    /// Overrides a single dependency using a KeyPath.
    ///
    /// Use this to override individual dependencies declaratively on tests:
    ///
    /// ```swift
    /// @Test(.dependency(\.clock, .immediate))
    /// func timedFeature() async {
    ///     @Dependency(\.clock) var clock
    ///     // clock is .immediate
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - keyPath: KeyPath to the dependency value on `Dependency.Values`.
    ///   - value: The override value (lazily evaluated).
    /// - Returns: A trait that applies the override.
    public static func dependency<Value: Sendable>(
        _ keyPath: WritableKeyPath<__DependencyValues, Value>,
        _ value: @autoclosure @escaping @Sendable () -> Value
    ) -> Self {
        let kp = Reference.Sendability.Unchecked(__unchecked: keyPath)
        return Self { $0[keyPath: kp.value] = value() }
    }

    /// Overrides a dependency using a Key type where `Key.Value == Key`.
    ///
    /// This is useful for witness types that are both the key and value:
    ///
    /// ```swift
    /// @Witness
    /// struct APIClient: Sendable, Dependency.Key {
    ///     static var liveValue: APIClient { .live }
    ///     static var testValue: APIClient { .mock }
    ///     // ...
    /// }
    ///
    /// @Test(.dependency(APIClient.mock))
    /// func apiFeature() async {
    ///     @Dependency(APIClient.self) var api
    ///     // api is .mock
    /// }
    /// ```
    ///
    /// - Parameter value: The key/value to override (where `Key.Value == Key`).
    /// - Returns: A trait that applies the override.
    public static func dependency<Key: Witness.Key>(
        _ value: @autoclosure @escaping @Sendable () -> Key
    ) -> Self where Key.Value == Key {
        Self { $0[Key.self] = value() }
    }

    /// Overrides multiple dependencies via a closure.
    ///
    /// Use this when you need to override several dependencies at once:
    ///
    /// ```swift
    /// @Test(.dependencies {
    ///     $0.clock = .immediate
    ///     $0.apiClient = .mock
    ///     $0.database = .inMemory
    /// })
    /// func complexFeature() async {
    ///     // All dependencies overridden
    /// }
    /// ```
    ///
    /// - Parameter updateValues: Closure to modify dependency values.
    /// - Returns: A trait that applies the overrides.
    public static func dependencies(
        _ updateValues: @escaping @Sendable (inout __DependencyValues) -> Void
    ) -> Self {
        Self(updateValues: updateValues)
    }
}
#endif
