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

import Testing

@testable import Dependencies

// MARK: - Performance Tests

extension `withDependencies Tests`.Test.Performance {
    //    @Test("Sync scope overhead", .timed(iterations: 1000, warmup: 100))
    //    func syncScopeOverhead() {
    //        for _ in 0..<100 {
    //            withDependencies { _ in
    //                // Empty modification
    //            } operation: {
    //                // Empty operation
    //            }
    //        }
    //    }
    //
    //    @Test("Sync scope with modification", .timed(iterations: 1000, warmup: 100))
    //    func syncScopeWithModification() {
    //        for _ in 0..<100 {
    //            withDependencies {
    //                $0[SimpleKey.self] = "modified"
    //            } operation: {
    //                _ = Dependency<Never>.Context.current[SimpleKey.self]
    //            }
    //        }
    //    }
    //
    //    @Test("Nested scopes", .timed(iterations: 100, warmup: 10))
    //    func nestedScopesPerformance() {
    //        for _ in 0..<10 {
    //            withDependencies {
    //                $0[SimpleKey.self] = "outer"
    //            } operation: {
    //                withDependencies {
    //                    $0[SimpleKey.self] = "inner"
    //                } operation: {
    //                    _ = Dependency<Never>.Context.current[SimpleKey.self]
    //                }
    //            }
    //        }
    //    }
    //
    //    @Test("Mode-aware scope", .timed(iterations: 1000, warmup: 100))
    //    func modeAwareScopePerformance() {
    //        for _ in 0..<100 {
    //            withDependencies(mode: .test) { _ in
    //                // Empty modification
    //            } operation: {
    //                _ = Dependency<Never>.Context.mode
    //            }
    //        }
    //    }
}
