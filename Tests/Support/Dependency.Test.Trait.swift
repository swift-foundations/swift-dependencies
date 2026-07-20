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
public import Dependency_Primitives
public import Witnesses

/// Hoisted type for ``Dependency.Test._Trait``.
///
/// - Note: This type is at module level due to Swift's limitation on
///   `@TaskLocal` in generic contexts. Use ``Dependency.Test._Trait`` in API usage.
@_documentation(visibility: private)
public struct __DependencyTestTrait: TestScoping, TestTrait, SuiteTrait {
    /// Closure that modifies dependency values for the test scope.
    let updateValues: @Sendable (inout __DependencyValues) -> Void
}

extension __DependencyTestTrait {
    /// Tracks whether this is the root trait in the hierarchy.
    @TaskLocal static var isRoot = true

    /// Indicates that this trait should propagate to nested tests.
    public var isRecursive: Bool { true }

    /// Provides the scoped context for test execution.
    ///
    /// - Note: Adopts the same two-store scope mechanism as `withDependencies`
    ///   (``Witness/Context/_withScope(mode:_:operation:)-5f2ep``), pushing both
    ///   L1 (`Dependency_Primitives.Dependency.Values`) and L2/L3 (`Witness.Values`)
    ///   modifications into scope. At the root trait, both stores are reset so a
    ///   test does not inherit L1 state from an enclosing (non-test) scope.
    @concurrent public func provideScope(
        for test: Testing.Test,
        testCase: Testing.Test.Case?,
        performing function: @Sendable @concurrent () async throws -> Void
    ) async throws {
        try await Witness.Context._withScope(
            mode: .test,
            { witnessValues, l1Values in
                if Self.isRoot {
                    witnessValues = Witness.Values()
                    // `.forTesting()`, not `.init()`: this trait always scopes with
                    // `mode: .test`, and a bare `.init()` would clear the
                    // `isTestContext` flag that `_withScope` had just set moments
                    // earlier from that mode, silently flipping L1-only keys with
                    // no explicit override back to `liveValue` inside a test.
                    l1Values = Dependency_Primitives.Dependency.Values.forTesting()
                }
                var depValues = __DependencyValues(_witnessValues: witnessValues, _l1Values: l1Values)
                updateValues(&depValues)
                witnessValues = depValues._witnessValues
                l1Values = depValues._l1Values
            },
            operation: {
                try await Self.$isRoot.withValue(false) {
                    try await function()
                }
            }
        )
    }
}

extension Dependencies.Dependency.Test {
    /// Typealias to the hoisted trait type.
    ///
    /// - Note: Typealias to module-level ``__DependencyTestTrait`` due to Swift's
    ///   limitation on `@TaskLocal` in generic contexts.
    public typealias _Trait = __DependencyTestTrait
}
#endif
