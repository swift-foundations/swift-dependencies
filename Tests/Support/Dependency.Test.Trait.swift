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
public import Witnesses

/// Hoisted type for ``Dependency.Test._Trait``.
///
/// - Note: This type is at module level due to Swift's limitation on
///   `@TaskLocal` in generic contexts. Use ``Dependency.Test._Trait`` in API usage.
@_documentation(visibility: private)
public struct __DependencyTestTrait: TestScoping, TestTrait, SuiteTrait {
    /// Closure that modifies dependency values for the test scope.
    let updateValues: @Sendable (inout __DependencyValues) -> Void

    /// Tracks whether this is the root trait in the hierarchy.
    @TaskLocal static var isRoot = true

    /// Indicates that this trait should propagate to nested tests.
    public var isRecursive: Bool { true }

    /// Provides the scoped context for test execution.
    public func provideScope(
        for test: Testing.Test,
        testCase: Testing.Test.Case?,
        performing function: @Sendable () async throws -> Void
    ) async throws {
        try await Witness.Context.with(isolation: nil, mode: .test, { witnessValues in
            if Self.isRoot {
                witnessValues = Witness.Values()
            }
            var depValues = __DependencyValues(_witnessValues: witnessValues)
            updateValues(&depValues)
            witnessValues = depValues._witnessValues
        }) {
            try await Self.$isRoot.withValue(false) {
                try await function()
            }
        }
    }
}

extension Dependency.Test {
    /// Typealias to the hoisted trait type.
    ///
    /// - Note: Typealias to module-level ``__DependencyTestTrait`` due to Swift's
    ///   limitation on `@TaskLocal` in generic contexts.
    public typealias _Trait = __DependencyTestTrait
}
#endif
