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

extension __DependencyContext.Test.Performance {
    //    @Test("Mode access", .timed(iterations: 1000, warmup: 100))
    //    func modeAccess() {
    //        for _ in 0..<100 {
    //            _ = Dependency<Never>.Context.mode
    //        }
    //    }
    //
    //    @Test("Current values access", .timed(iterations: 1000, warmup: 100))
    //    func currentValuesAccess() {
    //        for _ in 0..<100 {
    //            _ = Dependency<Never>.Context.current
    //        }
    //    }
    //
    //    @Test("Subscript access", .timed(iterations: 1000, warmup: 100))
    //    func subscriptAccess() {
    //        for _ in 0..<100 {
    //            _ = Dependency<Never>.Context.current[SimpleKey.self]
    //        }
    //    }
    //
    //    @Test("Mode detection", .timed(iterations: 1000, warmup: 100))
    //    func modeDetection() {
    //        for _ in 0..<100 {
    //            _ = Dependency<Never>.Context.detect()
    //        }
    //    }
}
