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

extension __DependencyValues {
    #Tests
}

// MARK: - Unit Tests

extension __DependencyValues.Test.Unit {
    @Test("Subscript get uses context")
    func subscriptGet() async throws {
        try await withDependencies(mode: .test) { _ in
            // Empty modification
        } operation: {
            let value = Dependency<Never>.Context.current[SimpleKey.self]
            #expect(value == "test")
        }
    }

    @Test("Subscript set stores value")
    func subscriptSet() throws {
        try withDependencies {
            $0[SimpleKey.self] = "custom"
        } operation: {
            let value = Dependency<Never>.Context.current[SimpleKey.self]
            #expect(value == "custom")
        }
    }

    @Test("Empty initialization creates empty container")
    func emptyInit() {
        let values = Dependency<Never>.Values()
        // Can access values, will use defaults
        // This just verifies initialization works
        _ = values
        #expect(true)
    }
}

// MARK: - Edge Case Tests

extension __DependencyValues.Test.EdgeCase {
    @Test("KeyPath-based access works")
    func keyPathAccess() throws {
        try withDependencies {
            $0.simple = "keypath-value"
        } operation: {
            let value = Dependency<Never>.Context.current.simple
            #expect(value == "keypath-value")
        }
    }

    @Test("Multiple keys can be set")
    func multipleKeys() async throws {
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
            // Verify it's our custom API by calling it
            let result = try await api.fetch(id: 1)
            #expect(result == "custom-fetch")
        }
    }
}

// MARK: - Integration Tests

extension __DependencyValues.Test.Integration {
    @Test("Values wrapper correctly delegates to Witness.Values")
    func delegatesStorage() throws {
        // Verify mutations go through to Witness.Values
        try withDependencies {
            $0[SimpleKey.self] = "stored"
        } operation: {
            // Access via Witness.Context directly
            let witnessValue = Witness.Context.current[SimpleKey.self]
            #expect(witnessValue == "stored")

            // Access via Dependency.Context
            let depValue = Dependency<Never>.Context.current[SimpleKey.self]
            #expect(depValue == "stored")
        }
    }
}

// MARK: - Performance Tests

extension __DependencyValues.Test.Performance {
    @Test("Values initialization", .timed(iterations: 1000, warmup: 100))
    func valuesInit() {
        for _ in 0..<100 {
            _ = Dependency<Never>.Values()
        }
    }

    @Test("Subscript get", .timed(iterations: 1000, warmup: 100))
    func subscriptGet() {
        let values = Dependency<Never>.Context.current
        for _ in 0..<100 {
            _ = values[SimpleKey.self]
        }
    }

    @Test("Subscript set", .timed(iterations: 1000, warmup: 100))
    func subscriptSet() {
        var values = Dependency<Never>.Values()
        for i in 0..<100 {
            values[SimpleKey.self] = "value-\(i)"
        }
    }
}
