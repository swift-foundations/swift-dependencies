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

extension `Resolution`.Test.Performance {
    //    @Test("Nested scope resolution", .timed(iterations: 100, warmup: 10))
    //    func nestedScopeResolution() {
    //        for _ in 0..<10 {
    //            withDependencies {
    //                $0.simple = "outer"
    //            } operation: {
    //                withDependencies {
    //                    $0.simple = "inner"
    //                } operation: {
    //                    _ = Dependency<Never>.Context.current.simple
    //                }
    //            }
    //        }
    //    }
    //
    //    @Test("Multiple key access", .timed(iterations: 1000, warmup: 100))
    //    func multipleKeyAccess() {
    //        let values = Dependency<Never>.Context.current
    //        for _ in 0..<100 {
    //            _ = values.simple
    //            _ = values.eagerChild
    //        }
    //    }
}
