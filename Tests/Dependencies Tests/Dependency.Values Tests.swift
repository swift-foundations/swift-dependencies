import Testing

@testable import Dependencies

extension __DependencyValues {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension __DependencyValues.Test.Unit {
    @Test
    func `Subscript get uses context`() async throws {
        try await withDependencies(mode: .test) { _ in

        } operation: {
            let value = Dependency<Never>.Context.current[SimpleKey.self]
            #expect(value == "test")
        }
    }

    @Test
    func `Subscript set stores value`() throws {
        try withDependencies {
            $0[SimpleKey.self] = "custom"
        } operation: {
            let value = Dependency<Never>.Context.current[SimpleKey.self]
            #expect(value == "custom")
        }
    }

    @Test
    func `Empty initialization creates empty container`() {
        let values = Dependency<Never>.Values()

        _ = values
        #expect(true)
    }
}

extension __DependencyValues.Test.`Edge Case` {
    @Test
    func `KeyPath-based access works`() throws {
        try withDependencies {
            $0.simple = "keypath-value"
        } operation: {
            let value = Dependency<Never>.Context.current.simple
            #expect(value == "keypath-value")
        }
    }

    @Test
    func `Multiple keys can be set`() async throws {
        try await withDependencies {
            $0[SimpleKey.self] = "first"
            $0.testAPI = TestAPI(
                fetch: { _ in "custom-fetch" },
                update: { _, _ in }
            )
        } operation: {
            let simple = Dependency<Never>.Context.current[SimpleKey.self]
            #expect(simple == "first")

            let api = Dependency<Never>.Context.current[TestAPI.self]

            let result = try await api.fetch(id: 1)
            #expect(result == "custom-fetch")
        }
    }
}

extension __DependencyValues.Test.Integration {
    @Test
    func `Values wrapper correctly delegates to Witness.Values`() throws {

        try withDependencies {
            $0[SimpleKey.self] = "stored"
        } operation: {

            let witnessValue = Witness.Context.current[SimpleKey.self]
            #expect(witnessValue == "stored")

            let depValue = Dependency<Never>.Context.current[SimpleKey.self]
            #expect(depValue == "stored")
        }
    }
}
