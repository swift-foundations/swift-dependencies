import Testing

@testable import Dependencies

@Suite("Isolation")
struct `Isolation` {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension `Isolation`.Test.Unit {
    @Test
    func `Each test starts with clean context`() {
        @Dependency(\.counting) var counting

        let value = counting.increment()
        #expect(value == 1)
    }

    @Test
    func `Each test starts with clean context (duplicate)`() {
        @Dependency(\.counting) var counting

        let value = counting.increment()
        #expect(value == 1)
    }

    @Test
    func `withDependencies creates isolated scope`() {
        @Dependency(\.simple) var simple

        let outside = simple

        withDependencies {
            $0.simple = "inside-scope"
        } operation: {
            let inside = Dependency<Never>.Context.current.simple
            #expect(inside == "inside-scope")
        }

        #expect(simple == outside)
    }
}

extension `Isolation`.Test.`Edge Case` {
    @Test
    func `Concurrent scopes are isolated`() async {
        let iterations = 10

        await withThrowingTaskGroup(of: Void.self) { group in
            for i in 0..<iterations {
                group.addTask {
                    await withDependencies {
                        $0.simple = "task-\(i)"
                    } operation: {

                        await Task.yield()

                        let value = Dependency<Never>.Context.current.simple
                        #expect(value == "task-\(i)")
                    }
                }
            }

            try? await group.waitForAll()
        }
    }

    @Test
    func `Nested scopes maintain correct hierarchy`() {
        withDependencies {
            $0.simple = "level-1"
            $0.eagerChild = 1
        } operation: {
            #expect(Dependency<Never>.Context.current.simple == "level-1")
            #expect(Dependency<Never>.Context.current.eagerChild == 1)

            withDependencies {
                $0.simple = "level-2"

            } operation: {
                #expect(Dependency<Never>.Context.current.simple == "level-2")
                #expect(Dependency<Never>.Context.current.eagerChild == 1)

                withDependencies {
                    $0.eagerChild = 3

                } operation: {
                    #expect(Dependency<Never>.Context.current.simple == "level-2")
                    #expect(Dependency<Never>.Context.current.eagerChild == 3)
                }
            }
        }
    }

    @Test
    func `Mode isolation across scopes`() {
        withDependencies(mode: .test) { _ in
        } operation: {
            #expect(Dependency<Never>.Context.mode == .test)

            withDependencies(mode: .preview) { _ in
            } operation: {
                #expect(Dependency<Never>.Context.mode == .preview)
            }

            #expect(Dependency<Never>.Context.mode == .test)
        }
    }

    @Test
    func `Continuation preserves isolation`() {
        var captured1: String?
        var captured2: String?

        var continuation1: Dependency<Never>.Continuation?
        var continuation2: Dependency<Never>.Continuation?

        withDependencies {
            $0.simple = "context-1"
        } operation: {
            Dependency<Never>.Context.withEscaped { cont in
                continuation1 = cont
            }
        }

        withDependencies {
            $0.simple = "context-2"
        } operation: {
            Dependency<Never>.Context.withEscaped { cont in
                continuation2 = cont
            }
        }

        continuation1?.yield {
            captured1 = Dependency<Never>.Context.current.simple
        }

        continuation2?.yield {
            captured2 = Dependency<Never>.Context.current.simple
        }

        #expect(captured1 == "context-1")
        #expect(captured2 == "context-2")
    }
}

extension `Isolation`.Test.Integration {
    @Test
    func `Task isolation with TaskGroup`() async {
        await withDependencies {
            $0.simple = "group-root"
        } operation: {
            let results = await withTaskGroup(of: String.self) { group in
                for i in 0..<3 {
                    group.addTask {
                        await withDependencies {
                            $0.simple = "group-child-\(i)"
                        } operation: {
                            await Task.yield()
                            return Dependency<Never>.Context.current.simple
                        }
                    }
                }

                var collected: [String] = []
                for await result in group {
                    collected.append(result)
                }
                return collected.sorted()
            }

            #expect(results == ["group-child-0", "group-child-1", "group-child-2"])

            #expect(Dependency<Never>.Context.current.simple == "group-root")
        }
    }

    @Test
    func `Async sequence isolation`() async {
        await withDependencies {
            $0.simple = "sequence-context"
        } operation: {
            let stream = AsyncStream<String> { continuation in
                continuation.yield(Dependency<Never>.Context.current.simple)
                continuation.yield(Dependency<Never>.Context.current.simple)
                continuation.finish()
            }

            var values: [String] = []
            for await value in stream {
                values.append(value)
            }

            #expect(values == ["sequence-context", "sequence-context"])
        }
    }
}
