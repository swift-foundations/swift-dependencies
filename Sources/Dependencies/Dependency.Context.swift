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

internal import Environment
public import Dependency_Primitives
public import Witnesses

/// Hoisted type for ``Dependency.Context``.
///
/// - Note: This type is at module level due to Swift's limitation on referencing
///   nested types in generic contexts. Use ``Dependency.Context`` in all API usage.
public enum __DependencyContext: Sendable {}

extension __DependencyContext {
    /// Typealias to ``Witness.Context.Mode``.
    public typealias Mode = Witness.Context.Mode

    /// Current mode from ``Witness.Context``.
    ///
    /// Returns the mode from the innermost ``withDependencies`` scope,
    /// or `.live` if not in a scope.
    public static var mode: Mode {
        Witness.Context.currentMode
    }

    /// Current values from ``Witness.Context``.
    ///
    /// Returns the values from the innermost ``withDependencies`` scope,
    /// or the default values if not in a scope.
    ///
    /// - Note: Materializes both stores: L2/L3 witness values from
    ///   ``Witness/Context/current`` and L1 values from
    ///   `Dependency_Primitives.Dependency.Scope.current`, so L1-only keys
    ///   (set via the `__DependencyKey` subscript) resolve correctly here and
    ///   through the ``Dependency`` property wrapper, not just their default.
    public static var current: __DependencyValues {
        __DependencyValues(
            _witnessValues: Witness.Context.current,
            _l1Values: Dependency_Primitives.Dependency.Scope.current
        )
    }

    /// Detects the execution mode from environment variables.
    ///
    /// This method checks environment variables to determine if code is
    /// running in a preview or test context. Call this once at app launch
    /// or test setup to configure the initial mode.
    ///
    /// Detection order:
    /// 1. `XCODE_RUNNING_FOR_PREVIEWS` - SwiftUI Preview mode
    /// 2. `XCTestConfigurationFilePath` - XCTest mode
    /// 3. `SWIFT_TESTING` - Swift Testing mode
    /// 4. Otherwise - Live mode
    ///
    /// - Returns: The detected execution mode.
    public static func detect() -> Mode {
        if Environment.task.isSet("XCODE_RUNNING_FOR_PREVIEWS") {
            return .preview
        }
        if Environment.task.isSet("XCTestConfigurationFilePath") {
            return .test
        }
        if Environment.task.isSet("SWIFT_TESTING") {
            return .test
        }
        return .live
    }
}
