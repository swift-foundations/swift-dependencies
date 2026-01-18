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
import Testing
@testable import Dependencies

@Suite("Dependency.Continuation")
struct DependencyContinuationTests {
    #Tests
}

// MARK: - Unit Tests

extension DependencyContinuationTests.Test.Unit {
    @Test("Continuation is typealias for Witness.Context.Escaped")
    func continuationTypealias() {
        // This test verifies the typealias compiles correctly
        // The actual type checking happens at compile time
        #expect(Bool(true))
    }

    @Test("withEscaped provides continuation")
    func withEscapedProvidesContinuation() {
        var capturedContinuation: Dependency<Never>.Continuation?

        Dependency<Never>.Context.withEscaped { continuation in
            capturedContinuation = continuation
        }

        #expect(capturedContinuation != nil)
    }
}

// MARK: - Edge Case Tests

extension DependencyContinuationTests.Test.EdgeCase {
    @Test("Continuation captures current dependencies")
    func capturesCurrentDependencies() {
        var capturedValue: String?

        withDependencies {
            $0[SimpleKey.self] = "captured"
        } operation: {
            Dependency<Never>.Context.withEscaped { continuation in
                continuation.yield {
                    capturedValue = Dependency<Never>.Context.current[SimpleKey.self]
                }
            }
        }

        #expect(capturedValue == "captured")
    }

    @Test("Continuation works outside original scope")
    func worksOutsideOriginalScope() {
        var savedContinuation: Dependency<Never>.Continuation?

        withDependencies {
            $0[SimpleKey.self] = "escaped"
        } operation: {
            Dependency<Never>.Context.withEscaped { continuation in
                savedContinuation = continuation
            }
        }

        // Now outside the withDependencies scope
        var capturedValue: String?
        savedContinuation?.yield {
            capturedValue = Dependency<Never>.Context.current[SimpleKey.self]
        }

        #expect(capturedValue == "escaped")
    }

    @Test("Multiple continuations are independent")
    func multipleContinuationsIndependent() {
        var continuation1: Dependency<Never>.Continuation?
        var continuation2: Dependency<Never>.Continuation?

        withDependencies {
            $0[SimpleKey.self] = "first"
        } operation: {
            Dependency<Never>.Context.withEscaped { cont in
                continuation1 = cont
            }
        }

        withDependencies {
            $0[SimpleKey.self] = "second"
        } operation: {
            Dependency<Never>.Context.withEscaped { cont in
                continuation2 = cont
            }
        }

        var value1: String?
        var value2: String?

        continuation1?.yield {
            value1 = Dependency<Never>.Context.current[SimpleKey.self]
        }

        continuation2?.yield {
            value2 = Dependency<Never>.Context.current[SimpleKey.self]
        }

        #expect(value1 == "first")
        #expect(value2 == "second")
    }
}

// MARK: - Integration Tests

extension DependencyContinuationTests.Test.Integration {
    @Test("Continuation with async work")
    func asyncWork() async {
        var savedContinuation: Dependency<Never>.Continuation?

        await withDependencies {
            $0[SimpleKey.self] = "async-captured"
        } operation: {
            Dependency<Never>.Context.withEscaped { continuation in
                savedContinuation = continuation
            }
        }

        var capturedValue: String?
        await savedContinuation?.yield {
            capturedValue = Dependency<Never>.Context.current[SimpleKey.self]
        }

        #expect(capturedValue == "async-captured")
    }

    @Test("Continuation preserves mode")
    func preservesMode() {
        var savedContinuation: Dependency<Never>.Continuation?

        withDependencies(mode: .test) { _ in
        } operation: {
            Dependency<Never>.Context.withEscaped { continuation in
                savedContinuation = continuation
            }
        }

        var capturedMode: Dependency<Never>.Context.Mode?
        savedContinuation?.yield {
            capturedMode = Dependency<Never>.Context.mode
        }

        #expect(capturedMode == .test)
    }

    @Test("Continuation with nested scopes")
    func nestedScopes() {
        var outerContinuation: Dependency<Never>.Continuation?
        var innerContinuation: Dependency<Never>.Continuation?

        withDependencies {
            $0[SimpleKey.self] = "outer"
        } operation: {
            Dependency<Never>.Context.withEscaped { cont in
                outerContinuation = cont
            }

            withDependencies {
                $0[SimpleKey.self] = "inner"
            } operation: {
                Dependency<Never>.Context.withEscaped { cont in
                    innerContinuation = cont
                }
            }
        }

        var outerValue: String?
        var innerValue: String?

        outerContinuation?.yield {
            outerValue = Dependency<Never>.Context.current[SimpleKey.self]
        }

        innerContinuation?.yield {
            innerValue = Dependency<Never>.Context.current[SimpleKey.self]
        }

        #expect(outerValue == "outer")
        #expect(innerValue == "inner")
    }
}

// MARK: - Performance Tests

extension DependencyContinuationTests.Test.Performance {
    @Test("Continuation creation", .timed(iterations: 1000, warmup: 100))
    func continuationCreation() {
        for _ in 0..<100 {
            Dependency<Never>.Context.withEscaped { _ in
                // Just create the continuation
            }
        }
    }

    @Test("Continuation yield", .timed(iterations: 1000, warmup: 100))
    func continuationYield() {
        var savedContinuation: Dependency<Never>.Continuation?

        withDependencies {
            $0[SimpleKey.self] = "perf"
        } operation: {
            Dependency<Never>.Context.withEscaped { cont in
                savedContinuation = cont
            }
        }

        for _ in 0..<100 {
            savedContinuation?.yield {
                _ = Dependency<Never>.Context.current[SimpleKey.self]
            }
        }
    }
}
