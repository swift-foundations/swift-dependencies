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

extension __DependencyContext.Test.Continuation.Performance {
    //    @Test("Continuation creation", .timed(iterations: 1000, warmup: 100))
    //    func continuationCreation() {
    //        for _ in 0..<100 {
    //            Dependency<Never>.Context.withEscaped { _ in
    //                // Just create the continuation
    //            }
    //        }
    //    }
    //
    //    @Test("Continuation yield", .timed(iterations: 1000, warmup: 100))
    //    func continuationYield() {
    //        var savedContinuation: Dependency<Never>.Continuation?
    //
    //        withDependencies {
    //            $0[SimpleKey.self] = "perf"
    //        } operation: {
    //            Dependency<Never>.Context.withEscaped { cont in
    //                savedContinuation = cont
    //            }
    //        }
    //
    //        for _ in 0..<100 {
    //            savedContinuation?.yield {
    //                _ = Dependency<Never>.Context.current[SimpleKey.self]
    //            }
    //        }
    //    }
}
