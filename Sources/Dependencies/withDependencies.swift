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
public import Dependency_Primitives

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
    var l1Values = Dependency_Primitives.Dependency.Scope.current
    return try Witness.Context.with({ witnessValues in
        var depValues = __DependencyValues(
            _witnessValues: witnessValues,
            _l1Values: l1Values
        )
        modify(&depValues)
        witnessValues = depValues._witnessValues
        l1Values = depValues._l1Values
    }, operation: { () throws(E) -> T in
        try Dependency_Primitives.Dependency.Scope.with({ $0 = l1Values }, operation: operation)
    })
}

/// Executes an async operation with modified dependency values.
///
/// This overload preserves actor isolation, allowing the operation to run
/// in the caller's isolation context.
///
/// - Parameters:
///   - isolation: The actor isolation context for the operation.
///   - modify: A closure that modifies the dependency values for the scope.
///   - operation: The async operation to execute with the modified values.
/// - Returns: The result of the operation.
/// - Throws: The typed error from the operation.
@inlinable
public func withDependencies<T, E: Error>(
    isolation: isolated (any Actor)? = #isolation,
    _ modify: (inout __DependencyValues) -> Void,
    operation: () async throws(E) -> T
) async throws(E) -> T {
    var l1Values = Dependency_Primitives.Dependency.Scope.current
    return try await Witness.Context.with(isolation: isolation, { witnessValues in
        var depValues = __DependencyValues(
            _witnessValues: witnessValues,
            _l1Values: l1Values
        )
        modify(&depValues)
        witnessValues = depValues._witnessValues
        l1Values = depValues._l1Values
    }, operation: { () async throws(E) -> T in
        try await Dependency_Primitives.Dependency.Scope.with({ $0 = l1Values }, operation: operation)
    })
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
    var l1Values = Dependency_Primitives.Dependency.Scope.current
    l1Values.isTestContext = (mode == .test)
    return try Witness.Context.with(mode: mode, { witnessValues in
        if let modify {
            var depValues = __DependencyValues(
                _witnessValues: witnessValues,
                _l1Values: l1Values
            )
            modify(&depValues)
            witnessValues = depValues._witnessValues
            l1Values = depValues._l1Values
        }
    }, operation: { () throws(E) -> T in
        try Dependency_Primitives.Dependency.Scope.with({ $0 = l1Values }, operation: operation)
    })
}

/// Executes an async operation with modified dependency values and mode.
///
/// - Parameters:
///   - isolation: The actor isolation context for the operation.
///   - mode: The execution mode for the scope.
///   - modify: A closure that modifies the dependency values for the scope.
///   - operation: The async operation to execute with the modified values.
/// - Returns: The result of the operation.
/// - Throws: The typed error from the operation.
@inlinable
public func withDependencies<T, E: Error>(
    isolation: isolated (any Actor)? = #isolation,
    mode: __DependencyContext.Mode,
    _ modify: ((inout __DependencyValues) -> Void)? = nil,
    operation: () async throws(E) -> T
) async throws(E) -> T {
    var l1Values = Dependency_Primitives.Dependency.Scope.current
    l1Values.isTestContext = (mode == .test)
    return try await Witness.Context.with(isolation: isolation, mode: mode, { witnessValues in
        if let modify {
            var depValues = __DependencyValues(
                _witnessValues: witnessValues,
                _l1Values: l1Values
            )
            modify(&depValues)
            witnessValues = depValues._witnessValues
            l1Values = depValues._l1Values
        }
    }, operation: { () async throws(E) -> T in
        try await Dependency_Primitives.Dependency.Scope.with({ $0 = l1Values }, operation: operation)
    })
}
