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

/// Property wrapper for dependency access with KeyPath syntax.
///
/// Use `@Dependency` to access dependencies in a type-safe manner:
///
/// ```swift
/// @Dependency(\.clock) var clock
/// @Dependency(\.apiClient) var apiClient
/// ```
///
/// ## KeyPath-Based Access
///
/// The KeyPath references a computed property on ``Dependency.Values``:
///
/// ```swift
/// extension Dependency.Values {
///     var clock: ContinuousClock {
///         get { self[ContinuousClock.self] }
///         set { self[ContinuousClock.self] = newValue }
///     }
/// }
/// ```
///
/// ## Nested Types
///
/// `Dependency` serves as both a property wrapper and a namespace:
/// - ``Dependency/Values``: Container for dependency values
/// - ``Dependency/Context``: Execution context and mode detection
/// - ``Dependency/Key``: Protocol for defining dependencies
/// - ``Dependency/Error``: Error type for unimplemented dependencies
///
/// ## Source Location Tracking
///
/// The property wrapper captures the file and line where it's declared,
/// enabling clear diagnostics when unimplemented dependencies are accessed.
///
/// ## Thread Safety
///
/// Dependency access is thread-safe via TaskLocal storage in ``Witness.Context``.
@propertyWrapper
public struct Dependency<Value: Sendable>: Sendable {
    @usableFromInline
    nonisolated(unsafe) internal let keyPath: KeyPath<__DependencyValues, Value>

    @usableFromInline
    internal let fileID: StaticString

    @usableFromInline
    internal let line: UInt

    /// Creates a dependency property wrapper.
    ///
    /// - Parameters:
    ///   - keyPath: KeyPath to the dependency value on ``Dependency.Values``.
    ///   - fileID: The file where the dependency is declared (auto-captured).
    ///   - line: The line where the dependency is declared (auto-captured).
    @inlinable
    public init(
        _ keyPath: KeyPath<__DependencyValues, Value>,
        fileID: StaticString = #fileID,
        line: UInt = #line
    ) {
        self.keyPath = keyPath
        self.fileID = fileID
        self.line = line
    }

    /// The current value of the dependency.
    ///
    /// Resolves the value from the current ``Dependency.Context``.
    @inlinable
    public var wrappedValue: Value {
        __DependencyContext.current[keyPath: keyPath]
    }
}

// MARK: - Typealiases (Nest.Name API)

extension Dependency {
    /// Container for dependency values.
    ///
    /// - Note: Typealias to module-level ``__DependencyValues`` due to Swift's
    ///   limitation on referencing nested types in generic contexts.
    public typealias Values = __DependencyValues

    /// Execution context and mode detection.
    ///
    /// - Note: Typealias to module-level ``__DependencyContext`` due to Swift's
    ///   limitation on referencing nested types in generic contexts.
    public typealias Context = __DependencyContext
}
