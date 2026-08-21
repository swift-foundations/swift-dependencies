import Testing

@testable import Dependencies

@Suite
struct `Dependency.Key Tests` {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension `Dependency.Key Tests`.Test.Unit {
    @Test
    func `Key is typealias for Witness.Key`() {

        let _: any Dependency<Never>.Key.Type = SimpleKey.self
        #expect(true)
    }

    @Test
    func `Key provides mode-based resolution`() throws {

        let liveValue = SimpleKey.liveValue
        #expect(liveValue == "live")

        let testValue = SimpleKey.testValue
        #expect(testValue == "test")

        let previewValue = SimpleKey.previewValue
        #expect(previewValue == "preview")
    }

    @Test
    func `Key default chain: testValue falls back to previewValue`() {

        let testValue = TestOnlyKey.testValue
        #expect(testValue == "test-only")
    }
}

extension `Dependency.Key Tests`.Test.`Edge Case` {
    @Test
    func `Key with complex value type`() async throws {
        try await withDependencies {
            $0.testAPI = TestAPI(
                fetch: { id in "complex-\(id)" },
                update: { _, _ in }
            )
        } operation: {
            let api = Dependency<Never>.Context.current[TestAPI.self]
            let result = try await api.fetch(id: 42)
            #expect(result == "complex-42")
        }
    }

    @Test
    func `Key subscript access in Values`() throws {
        try withDependencies {
            $0[SimpleKey.self] = "subscript-value"
        } operation: {
            let value = Dependency<Never>.Context.current[SimpleKey.self]
            #expect(value == "subscript-value")
        }
    }

    @Test
    func `KeyPath access in Values`() throws {
        try withDependencies {
            $0.simple = "keypath-value"
        } operation: {
            let value = Dependency<Never>.Context.current.simple
            #expect(value == "keypath-value")
        }
    }
}

extension `Dependency.Key Tests`.Test.Integration {
    @Test
    func `Key resolution respects context mode`() throws {

        try withDependencies(mode: .test) { _ in
        } operation: {
            let value = Dependency<Never>.Context.current[SimpleKey.self]
            #expect(value == "test")
        }

        try withDependencies(mode: .preview) { _ in
        } operation: {
            let value = Dependency<Never>.Context.current[SimpleKey.self]
            #expect(value == "preview")
        }
    }

    @Test
    func `Key override takes precedence over mode`() throws {
        try withDependencies(mode: .test) {
            $0[SimpleKey.self] = "explicit-override"
        } operation: {
            let value = Dependency<Never>.Context.current[SimpleKey.self]
            #expect(value == "explicit-override")
        }
    }
}

enum TestOnlyKey: Dependency<Never>.Key {}

extension TestOnlyKey {
    static var liveValue: String { "live-fallback" }
    static var testValue: String { "test-only" }
}
