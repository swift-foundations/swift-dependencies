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
import Testing
@testable import Dependencies

@Suite("Edge Cases")
struct EdgeCasesTests {
    #Tests
}

// MARK: - Unit Tests

extension EdgeCasesTests.Test.Unit {
    @Test("Dependency with type-based subscript access")
    func typedKeySubscript() {
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

    @Test("Dependency with struct key and value")
    func structKeyAndValue() {
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

    @Test("Dependency with closure value")
    func closureValue() {
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

extension EdgeCasesTests.Test.EdgeCase {
    @Test("Deeply nested model hierarchy")
    func deepModelHierarchy() {
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

    @Test("Multiple dependencies in single access")
    func multipleDependenciesInSingleAccess() {
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

    @Test("Empty withDependencies scope")
    func emptyScope() {
        withDependencies(mode: .test) { _ in
            // No modifications
        } operation: {
            @Dependency(\.intValue) var value
            #expect(value == 42)  // testValue
        }
    }

    @Test("Throws preservation in sync context")
    func throwsPreservationSync() throws {
        struct TestError: Error, Equatable {}

        #expect(throws: TestError.self) {
            try withDependencies {
                $0.intValue = 99
            } operation: {
                throw TestError()
            }
        }
    }

    @Test("Throws preservation in async context")
    func throwsPreservationAsync() async throws {
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

extension EdgeCasesTests.Test.Integration {
    @Test("Actor with dependencies")
    func actorWithDependencies() async {
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

    @Test("Global actor isolated dependencies")
    func globalActorIsolation() async {
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

    @Test("Dependency in computed property")
    func dependencyInComputedProperty() {
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

    @Test("Concurrent access to same dependency")
    func concurrentAccessSameDependency() async {
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

extension EdgeCasesTests.Test.Performance {
    @Test("Repeated scope creation", .timed(iterations: 100, warmup: 10))
    func repeatedScopeCreation() {
        for _ in 0..<50 {
            withDependencies {
                $0.intValue = 1
            } operation: {
                _ = Dependency<Never>.Context.current.intValue
            }
        }
    }

    @Test("Deep nesting stress test", .timed(iterations: 10, warmup: 2))
    func deepNestingStress() {
        func nest(depth: Int) {
            if depth == 0 {
                _ = Dependency<Never>.Context.current.intValue
                return
            }
            withDependencies {
                $0.intValue = depth
            } operation: {
                nest(depth: depth - 1)
            }
        }

        nest(depth: 20)
    }
}
