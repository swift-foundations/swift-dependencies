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

extension Dependency {
    /// Protocol for defining dependencies.
    ///
    /// `Dependency.Key` is a typealias to `Witness.Key`, providing the standard
    /// dependency resolution chain:
    ///
    /// ```
    /// testValue → previewValue → liveValue
    /// ```
    ///
    /// ## Defining a Dependency
    ///
    /// ```swift
    /// struct APIClient: Dependency.Key {
    ///     static var liveValue: APIClient { APIClient.live }
    ///     static var testValue: APIClient { APIClient.mock }
    /// }
    /// ```
    ///
    /// ## KeyPath Access
    ///
    /// Register dependencies for KeyPath access:
    ///
    /// ```swift
    /// extension Dependency.Values {
    ///     var apiClient: APIClient {
    ///         get { self[APIClient.self] }
    ///         set { self[APIClient.self] = newValue }
    ///     }
    /// }
    /// ```
    ///
    /// - Note: For fail-fast behavior in tests, use ``Dependency.Key.Strict``.
    public typealias Key = Witness.Key
}
