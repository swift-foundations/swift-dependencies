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

extension `Dependency.Key Tests`.Test.Performance {
    //    @Test("Key resolution", .timed(iterations: 1000, warmup: 100))
    //    func keyResolution() {
    //        for _ in 0..<100 {
    //            _ = SimpleKey.liveValue
    //        }
    //    }
    //
    //    @Test("Key subscript get", .timed(iterations: 1000, warmup: 100))
    //    func keySubscriptGet() {
    //        let values = Dependency<Never>.Context.current
    //        for _ in 0..<100 {
    //            _ = values[SimpleKey.self]
    //        }
    //    }
    //
    //    @Test("Key subscript set", .timed(iterations: 1000, warmup: 100))
    //    func keySubscriptSet() {
    //        var values = Dependency<Never>.Values()
    //        for i in 0..<100 {
    //            values[SimpleKey.self] = "value-\(i)"
    //        }
    //    }
}
