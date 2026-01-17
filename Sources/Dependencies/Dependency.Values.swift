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

/// Hoisted type for ``Dependency.Values``.
///
/// - Note: This type is at module level due to Swift's limitation on referencing
///   nested types in generic contexts. Use ``Dependency.Values`` in all API usage.
public struct __DependencyValues: Sendable {
    /// The underlying witness values.
    ///
    /// - Note: Public for use by test support infrastructure.
    public var _witnessValues: Witness.Values

    /// Creates an empty values container.
    @inlinable
    public init() {
        self._witnessValues = Witness.Values()
    }

    /// Creates a values container wrapping existing witness values.
    ///
    /// - Note: This initializer is public for use by test support infrastructure.
    @inlinable
    public init(_witnessValues: Witness.Values) {
        self._witnessValues = _witnessValues
    }

    /// Accesses the value for the given key type.
    ///
    /// For get operations without explicit mode, uses the current context's mode.
    /// For set operations, stores the value as an explicit override.
    ///
    /// - Parameter key: The key type identifying the dependency.
    /// - Returns: The value for the key.
    @inlinable
    public subscript<K: Witness.Key>(key: K.Type) -> K.Value {
        get { Witness.Context[key] }
        set { _witnessValues[key] = newValue }
    }
}
