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
import Witnesses

@Suite("prepareDependencies")
struct PrepareDependenciesTests {
    #Tests
}

// MARK: - Unit Tests

extension PrepareDependenciesTests.Test.Unit {
    @Test("Sync preparation runs without error")
    func syncPreparation() {
        let result = prepareDependencies { store in
            store.set(SimpleKey.self, value: "prepared")
        } operation: {
            "completed"
        }

        #expect(result == "completed")
    }

    @Test("Async preparation runs without error")
    func asyncPreparation() async {
        let result = await prepareDependencies { store in
            store.set(SimpleKey.self, value: "async-prepared")
        } operation: {
            "async-completed"
        }

        #expect(result == "async-completed")
    }

    @Test("Return value passes through")
    func returnValue() {
        let result = prepareDependencies { _ in
        } operation: {
            42
        }

        #expect(result == 42)
    }

    @Test("Store accepts values")
    func storeAcceptsValues() {
        prepareDependencies { store in
            // Verify store.set compiles and runs
            store.set(SimpleKey.self, value: "value1")
            store.set(TestAPI.self, value: TestAPI(
                fetch: { _ in "test" },
                update: { _, _ in }
            ))
        } operation: {
            // Operation completes
        }

        #expect(Bool(true))
    }
}

// MARK: - Edge Case Tests

extension PrepareDependenciesTests.Test.EdgeCase {
    @Test("Empty preparation works")
    func emptyPreparation() {
        let result = prepareDependencies { _ in
            // No configuration
        } operation: {
            "empty"
        }

        #expect(result == "empty")
    }

    @Test("Nested preparations work")
    func nestedPreparations() {
        let result = prepareDependencies { store in
            store.set(SimpleKey.self, value: "outer")
        } operation: {
            prepareDependencies { store in
                store.set(SimpleKey.self, value: "inner")
            } operation: {
                "nested"
            }
        }

        #expect(result == "nested")
    }
}

// MARK: - Integration Tests

extension PrepareDependenciesTests.Test.Integration {
    @Test("withDependencies works inside prepareDependencies")
    func withDependenciesInside() {
        prepareDependencies { _ in
        } operation: {
            withDependencies {
                $0[SimpleKey.self] = "override"
            } operation: {
                let value = Dependency<Never>.Context.current[SimpleKey.self]
                #expect(value == "override")
            }
        }
    }

    @Test("Preparation store is accessible")
    func storeIsAccessible() {
        prepareDependencies { store in
            store.set(SimpleKey.self, value: "stored")

            // Can retrieve from store directly
            let retrieved = store.get(SimpleKey.self)
            #expect(retrieved == "stored")
        } operation: {
            // Values stored in preparation store
        }
    }

    @Test("Current preparation store available in operation")
    func currentStoreAvailable() {
        prepareDependencies { store in
            store.set(SimpleKey.self, value: "current")
        } operation: {
            // Witness.Preparation.current should be set
            let currentStore = Witness.Preparation.current
            #expect(currentStore != nil)

            // Can read from current store
            if let store = currentStore {
                let value = store.get(SimpleKey.self)
                #expect(value == "current")
            }
        }
    }
}

// MARK: - Performance Tests

extension PrepareDependenciesTests.Test.Performance {
    @Test("Sync preparation overhead", .timed(iterations: 100, warmup: 10))
    func syncPreparationOverhead() {
        for _ in 0..<10 {
            _ = prepareDependencies { store in
                store.set(SimpleKey.self, value: "perf")
            } operation: {
                "result"
            }
        }
    }

    @Test("Empty preparation", .timed(iterations: 1000, warmup: 100))
    func emptyPreparation() {
        for _ in 0..<100 {
            _ = prepareDependencies { _ in
            } operation: {
                // Empty
            }
        }
    }

    @Test("Store set operations", .timed(iterations: 100, warmup: 10))
    func storeSetOperations() {
        for _ in 0..<10 {
            _ = prepareDependencies { store in
                store.set(SimpleKey.self, value: "v1")
            } operation: {
                // Empty
            }
        }
    }
}
