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

extension __DependencyValues.Test.Comprehensive.Performance {
    //    @Test("Values container access", .timed(iterations: 1000, warmup: 100))
    //    func valuesContainerAccess() {
    //        var values = Dependency<Never>.Values()
    //        values.simple = "perf"
    //
    //        for _ in 0..<100 {
    //            _ = values.simple
    //        }
    //    }
    //
    //    @Test("Context current access", .timed(iterations: 1000, warmup: 100))
    //    func contextCurrentAccess() {
    //        for _ in 0..<100 {
    //            _ = Dependency<Never>.Context.current.simple
    //        }
    //    }
    //
    //    @Test("Scope creation and teardown", .timed(iterations: 100, warmup: 10))
    //    func scopeCreationAndTeardown() {
    //        for _ in 0..<10 {
    //            withDependencies {
    //                $0.simple = "perf-scope"
    //            } operation: {
    //                _ = Dependency<Never>.Context.current.simple
    //            }
    //        }
    //    }
}
