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

import Dependency_Primitives

/// L1-only test key: conforms directly to `Dependency_Primitives.Dependency.Key`
/// (never `Witness.Key`), so a value set for it is stored only in L1's
/// `Dependency.Scope` / `Dependency.Values`, never in L3's `Witness.Values`.
/// Exercises the `__DependencyKey`-constrained subscript on `Dependency.Values`
/// (see `Sources/Dependencies/Dependency.Values.swift`).
///
/// - Note: Kept in its own file, importing only `Dependency_Primitives` (never
///   `Dependencies`), because importing both into one file makes the bare
///   `Dependency` name ambiguous between `Dependency_Primitives.Dependency`
///   (this enum) and `Dependencies.Dependency` (the property wrapper struct) —
///   every other test file in this target unqualifiedly writes `Dependency<_>`
///   or `Dependency.Values`, which would stop resolving.
enum L1OnlyKey: Dependency.Key {
    static var liveValue: String { "l1-live" }
    static var testValue: String { "l1-test" }
}
