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
import Testing_Extras
@testable import Dependencies

@Suite("Dependency.Values.Comprehensive")
struct DependencyValuesComprehensiveTests {
    #TestSuites
}

// MARK: - Unit Tests

extension DependencyValuesComprehensiveTests.Test.Unit {
    @Test("Values container stores and retrieves values")
    func storesAndRetrievesValues() {
        withDependencies {
            $0.simple = "stored"
        } operation: {
            #expect(Dependency<Never>.Context.current.simple == "stored")
        }
    }

    @Test("Values container allows multiple keys")
    func multipleKeys() {
        withDependencies {
            $0.simple = "simple"
            $0.eagerChild = 42
        } operation: {
            #expect(Dependency<Never>.Context.current.simple == "simple")
            #expect(Dependency<Never>.Context.current.eagerChild == 42)
        }
    }

    @Test("Values container overwrites existing values")
    func overwritesExisting() {
        withDependencies {
            $0.simple = "first"
            $0.simple = "second"
        } operation: {
            #expect(Dependency<Never>.Context.current.simple == "second")
        }
    }

    @Test("Context mode affects default resolution")
    func contextModeAffectsDefaults() {
        withDependencies(mode: .test) { _ in
        } operation: {
            let value = Dependency<Never>.Context.current.modeAware
            #expect(value == "test-default")
        }

        withDependencies(mode: .preview) { _ in
        } operation: {
            let value = Dependency<Never>.Context.current.modeAware
            #expect(value == "preview-default")
        }

        withDependencies(mode: .live) { _ in
        } operation: {
            let value = Dependency<Never>.Context.current.modeAware
            #expect(value == "live-default")
        }
    }
}

// MARK: - Edge Case Tests

extension DependencyValuesComprehensiveTests.Test.EdgeCase {
    @Test("Empty modification preserves existing values")
    func emptyModificationPreserves() {
        withDependencies {
            $0.simple = "original"
        } operation: {
            withDependencies { _ in
                // Empty modification
            } operation: {
                let value = Dependency<Never>.Context.current.simple
                #expect(value == "original")
            }
        }
    }

    @Test("Nil-like values can be stored")
    func nilLikeValues() {
        withDependencies {
            $0.optionalValue = nil
        } operation: {
            let value = Dependency<Never>.Context.current.optionalValue
            #expect(value == nil)
        }
    }

    @Test("Value types are copied correctly")
    func valueTypesCopied() {
        struct Counter: Sendable {
            var count: Int
        }

        enum CounterKey: Dependency.Key {
            static var liveValue: Counter { Counter(count: 0) }
            static var testValue: Counter { Counter(count: 0) }
        }

        var captured: Counter?

        withDependencies {
            $0[CounterKey.self] = Counter(count: 10)
        } operation: {
            captured = Dependency<Never>.Context.current[CounterKey.self]
        }

        // Value should be copied, not referenced
        #expect(captured?.count == 10)
    }

    @Test("Reference types share identity")
    func referenceTypesShareIdentity() {
        final class RefType: @unchecked Sendable {
            var value: Int
            init(value: Int) { self.value = value }
        }

        enum RefKey: Dependency.Key {
            static var liveValue: RefType { RefType(value: 0) }
            static var testValue: RefType { RefType(value: 0) }
        }

        let shared = RefType(value: 42)

        withDependencies {
            $0[RefKey.self] = shared
        } operation: {
            let retrieved = Dependency<Never>.Context.current[RefKey.self]
            #expect(retrieved === shared)
        }
    }

    @Test("Scope isolation - changes don't leak")
    func scopeIsolation() {
        withDependencies {
            $0.simple = "outer"
        } operation: {
            withDependencies {
                $0.simple = "inner"
            } operation: {
                // Inner scope has inner value
                let inner = Dependency<Never>.Context.current.simple
                #expect(inner == "inner")
            }

            // Outer scope still has outer value
            let outer = Dependency<Never>.Context.current.simple
            #expect(outer == "outer")
        }
    }

    @Test("Async scope isolation")
    func asyncScopeIsolation() async {
        await withDependencies {
            $0.simple = "async-outer"
        } operation: {
            let tasks = (0..<5).map { i in
                Task {
                    await withDependencies {
                        $0.simple = "task-\(i)"
                    } operation: {
                        // Each task should see its own value
                        let value = Dependency<Never>.Context.current.simple
                        #expect(value == "task-\(i)")
                    }
                }
            }

            for task in tasks {
                await task.value
            }

            // Outer scope still intact
            let outer = Dependency<Never>.Context.current.simple
            #expect(outer == "async-outer")
        }
    }
}

// MARK: - Integration Tests

extension DependencyValuesComprehensiveTests.Test.Integration {
    @Test("withDependencies returns operation result")
    func withDependenciesReturnsResult() {
        let result = withDependencies {
            $0.simple = "for-result"
        } operation: {
            Dependency<Never>.Context.current.simple
        }

        #expect(result == "for-result")
    }

    @Test("withDependencies propagates errors")
    func withDependenciesPropagatesErrors() throws {
        struct TestError: Error, Equatable {}

        #expect(throws: TestError.self) {
            try withDependencies {
                $0.simple = "will-throw"
            } operation: {
                throw TestError()
            }
        }
    }

    @Test("Async withDependencies returns operation result")
    func asyncWithDependenciesReturnsResult() async {
        let result = await withDependencies {
            $0.simple = "async-result"
        } operation: {
            await Task.yield()
            return Dependency<Never>.Context.current.simple
        }

        #expect(result == "async-result")
    }

    @Test("Async withDependencies propagates errors")
    func asyncWithDependenciesPropagatesErrors() async throws {
        struct AsyncTestError: Error, Equatable {}

        await #expect(throws: AsyncTestError.self) {
            try await withDependencies {
                $0.simple = "will-throw-async"
            } operation: {
                await Task.yield()
                throw AsyncTestError()
            }
        }
    }

    @Test("Context propagates through Task boundaries")
    func contextPropagatesThroughTaskBoundaries() async {
        await withDependencies {
            $0.simple = "task-propagated"
        } operation: {
            let value = await Task {
                Dependency<Never>.Context.current.simple
            }.value

            #expect(value == "task-propagated")
        }
    }

    @Test("Context propagates through detached tasks with continuation")
    func contextPropagatesThroughDetachedWithContinuation() async throws {
        final class Box: @unchecked Sendable {
            var value: String?
        }
        let box = Box()

        await withDependencies {
            $0.simple = "detached-propagated"
        } operation: {
            _ = Dependency<Never>.Context.withEscaped { continuation in
                Task.detached {
                    continuation.yield {
                        box.value = Dependency<Never>.Context.current.simple
                    }
                }
            }

            // Wait for detached task
            try? await Task.sleep(for: .milliseconds(100))

            #expect(box.value == "detached-propagated")
        }
    }
}

// MARK: - Performance Tests

extension DependencyValuesComprehensiveTests.Test.Performance {
    @Test("Values container access", .timed(iterations: 1000, warmup: 100))
    func valuesContainerAccess() {
        var values = Dependency<Never>.Values()
        values.simple = "perf"

        for _ in 0..<100 {
            _ = values.simple
        }
    }

    @Test("Context current access", .timed(iterations: 1000, warmup: 100))
    func contextCurrentAccess() {
        for _ in 0..<100 {
            _ = Dependency<Never>.Context.current.simple
        }
    }

    @Test("Scope creation and teardown", .timed(iterations: 100, warmup: 10))
    func scopeCreationAndTeardown() {
        for _ in 0..<10 {
            withDependencies {
                $0.simple = "perf-scope"
            } operation: {
                _ = Dependency<Never>.Context.current.simple
            }
        }
    }
}
