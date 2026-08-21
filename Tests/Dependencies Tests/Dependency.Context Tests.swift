import Testing

@testable import Dependencies

extension __DependencyContext {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension __DependencyContext.Test.Unit {
    @Test
    func `Current returns default values outside scope`() async throws {
        let value = Dependency<Never>.Context.current[SimpleKey.self]

        #expect(value == "live")
    }

    @Test
    func `Mode defaults to live outside scope`() {
        let mode = Dependency<Never>.Context.mode
        #expect(mode == .live)
    }

    @Test
    func `Detect returns correct mode based on environment`() {

        let detected = Dependency<Never>.Context.detect()

        #expect([Dependency<Never>.Context.Mode.live, .test, .preview].contains(detected))
    }
}

extension __DependencyContext.Test.`Edge Case` {
    @Test
    func `Context tracks mode changes through withDependencies`() throws {

        #expect(Dependency<Never>.Context.mode == .live)

        try withDependencies(mode: .test) { _ in

        } operation: {

            #expect(Dependency<Never>.Context.mode == .test)
        }

        #expect(Dependency<Never>.Context.mode == .live)
    }
}

extension __DependencyContext.Test.Integration {
    @Test
    func `Context delegates to Witness.Context`() async throws {

        try await Witness.Context.with { values in
            values[SimpleKey.self] = "witness-override"
        } operation: {
            let depValue = Dependency<Never>.Context.current[SimpleKey.self]
            #expect(depValue == "witness-override")
        }
    }

    @Test
    func `Context surfaces L1-only override pushed by withDependencies`() throws {
        try withDependencies {
            $0[L1OnlyKey.self] = "l1-round-trip"
        } operation: {
            let value = Dependency<Never>.Context.current[L1OnlyKey.self]
            #expect(value == "l1-round-trip")
        }
    }

    @Test
    func `Context falls back to L1-only key's testValue in test mode with no override`() throws {
        try withDependencies(mode: .test) { _ in

        } operation: {
            let value = Dependency<Never>.Context.current[L1OnlyKey.self]
            #expect(value == "l1-test")
        }
    }
}
