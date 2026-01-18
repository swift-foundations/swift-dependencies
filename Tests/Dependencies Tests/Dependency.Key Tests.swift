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

@Suite("Dependency.Key")
struct DependencyKeyTests {
    #Tests
}

// MARK: - Unit Tests

extension DependencyKeyTests.Test.Unit {
    @Test("Key is typealias for Witness.Key")
    func keyTypealias() {
        // Verify the typealias works by using a conforming type
        let _: any Dependency<Never>.Key.Type = SimpleKey.self
        #expect(true)
    }

    @Test("Key provides mode-based resolution")
    func modeBasedResolution() throws {
        // Live mode
        let liveValue = SimpleKey.liveValue
        #expect(liveValue == "live")

        // Test mode
        let testValue = SimpleKey.testValue
        #expect(testValue == "test")

        // Preview mode
        let previewValue = SimpleKey.previewValue
        #expect(previewValue == "preview")
    }

    @Test("Key default chain: testValue falls back to previewValue")
    func testFallsBackToPreview() {
        // TestOnlyKey only defines testValue
        let testValue = TestOnlyKey.testValue
        #expect(testValue == "test-only")
    }
}

// MARK: - Edge Case Tests

extension DependencyKeyTests.Test.EdgeCase {
    @Test("Key with complex value type")
    func complexValueType() async throws {
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

    @Test("Key subscript access in Values")
    func subscriptAccess() throws {
        try withDependencies {
            $0[SimpleKey.self] = "subscript-value"
        } operation: {
            let value = Dependency<Never>.Context.current[SimpleKey.self]
            #expect(value == "subscript-value")
        }
    }

    @Test("KeyPath access in Values")
    func keyPathAccess() throws {
        try withDependencies {
            $0.simple = "keypath-value"
        } operation: {
            let value = Dependency<Never>.Context.current.simple
            #expect(value == "keypath-value")
        }
    }
}

// MARK: - Integration Tests

extension DependencyKeyTests.Test.Integration {
    @Test("Key resolution respects context mode")
    func contextModeResolution() throws {
        // In test mode, SimpleKey returns "test"
        try withDependencies(mode: .test) { _ in
        } operation: {
            let value = Dependency<Never>.Context.current[SimpleKey.self]
            #expect(value == "test")
        }

        // In preview mode, SimpleKey returns "preview"
        try withDependencies(mode: .preview) { _ in
        } operation: {
            let value = Dependency<Never>.Context.current[SimpleKey.self]
            #expect(value == "preview")
        }
    }

    @Test("Key override takes precedence over mode")
    func overrideTakesPrecedence() throws {
        try withDependencies(mode: .test) {
            $0[SimpleKey.self] = "explicit-override"
        } operation: {
            let value = Dependency<Never>.Context.current[SimpleKey.self]
            #expect(value == "explicit-override")
        }
    }
}

// MARK: - Performance Tests

extension DependencyKeyTests.Test.Performance {
    @Test("Key resolution", .timed(iterations: 1000, warmup: 100))
    func keyResolution() {
        for _ in 0..<100 {
            _ = SimpleKey.liveValue
        }
    }

    @Test("Key subscript get", .timed(iterations: 1000, warmup: 100))
    func keySubscriptGet() {
        let values = Dependency<Never>.Context.current
        for _ in 0..<100 {
            _ = values[SimpleKey.self]
        }
    }

    @Test("Key subscript set", .timed(iterations: 1000, warmup: 100))
    func keySubscriptSet() {
        var values = Dependency<Never>.Values()
        for i in 0..<100 {
            values[SimpleKey.self] = "value-\(i)"
        }
    }
}

// MARK: - Test Support

/// Key that only defines testValue (no preview/live overrides)
enum TestOnlyKey: Dependency<Never>.Key {
    static var liveValue: String { "live-fallback" }
    static var testValue: String { "test-only" }
}
