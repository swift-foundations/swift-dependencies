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

/// Hoisted type for ``Dependency.Values``.
///
/// - Note: This type is at module level due to Swift's limitation on referencing
///   nested types in generic contexts. Use ``Dependency.Values`` in all API usage.
public struct __DependencyValues: Sendable {
    /// The underlying witness values.
    ///
    /// - Note: Public for use by test support infrastructure.
    public var _witnessValues: Witness.Values

    /// L1 dependency values for direct write-through to `Dependency.Scope`.
    ///
    /// When an L1-only key is set via the `__DependencyKey` subscript, the
    /// value is written directly into this struct. `withDependencies`
    /// unconditionally pushes these values into `Dependency.Scope.with`
    /// to make overrides visible to L1/L2 code.
    ///
    /// Module-qualified type disambiguates from this module's
    /// `Dependency.Values` typealias (which is `__DependencyValues`).
    public var _l1Values: Dependency_Primitives.Dependency.Values

    /// Creates a values container wrapping existing witness values.
    ///
    /// - Note: This initializer is public for use by test support infrastructure.
    @inlinable
    public init(
        _witnessValues: Witness.Values = Witness.Values(),
        _l1Values: Dependency_Primitives.Dependency.Values = .init()
    ) {
        self._witnessValues = _witnessValues
        self._l1Values = _l1Values
    }
}

extension __DependencyValues {
    /// Accesses the value for the given key type.
    ///
    /// For get operations without explicit mode, uses the current context's mode.
    /// For set operations, stores the value as an explicit override.
    ///
    /// - Parameter key: The key type identifying the dependency.
    /// - Returns: The value for the key.
    @inlinable
    public subscript<K: Witness.Key>(key: K.Type) -> K.Value where K.Value: Copyable {
        get { Witness.Context[key] }
        set { _witnessValues[key] = newValue }
    }
}

extension __DependencyValues {
    /// Accesses the value for an L1-only dependency key.
    ///
    /// **Get**: Reads directly from the L1 values struct.
    ///
    /// **Set**: Writes directly to the L1 values struct. `withDependencies`
    /// pushes these values into `Dependency.Scope` unconditionally.
    ///
    /// - Note: When `K` also conforms to `Witness.Key`, the more specific
    ///   `Witness.Key` subscript is selected by overload resolution.
    @inlinable
    public subscript<K: __DependencyKey>(key: K.Type) -> K.Value where K.Value: Copyable {
        get { _l1Values[K.self] }
        set { _l1Values[K.self] = newValue }
    }
}
