import Testing

@testable import Dependencies

@Suite
struct `Dependency Tests` {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

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

extension `Dependency Tests`.Test.`Edge Case` {
    @Test
    func `Property wrapper reflects scope changes`() throws {
        let consumer = DependencyConsumer()

        #expect(consumer.getSimple() == "live")

        try withDependencies {
            $0.simple = "scoped"
        } operation: {

            #expect(consumer.getSimple() == "scoped")
        }

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

            try await Task.sleep(for: .milliseconds(1))

            let result2 = try await consumer.fetchFromAPI(id: 2)
            #expect(result2 == "async-result-2")
        }
    }
}
