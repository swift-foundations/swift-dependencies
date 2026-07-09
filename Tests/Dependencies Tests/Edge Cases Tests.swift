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
struct `Edge Cases` {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Unit Tests

extension `Edge Cases`.Test.Unit {
    @Test
    func `Dependency with type-based subscript access`() {
        struct MyDependency: Dependency.Key {
            typealias Value = Int
            static var liveValue: Int { -1 }
            static var testValue: Int { 42 }
        }

        withDependencies {
            $0[MyDependency.self] = 100
        } operation: {
            #expect(Dependency<Never>.Context.current[MyDependency.self] == 100)
        }
    }

    @Test
    func `Dependency with struct key and value`() {
        struct Config: Sendable, Equatable {
            let name: String
            let version: Int
        }

        struct ConfigKey: Dependency.Key {
            typealias Value = Config
            static var liveValue: Config { Config(name: "live", version: 1) }
            static var testValue: Config { Config(name: "test", version: 0) }
        }

        withDependencies {
            $0[ConfigKey.self] = Config(name: "custom", version: 99)
        } operation: {
            let config = Dependency<Never>.Context.current[ConfigKey.self]
            #expect(config.name == "custom")
            #expect(config.version == 99)
        }
    }

    @Test
    func `Dependency with closure value`() {
        struct ActionKey: Dependency.Key {
            typealias Value = @Sendable () -> Int
            static var liveValue: @Sendable () -> Int { { -1 } }
            static var testValue: @Sendable () -> Int { { 42 } }
        }

        withDependencies {
            $0[ActionKey.self] = { 100 }
        } operation: {
            let action = Dependency<Never>.Context.current[ActionKey.self]
            #expect(action() == 100)
        }
    }
}

// MARK: - Edge Case Tests

extension `Edge Cases`.Test.`Edge Case` {
    @Test
    func `Deeply nested model hierarchy`() {
        class NestedModel: @unchecked Sendable {
            func getIntValue() -> Int {
                Dependency<Never>.Context.current.intValue
            }
            func getStringValue() -> String {
                Dependency<Never>.Context.current.stringValue
            }
            init() {}
        }

        let model1 = withDependencies {
            $0.intValue = 1
            $0.stringValue = "first"
        } operation: {
            NestedModel()
        }

        let model2 = withDependencies {
            $0.intValue = 2
            $0.stringValue = "second"
        } operation: {
            NestedModel()
        }

        // Each model should reflect current context when accessed
        withDependencies {
            $0.intValue = 100
            $0.stringValue = "hundred"
        } operation: {
            #expect(model1.getIntValue() == 100)
            #expect(model1.getStringValue() == "hundred")
            #expect(model2.getIntValue() == 100)
            #expect(model2.getStringValue() == "hundred")
        }

        // Outside scope, back to defaults (live mode)
        #expect(model1.getIntValue() == -1)  // liveValue
        #expect(model1.getStringValue() == "live-string")
    }

    @Test
    func `Multiple dependencies in single access`() {
        struct MultiAccessor: Sendable {
            func allValues() -> (Int, Int, String) {
                let context = Dependency<Never>.Context.current
                return (context.intValue, context.intValue, context.stringValue)
            }
        }

        let accessor = MultiAccessor()

        withDependencies {
            $0.intValue = 99
            $0.stringValue = "multi"
        } operation: {
            let values = accessor.allValues()
            #expect(values.0 == 99)
            #expect(values.1 == 99)
            #expect(values.2 == "multi")
        }
    }

    @Test
    func `Empty withDependencies scope`() {
        withDependencies(mode: .test) { _ in
            // No modifications
        } operation: {
            @Dependency(\.intValue) var value
            #expect(value == 42)  // testValue
        }
    }

    @Test
    func `Throws preservation in sync context`() throws {
        struct TestError: Error, Equatable {}

        #expect(throws: TestError.self) {
            try withDependencies {
                $0.intValue = 99
            } operation: {
                throw TestError()
            }
        }
    }

    @Test
    func `Throws preservation in async context`() async throws {
        struct AsyncError: Error, Equatable {}

        await #expect(throws: AsyncError.self) {
            try await withDependencies {
                $0.intValue = 99
            } operation: {
                await Task.yield()
                throw AsyncError()
            }
        }
    }
}

// MARK: - Integration Tests

extension `Edge Cases`.Test.Integration {
    @Test
    func `Actor with dependencies`() async {
        actor DependentActor {
            func getValue() -> Int {
                Dependency<Never>.Context.current.intValue
            }
        }

        let actor = DependentActor()

        await withDependencies {
            $0.intValue = 999
        } operation: {
            let value = await actor.getValue()
            #expect(value == 999)
        }
    }

    @Test
    func `Global actor isolated dependencies`() async {
        @MainActor
        struct MainActorType {
            func getValue() -> Int {
                Dependency<Never>.Context.current.intValue
            }
        }

        await withDependencies {
            $0.intValue = 888
        } operation: {
            let type = await MainActorType()
            let value = await type.getValue()
            #expect(value == 888)
        }
    }

    @Test
    func `Dependency in computed property`() {
        struct ComputedType: Sendable {
            var base: Int {
                Dependency<Never>.Context.current.intValue
            }

            var doubled: Int {
                base * 2
            }

            var quadrupled: Int {
                doubled * 2
            }
        }

        let computed = ComputedType()

        withDependencies {
            $0.intValue = 10
        } operation: {
            #expect(computed.doubled == 20)
            #expect(computed.quadrupled == 40)
        }
    }

    @Test
    func `Concurrent access to same dependency`() async {
        let iterations = 100

        await withDependencies {
            $0.intValue = 42
        } operation: {
            let results = await withTaskGroup(of: Int.self) { group in
                for _ in 0..<iterations {
                    group.addTask {
                        Dependency<Never>.Context.current.intValue
                    }
                }

                var collected: [Int] = []
                for await result in group {
                    collected.append(result)
                }
                return collected
            }

            // All concurrent reads should see the same value
            #expect(results.count == iterations)
            #expect(results.allSatisfy { $0 == 42 })
        }
    }
}

// MARK: - Performance Tests

extension `Edge Cases`.Test.Performance {
    //    @Test("Repeated scope creation", .timed(iterations: 100, warmup: 10))
    //    func repeatedScopeCreation() {
    //        for _ in 0..<50 {
    //            withDependencies {
    //                $0.intValue = 1
    //            } operation: {
    //                _ = Dependency<Never>.Context.current.intValue
    //            }
    //        }
    //    }
    //
    //    @Test("Deep nesting stress test", .timed(iterations: 10, warmup: 2))
    //    func deepNestingStress() {
    //        func nest(depth: Int) {
    //            if depth == 0 {
    //                _ = Dependency<Never>.Context.current.intValue
    //                return
    //            }
    //            withDependencies {
    //                $0.intValue = depth
    //            } operation: {
    //                nest(depth: depth - 1)
    //            }
    //        }
    //
    //        nest(depth: 20)
    //    }
}
