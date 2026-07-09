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

extension `Edge Cases`.Test.Performance {
    //    @Test("Repeated scope creation", .timed(iterations: 100, warmup: 10))
    //    func repeatedScopeCreation() {
    //        for _ in 0..<50 {
    //            withDependencies {
    //                $0.intValue = 1
    //            } operation: {
    //                _ = Dependency<Never>.Context.current.intValue
    //            }
    //        }
    //    }
    //
    //    @Test("Deep nesting stress test", .timed(iterations: 10, warmup: 2))
    //    func deepNestingStress() {
    //        func nest(depth: Int) {
    //            if depth == 0 {
    //                _ = Dependency<Never>.Context.current.intValue
    //                return
    //            }
    //            withDependencies {
    //                $0.intValue = depth
    //            } operation: {
    //                nest(depth: depth - 1)
    //            }
    //        }
    //
    //        nest(depth: 20)
    //    }
}
