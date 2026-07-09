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

extension `Dependency Tests`.Test.Performance {
    //    @Test("Property wrapper access", .timed(iterations: 1000, warmup: 100))
    //    func propertyWrapperAccess() {
    //        let consumer = DependencyConsumer()
    //        for _ in 0..<100 {
    //            _ = consumer.getSimple()
    //        }
    //    }
    //
    //    @Test("Property wrapper in scoped context", .timed(iterations: 100, warmup: 10))
    //    func propertyWrapperScoped() {
    //        let consumer = DependencyConsumer()
    //        withDependencies {
    //            $0.simple = "scoped"
    //        } operation: {
    //            for _ in 0..<100 {
    //                _ = consumer.getSimple()
    //            }
    //        }
    //    }
}
