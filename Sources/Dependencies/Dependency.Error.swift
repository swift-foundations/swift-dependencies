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
    /// Error type for unimplemented dependencies.
    ///
    /// `Dependency.Error` is a typealias to `Witness.Unimplemented.Error`,
    /// providing source location tracking for unimplemented witness methods.
    ///
    /// ## Error Information
    ///
    /// The error includes:
    /// - Witness type name
    /// - Method/property name
    /// - File and line where the unimplemented call occurred
    ///
    /// ## Example
    ///
    /// ```swift
    /// @Witness
    /// struct APIClient {
    ///     var fetch: () async throws(Dependency.Error) -> Data
    /// }
    ///
    /// // In tests, calling an unimplemented method throws with location info
    /// let client = APIClient.unimplemented()
    /// try await client.fetch()  // throws Dependency.Error
    /// ```
    public typealias Error = Witness.Unimplemented.Error
}
