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

extension `Dependency.Key.Strict Tests`.Test.Performance {
    //    @Test("Strict key resolution with override", .timed(iterations: 1000, warmup: 100))
    //    func strictKeyResolution() {
    //        withDependencies {
    //            $0[StrictTestKey.self] = "perf-test"
    //        } operation: {
    //            for _ in 0..<100 {
    //                _ = Dependency<Never>.Context.current[StrictTestKey.self]
    //            }
    //        }
    //    }
    //
    //    @Test("Strict key liveValue access", .timed(iterations: 1000, warmup: 100))
    //    func strictKeyLiveValue() {
    //        for _ in 0..<100 {
    //            _ = StrictTestKey.liveValue
    //        }
    //    }
}
