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

extension __DependencyValues.Test.Performance {
    //    @Test("Values initialization", .timed(iterations: 1000, warmup: 100))
    //    func valuesInit() {
    //        for _ in 0..<100 {
    //            _ = Dependency<Never>.Values()
    //        }
    //    }
    //
    //    @Test("Subscript get", .timed(iterations: 1000, warmup: 100))
    //    func subscriptGet() {
    //        let values = Dependency<Never>.Context.current
    //        for _ in 0..<100 {
    //            _ = values[SimpleKey.self]
    //        }
    //    }
    //
    //    @Test("Subscript set", .timed(iterations: 1000, warmup: 100))
    //    func subscriptSet() {
    //        var values = Dependency<Never>.Values()
    //        for i in 0..<100 {
    //            values[SimpleKey.self] = "value-\(i)"
    //        }
    //    }
}
