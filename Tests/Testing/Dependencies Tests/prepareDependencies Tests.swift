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

extension `prepareDependencies Tests`.Test.Performance {
    //    @Test("Sync preparation overhead", .timed(iterations: 100, warmup: 10))
    //    func syncPreparationOverhead() {
    //        for _ in 0..<10 {
    //            _ = prepareDependencies { store in
    //                store.set(SimpleKey.self, value: "perf")
    //            } operation: {
    //                "result"
    //            }
    //        }
    //    }
    //
    //    @Test("Empty preparation", .timed(iterations: 1000, warmup: 100))
    //    func emptyPreparation() {
    //        for _ in 0..<100 {
    //            _ = prepareDependencies { _ in
    //            } operation: {
    //                // Empty
    //            }
    //        }
    //    }
    //
    //    @Test("Store set operations", .timed(iterations: 100, warmup: 10))
    //    func storeSetOperations() {
    //        for _ in 0..<10 {
    //            _ = prepareDependencies { store in
    //                store.set(SimpleKey.self, value: "v1")
    //            } operation: {
    //                // Empty
    //            }
    //        }
    //    }
}
