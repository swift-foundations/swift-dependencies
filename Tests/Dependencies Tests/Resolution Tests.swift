import Testing

@testable import Dependencies

@Suite("Resolution")
struct `Resolution` {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension `Resolution`.Test.Unit {
    @Test
    func `Eager dependency resolution`() {
        @Dependency(\.eagerChild) var eagerChild: Int

        #expect(eagerChild == 1729)
    }

    @Test
    func `Lazy dependency resolution`() {
        @Dependency(\.lazyChild) var lazyChild: @Sendable () -> Int

        #expect(lazyChild() == 1729)
    }

    @Test
    func `Dependency access outside scope uses defaults`() {
        @Dependency(\.simple) var simple: String

        #expect(simple == "test" || simple == "live")
    }
}

extension `Resolution`.Test.`Edge Case` {
    @Test
    func `Eager dependency with override`() {
        @Dependency(\.eagerChild) var eagerChild: Int

        #expect(eagerChild == 1729)

        withDependencies {
            $0.eagerChild = 42
        } operation: {
            #expect(eagerChild == 42)
        }
    }

    @Test
    func `Lazy dependency with override`() {
        @Dependency(\.lazyChild) var lazyChild: @Sendable () -> Int

        #expect(lazyChild() == 1729)

        withDependencies {
            $0.lazyChild = { 42 }
        } operation: {
            #expect(lazyChild() == 42)
        }
    }

    @Test
    func `Deep nesting preserves overrides`() {
        withDependencies {
            $0.simple = "level-1"
        } operation: {
            let level1 = Dependency<Never>.Context.current.simple
            #expect(level1 == "level-1")

            withDependencies {
                $0.simple = "level-2"
            } operation: {
                let level2 = Dependency<Never>.Context.current.simple
                #expect(level2 == "level-2")

                withDependencies {
                    $0.simple = "level-3"
                } operation: {
                    let level3 = Dependency<Never>.Context.current.simple
                    #expect(level3 == "level-3")
                }

                let backToLevel2 = Dependency<Never>.Context.current.simple
                #expect(backToLevel2 == "level-2")
            }

            let backToLevel1 = Dependency<Never>.Context.current.simple
            #expect(backToLevel1 == "level-1")
        }
    }
}

extension `Resolution`.Test.Integration {
    @Test
    func `Multiple dependencies resolved together`() {
        withDependencies {
            $0.simple = "a"
            $0.eagerChild = 100
        } operation: {
            let simple = Dependency<Never>.Context.current.simple
            let eager = Dependency<Never>.Context.current.eagerChild

            #expect(simple == "a")
            #expect(eager == 100)
        }
    }

    @Test
    func `Async resolution preserves context`() async {
        await withDependencies {
            $0.simple = "async-value"
        } operation: {

            await Task.yield()

            let value = Dependency<Never>.Context.current.simple
            #expect(value == "async-value")
        }
    }

    @Test
    func `Resolution with mode switching`() {

        withDependencies(mode: .test) { _ in
        } operation: {
            let testValue = Dependency<Never>.Context.current.simple
            #expect(testValue == "test")

            withDependencies(mode: .preview) { _ in
            } operation: {
                let previewValue = Dependency<Never>.Context.current.simple
                #expect(previewValue == "preview")
            }

            let backToTest = Dependency<Never>.Context.current.simple
            #expect(backToTest == "test")
        }
    }
}
