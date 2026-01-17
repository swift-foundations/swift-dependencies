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
    /// Captures dependency context for use in escaping closures.
    ///
    /// `Continuation` is a typealias to `Witness.Context.Escaped`, enabling
    /// dependency context propagation to escaping closures like `DispatchQueue.async`,
    /// delegate callbacks, or timers.
    ///
    /// ## Example
    ///
    /// ```swift
    /// func setupTimer() {
    ///     Dependency.Context.withEscaped { escaped in
    ///         Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
    ///             escaped.yield {
    ///                 @Dependency(\.logger) var logger
    ///                 logger.log("Timer fired")
    ///             }
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## When to Use
    ///
    /// Use `Continuation` when you need dependency context in:
    /// - `DispatchQueue.async` or `DispatchQueue.main.async` blocks
    /// - Timer callbacks
    /// - Delegate methods
    /// - Notification observers
    /// - Any closure that outlives the current scope
    public typealias Continuation = Witness.Context.Escaped
}

// MARK: - Context Extension

extension __DependencyContext {
    /// Capture the current dependency context for use in escaping closures.
    ///
    /// - Parameter operation: A closure that receives the captured context.
    /// - Returns: The result of the operation.
    /// - Throws: The typed error from the operation.
    @inlinable
    public static func withEscaped<R, E: Error>(
        _ operation: (Dependency<Never>.Continuation) throws(E) -> R
    ) throws(E) -> R {
        try Witness.Context.withEscaped(operation)
    }

    /// Capture the current dependency context for use in escaping async closures.
    ///
    /// - Parameter operation: An async closure that receives the captured context.
    /// - Returns: The result of the operation.
    /// - Throws: The typed error from the operation.
    @inlinable
    public static func withEscaped<R, E: Error>(
        _ operation: (Dependency<Never>.Continuation) async throws(E) -> R
    ) async throws(E) -> R {
        try await Witness.Context.withEscaped(operation)
    }
}
