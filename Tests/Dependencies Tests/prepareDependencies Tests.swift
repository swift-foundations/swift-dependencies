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
import Witnesses

@testable import Dependencies

@Suite
struct `prepareDependencies Tests` {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

// MARK: - Unit Tests

extension `prepareDependencies Tests`.Test.Unit {
    @Test
    func `Sync preparation runs without error`() {
        let result = prepareDependencies { store in
            store.set(SimpleKey.self, value: "prepared")
        } operation: {
            "completed"
        }

        #expect(result == "completed")
    }

    @Test
    func `Async preparation runs without error`() async {
        let result = await prepareDependencies { store in
            store.set(SimpleKey.self, value: "async-prepared")
        } operation: {
            "async-completed"
        }

        #expect(result == "async-completed")
    }

    @Test
    func `Return value passes through`() {
        let result = prepareDependencies { _ in
        } operation: {
            42
        }

        #expect(result == 42)
    }

    @Test
    func `Store accepts values`() {
        prepareDependencies { store in
            // Verify store.set compiles and runs
            store.set(SimpleKey.self, value: "value1")
            store.set(
                TestAPI.self,
                value: TestAPI(
                    fetch: { _ in "test" },
                    update: { _, _ in }
                )
            )
        } operation: {
            // Operation completes
        }

        #expect(Bool(true))
    }
}

// MARK: - Edge Case Tests

extension `prepareDependencies Tests`.Test.`Edge Case` {
    @Test
    func `Empty preparation works`() {
        let result = prepareDependencies { _ in
            // No configuration
        } operation: {
            "empty"
        }

        #expect(result == "empty")
    }

    @Test
    func `Nested preparations work`() {
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

extension `prepareDependencies Tests`.Test.Integration {
    @Test
    func `withDependencies works inside prepareDependencies`() {
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

    @Test
    func `Preparation store is accessible`() {
        prepareDependencies { store in
            store.set(SimpleKey.self, value: "stored")

            // Can retrieve from store directly
            let retrieved = store.get(SimpleKey.self)
            #expect(retrieved == "stored")
        } operation: {
            // Values stored in preparation store
        }
    }

    @Test
    func `Current preparation store available in operation`() {
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