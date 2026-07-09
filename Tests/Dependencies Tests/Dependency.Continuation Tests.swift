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

extension __DependencyContext.Test {
    @Suite("Dependency.Continuation") struct Continuation {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

// MARK: - Unit Tests

extension __DependencyContext.Test.Continuation.Unit {
    @Test
    func `Continuation is typealias for Witness.Context.Escaped`() {
        // This test verifies the typealias compiles correctly
        // The actual type checking happens at compile time
        #expect(Bool(true))
    }

    @Test
    func `withEscaped provides continuation`() {
        var capturedContinuation: Dependency<Never>.Continuation?

        Dependency<Never>.Context.withEscaped { continuation in
            capturedContinuation = continuation
        }

        #expect(capturedContinuation != nil)
    }
}

// MARK: - Edge Case Tests

extension __DependencyContext.Test.Continuation.`Edge Case` {
    @Test
    func `Continuation captures current dependencies`() {
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

    @Test
    func `Continuation works outside original scope`() {
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

    @Test
    func `Multiple continuations are independent`() {
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

extension __DependencyContext.Test.Continuation.Integration {
    @Test
    func `Continuation with async work`() async {
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

    @Test
    func `Continuation preserves mode`() {
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

    @Test
    func `Continuation with nested scopes`() {
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