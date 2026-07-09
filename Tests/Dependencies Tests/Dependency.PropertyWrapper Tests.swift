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

@Suite
struct `Dependency Tests` {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

/// Helper type that uses @Dependency property wrapper.
struct DependencyConsumer: Sendable {
    @Dependency(\.simple) var simple
    @Dependency(\.testAPI) var testAPI
}

extension DependencyConsumer {
    func getSimple() -> String {
        simple
    }

    func fetchFromAPI(id: Int) async throws -> String {
        try await testAPI.fetch(id: id)
    }
}

// MARK: - Unit Tests

extension `Dependency Tests`.Test.Unit {
    @Test
    func `Property wrapper accesses current context value`() throws {
        let consumer = DependencyConsumer()

        try withDependencies {
            $0.simple = "wrapped-value"
        } operation: {
            let value = consumer.getSimple()
            #expect(value == "wrapped-value")
        }
    }

    @Test
    func `Property wrapper uses default when not overridden`() {
        let consumer = DependencyConsumer()
        let value = consumer.getSimple()
        #expect(value == "live")
    }
}

// MARK: - Edge Case Tests

extension `Dependency Tests`.Test.`Edge Case` {
    @Test
    func `Property wrapper reflects scope changes`() throws {
        let consumer = DependencyConsumer()

        // Before scope
        #expect(consumer.getSimple() == "live")

        try withDependencies {
            $0.simple = "scoped"
        } operation: {
            // Inside scope
            #expect(consumer.getSimple() == "scoped")
        }

        // After scope
        #expect(consumer.getSimple() == "live")
    }

    @Test
    func `Multiple property wrappers work independently`() async throws {
        let consumer = DependencyConsumer()

        try await withDependencies {
            $0.simple = "simple-override"
            $0.testAPI = TestAPI(
                fetch: { id in "api-override-\(id)" },
                update: { _, _ in }
            )
        } operation: {
            #expect(consumer.getSimple() == "simple-override")
            let apiResult = try await consumer.fetchFromAPI(id: 42)
            #expect(apiResult == "api-override-42")
        }
    }
}

// MARK: - Integration Tests

extension `Dependency Tests`.Test.Integration {
    @Test
    func `Property wrapper works with nested scopes`() throws {
        let consumer = DependencyConsumer()

        try withDependencies {
            $0.simple = "outer"
        } operation: {
            #expect(consumer.getSimple() == "outer")

            try withDependencies {
                $0.simple = "inner"
            } operation: {
                #expect(consumer.getSimple() == "inner")
            }

            #expect(consumer.getSimple() == "outer")
        }
    }

    @Test
    func `Property wrapper preserves context across await`() async throws {
        let consumer = DependencyConsumer()

        try await withDependencies {
            $0.testAPI = TestAPI(
                fetch: { id in "async-result-\(id)" },
                update: { _, _ in }
            )
        } operation: {
            let result1 = try await consumer.fetchFromAPI(id: 1)
            #expect(result1 == "async-result-1")

            // Simulate async work
            try await Task.sleep(for: .milliseconds(1))

            let result2 = try await consumer.fetchFromAPI(id: 2)
            #expect(result2 == "async-result-2")
        }
    }
}

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
