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

public import Dependency_Primitives
public import Witnesses

/// Executes an operation with modified dependency values.
///
/// Use this function to override dependencies for a scoped operation:
///
/// ```swift
/// withDependencies {
///     $0[Clock.self] = .mock
/// } operation: {
///     // Clock.self resolves to .mock here
///     let clock = Dependency.Context.current[Clock.self]
/// }
/// ```
///
/// ## Typed Throws
///
/// Per [API-ERR-001], typed errors are preserved through the scope:
///
/// ```swift
/// func riskyOperation() throws(FileError) -> Data { ... }
///
/// let data = try withDependencies {
///     $0[FileSystem.self] = .mock
/// } operation: {
///     try riskyOperation()  // FileError preserved
/// }
/// ```
///
/// ## Nesting
///
/// Scopes can be nested. Inner scopes inherit and override outer values:
///
/// ```swift
/// withDependencies {
///     $0[A.self] = .one
/// } operation: {
///     withDependencies {
///         $0[B.self] = .two
///     } operation: {
///         // A.self = .one, B.self = .two
///     }
/// }
/// ```
///
/// - Parameters:
///   - modify: A closure that modifies the dependency values for the scope.
///   - operation: The operation to execute with the modified values.
/// - Returns: The result of the operation.
/// - Throws: The typed error from the operation.
@inlinable
public func withDependencies<T, E: Error>(
    _ modify: (inout __DependencyValues) -> Void,
    operation: () throws(E) -> T
) throws(E) -> T {
    try Witness.Context._withScope(
        { witnessValues, l1Values in
            var depValues = __DependencyValues(
                _witnessValues: witnessValues,
                _l1Values: l1Values
            )
            modify(&depValues)
            witnessValues = depValues._witnessValues
            l1Values = depValues._l1Values
        },
        operation: operation
    )
}

/// Executes an async operation with modified dependency values.
///
/// This overload preserves actor isolation, allowing the operation to run
/// in the caller's isolation context.
///
/// - Parameters:
///   - modify: A closure that modifies the dependency values for the scope.
///   - operation: The async operation to execute with the modified values.
/// - Returns: The result of the operation.
/// - Throws: The typed error from the operation.
@inlinable
nonisolated(nonsending)
    public func withDependencies<T, E: Error>(
        _ modify: (inout __DependencyValues) -> Void,
        operation: nonisolated(nonsending) () async throws(E) -> T
    ) async throws(E) -> T
{
    try await Witness.Context._withScope(
        { witnessValues, l1Values in
            var depValues = __DependencyValues(
                _witnessValues: witnessValues,
                _l1Values: l1Values
            )
            modify(&depValues)
            witnessValues = depValues._witnessValues
            l1Values = depValues._l1Values
        },
        operation: operation
    )
}

/// Executes an operation with modified dependency values and mode.
///
/// Use this overload to explicitly set the execution mode:
///
/// ```swift
/// withDependencies(mode: .test) {
///     $0[APIClient.self] = .mock
/// } operation: {
///     // All keys resolve to testValue by default
/// }
/// ```
///
/// - Parameters:
///   - mode: The execution mode for the scope.
///   - modify: A closure that modifies the dependency values for the scope.
///   - operation: The operation to execute with the modified values.
/// - Returns: The result of the operation.
/// - Throws: The typed error from the operation.
@inlinable
public func withDependencies<T, E: Error>(
    mode: __DependencyContext.Mode,
    _ modify: ((inout __DependencyValues) -> Void)? = nil,
    operation: () throws(E) -> T
) throws(E) -> T {
    try Witness.Context._withScope(
        mode: mode,
        { witnessValues, l1Values in
            if let modify {
                var depValues = __DependencyValues(
                    _witnessValues: witnessValues,
                    _l1Values: l1Values
                )
                modify(&depValues)
                witnessValues = depValues._witnessValues
                l1Values = depValues._l1Values
            }
        },
        operation: operation
    )
}

/// Executes an async operation with modified dependency values and mode.
///
/// - Parameters:
///   - mode: The execution mode for the scope.
///   - modify: A closure that modifies the dependency values for the scope.
///   - operation: The async operation to execute with the modified values.
/// - Returns: The result of the operation.
/// - Throws: The typed error from the operation.
@inlinable
nonisolated(nonsending)
    public func withDependencies<T, E: Error>(
        mode: __DependencyContext.Mode,
        _ modify: ((inout __DependencyValues) -> Void)? = nil,
        operation: nonisolated(nonsending) () async throws(E) -> T
    ) async throws(E) -> T
{
    try await Witness.Context._withScope(
        mode: mode,
        { witnessValues, l1Values in
            if let modify {
                var depValues = __DependencyValues(
                    _witnessValues: witnessValues,
                    _l1Values: l1Values
                )
                modify(&depValues)
                witnessValues = depValues._witnessValues
                l1Values = depValues._l1Values
            }
        },
        operation: operation
    )
}
