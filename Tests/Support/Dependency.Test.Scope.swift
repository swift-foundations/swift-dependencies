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
public import Witnesses

extension Dependency {
    /// Test utilities for dependency injection.
    public enum Test {}
}

extension Dependency.Test {
    /// Execute an operation in test mode with dependency overrides.
    ///
    /// Convenience wrapper that sets mode to `.test` automatically:
    ///
    /// ```swift
    /// try await Dependency.Test.withOverrides {
    ///     $0.apiClient = .mock
    ///     $0.database = .inMemory
    /// } operation: {
    ///     // Dependencies resolve to test values
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - modify: Closure to configure dependency overrides.
    ///   - operation: The test operation to execute.
    /// - Returns: The result of the operation.
    /// - Throws: The typed error from the operation.
    public static func withOverrides<T, E: Error>(
        _ modify: @escaping (inout __DependencyValues) -> Void,
        operation: () throws(E) -> T
    ) throws(E) -> T {
        try Witness.Context.with(mode: .test, { witnessValues in
            var depValues = __DependencyValues(_witnessValues: witnessValues)
            modify(&depValues)
            witnessValues = depValues._witnessValues
        }, operation: operation)
    }

    /// Execute an async operation in test mode with dependency overrides.
    ///
    /// - Parameters:
    ///   - modify: Closure to configure dependency overrides.
    ///   - operation: The async test operation to execute.
    /// - Returns: The result of the operation.
    /// - Throws: The typed error from the operation.
    public static func withOverrides<T, E: Error>(
        isolation: isolated (any Actor)? = #isolation,
        _ modify: @escaping (inout __DependencyValues) -> Void,
        operation: () async throws(E) -> T
    ) async throws(E) -> T {
        try await Witness.Context.with(isolation: isolation, mode: .test, { witnessValues in
            var depValues = __DependencyValues(_witnessValues: witnessValues)
            modify(&depValues)
            witnessValues = depValues._witnessValues
        }, operation: operation)
    }
}
