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

@Suite("withDependencies")
struct WithDependenciesTests {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Unit Tests

extension WithDependenciesTests.Test.Unit {
    @Test
    func `Basic override works`() throws {
        let result = try withDependencies {
            $0[SimpleKey.self] = "overridden"
        } operation: {
            Dependency<Never>.Context.current[SimpleKey.self]
        }

        #expect(result == "overridden")
    }

    @Test
    func `Typed throws preserved`() throws {
        enum TestError: Error { case expected }

        func throwingOp() throws(TestError) -> String {
            throw TestError.expected
        }

        #expect(throws: TestError.self) {
            try withDependencies {
                $0[SimpleKey.self] = "value"
            } operation: {
                try throwingOp()
            }
        }
    }

    @Test
    func `Mode-aware override works`() throws {
        try withDependencies(mode: .test) { _ in
            // Empty modification - just setting mode
        } operation: {
            #expect(Dependency<Never>.Context.mode == .test)
            let value = Dependency<Never>.Context.current[SimpleKey.self]
            #expect(value == "test")
        }
    }
}

// MARK: - Edge Case Tests

extension WithDependenciesTests.Test.`Edge Case` {
    @Test
    func `Nested scopes work correctly`() throws {
        try withDependencies {
            $0[SimpleKey.self] = "outer"
        } operation: {
            #expect(Dependency<Never>.Context.current[SimpleKey.self] == "outer")

            try withDependencies {
                $0[SimpleKey.self] = "inner"
            } operation: {
                #expect(Dependency<Never>.Context.current[SimpleKey.self] == "inner")
            }

            #expect(Dependency<Never>.Context.current[SimpleKey.self] == "outer")
        }
    }

    @Test
    func `Empty modification preserves existing values`() throws {
        try withDependencies {
            $0[SimpleKey.self] = "set"
        } operation: {
            try withDependencies { _ in
                // No modifications
            } operation: {
                // Should still have parent's value
                let value = Dependency<Never>.Context.current[SimpleKey.self]
                #expect(value == "set")
            }
        }
    }

    @Test
    func `Return value passes through`() throws {
        let result = try withDependencies { _ in
        } operation: {
            42
        }
        #expect(result == 42)
    }
}

// MARK: - Integration Tests

extension WithDependenciesTests.Test.Integration {
    @Test
    func `Async variant works`() async throws {
        let result = try await withDependencies {
            $0[SimpleKey.self] = "async-value"
        } operation: {
            await Task.yield()
            return Dependency<Never>.Context.current[SimpleKey.self]
        }

        #expect(result == "async-value")
    }

    @Test
    func `Async with mode works`() async throws {
        try await withDependencies(mode: .preview) {
            $0[SimpleKey.self] = "preview-override"
        } operation: {
            #expect(Dependency<Never>.Context.mode == .preview)
            let value = Dependency<Never>.Context.current[SimpleKey.self]
            #expect(value == "preview-override")
        }
    }

    @Test
    func `Context preserved across await points`() async throws {
        try await withDependencies {
            $0.testAPI = TestAPI(
                fetch: { id in "preserved-\(id)" },
                update: { _, _ in }
            )
        } operation: {
            let api = Dependency<Never>.Context.current[TestAPI.self]
            let result1 = try await api.fetch(id: 1)
            #expect(result1 == "preserved-1")

            try await Task.sleep(for: .milliseconds(1))

            let result2 = try await api.fetch(id: 2)
            #expect(result2 == "preserved-2")
        }
    }

    @Test
    func `Delegates to Witness.Context.with`() throws {
        try withDependencies {
            $0[SimpleKey.self] = "delegated"
        } operation: {
            // Should be visible via Witness.Context
            let witnessValue = Witness.Context.current[SimpleKey.self]
            #expect(witnessValue == "delegated")
        }
    }
}

// MARK: - Performance Tests

extension WithDependenciesTests.Test.Performance {
    //    @Test("Sync scope overhead", .timed(iterations: 1000, warmup: 100))
    //    func syncScopeOverhead() {
    //        for _ in 0..<100 {
    //            withDependencies { _ in
    //                // Empty modification
    //            } operation: {
    //                // Empty operation
    //            }
    //        }
    //    }
    //
    //    @Test("Sync scope with modification", .timed(iterations: 1000, warmup: 100))
    //    func syncScopeWithModification() {
    //        for _ in 0..<100 {
    //            withDependencies {
    //                $0[SimpleKey.self] = "modified"
    //            } operation: {
    //                _ = Dependency<Never>.Context.current[SimpleKey.self]
    //            }
    //        }
    //    }
    //
    //    @Test("Nested scopes", .timed(iterations: 100, warmup: 10))
    //    func nestedScopesPerformance() {
    //        for _ in 0..<10 {
    //            withDependencies {
    //                $0[SimpleKey.self] = "outer"
    //            } operation: {
    //                withDependencies {
    //                    $0[SimpleKey.self] = "inner"
    //                } operation: {
    //                    _ = Dependency<Never>.Context.current[SimpleKey.self]
    //                }
    //            }
    //        }
    //    }
    //
    //    @Test("Mode-aware scope", .timed(iterations: 1000, warmup: 100))
    //    func modeAwareScopePerformance() {
    //        for _ in 0..<100 {
    //            withDependencies(mode: .test) { _ in
    //                // Empty modification
    //            } operation: {
    //                _ = Dependency<Never>.Context.mode
    //            }
    //        }
    //    }
}
