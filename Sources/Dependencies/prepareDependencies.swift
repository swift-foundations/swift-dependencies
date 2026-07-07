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

/// Configures dependencies for a scope before first access.
///
/// Use this function at app startup to configure live implementations
/// that will be available throughout the operation:
///
/// ```swift
/// await prepareDependencies { store in
///     store.set(APIClient.self, value: .live(baseURL: config.apiURL))
///     store.set(Database.self, value: .sqlite(path: config.dbPath))
/// } operation: {
///     // Dependencies are now available throughout this scope
///     await runApp()
/// }
/// ```
///
/// ## Relationship to withDependencies
///
/// - `prepareDependencies`: One-time setup for app-wide defaults
/// - `withDependencies`: Scoped overrides for testing or specific contexts
///
/// Prepared values act as fallbacks. Explicit overrides via `withDependencies`
/// take precedence over prepared values.
///
/// ## Design
///
/// Per [API-IMPL-010], this uses TaskLocal storage rather than global state.
/// The preparation store is scoped to the current task tree and automatically
/// cleaned up when the scope exits.
///
/// - Parameters:
///   - configure: A closure that configures the preparation store.
///   - operation: The operation to execute with prepared values.
/// - Returns: The result of the operation.
/// - Throws: Rethrows any error from the operation.
nonisolated(nonsending)
    public func prepareDependencies<T, E: Swift.Error>(
        _ configure: (Witness.Preparation.Store) -> Void,
        operation: nonisolated(nonsending) () async throws(E) -> T
    ) async throws(E) -> T
{
    try await Witness.Preparation.with(configure, operation: operation)
}

/// Configures dependencies for a scope before first access (synchronous).
///
/// - Parameters:
///   - configure: A closure that configures the preparation store.
///   - operation: The operation to execute with prepared values.
/// - Returns: The result of the operation.
public func prepareDependencies<T, E: Swift.Error>(
    _ configure: (Witness.Preparation.Store) -> Void,
    operation: () throws(E) -> T
) throws(E) -> T {
    try Witness.Preparation.with(configure, operation: operation)
}
