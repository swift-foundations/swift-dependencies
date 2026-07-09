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

extension `Isolation`.Test.Performance {
    //    @Test("Concurrent scope creation", .timed(iterations: 10, warmup: 2))
    //    func concurrentScopeCreation() async {
    //        await withTaskGroup(of: Void.self) { group in
    //            for _ in 0..<10 {
    //                group.addTask {
    //                    withDependencies {
    //                        $0.simple = "concurrent"
    //                    } operation: {
    //                        _ = Dependency<Never>.Context.current.simple
    //                    }
    //                }
    //            }
    //            await group.waitForAll()
    //        }
    //    }
    //
    //    @Test("Deep nesting performance", .timed(iterations: 100, warmup: 10))
    //    func deepNestingPerformance() {
    //        func nest(depth: Int) {
    //            if depth == 0 {
    //                _ = Dependency<Never>.Context.current.simple
    //                return
    //            }
    //            withDependencies {
    //                $0.simple = "depth-\(depth)"
    //            } operation: {
    //                nest(depth: depth - 1)
    //            }
    //        }
    //
    //        nest(depth: 10)
    //    }
}
