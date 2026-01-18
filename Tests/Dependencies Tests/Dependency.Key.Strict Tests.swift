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

@Suite("Dependency.Key.Strict")
struct DependencyKeyStrictTests {
    #TestSuites
}

// MARK: - Unit Tests

extension DependencyKeyStrictTests.Test.Unit {
    @Test("Strict key conforms to Witness.Key")
    func conformsToWitnessKey() {
        // Verify StrictTestKey conforms to the protocol hierarchy
        let _: any Dependency<Never>.Key.Strict.Type = StrictTestKey.self
        let _: any Dependency<Never>.Key.Type = StrictTestKey.self
        #expect(Bool(true))
    }

    @Test("Strict key has liveValue")
    func hasLiveValue() {
        let value = StrictTestKey.liveValue
        #expect(value == "strict-live")
    }
}

// MARK: - Edge Case Tests

extension DependencyKeyStrictTests.Test.EdgeCase {
    @Test("Strict key override works in test mode")
    func overrideInTestMode() {
        withDependencies(mode: .test) {
            $0[StrictTestKey.self] = "overridden"
        } operation: {
            let value = Dependency<Never>.Context.current[StrictTestKey.self]
            #expect(value == "overridden")
        }
    }

    @Test("Strict key override works in preview mode")
    func overrideInPreviewMode() {
        withDependencies(mode: .preview) {
            $0[StrictTestKey.self] = "preview-override"
        } operation: {
            let value = Dependency<Never>.Context.current[StrictTestKey.self]
            #expect(value == "preview-override")
        }
    }

    @Test("Strict key works in live mode without override")
    func liveWithoutOverride() {
        // In live mode, strict keys use their liveValue
        withDependencies(mode: .live) { _ in
        } operation: {
            let value = Dependency<Never>.Context.current[StrictTestKey.self]
            #expect(value == "strict-live")
        }
    }
}

// MARK: - Integration Tests

extension DependencyKeyStrictTests.Test.Integration {
    @Test("Strict key with property wrapper")
    func withPropertyWrapper() {
        struct Consumer: Sendable {
            @Dependency(\.strictTest) var strictTest

            func getValue() -> String {
                strictTest
            }
        }

        let consumer = Consumer()

        withDependencies {
            $0.strictTest = "wrapper-override"
        } operation: {
            #expect(consumer.getValue() == "wrapper-override")
        }
    }

    @Test("Multiple strict keys can be overridden together")
    func multipleStrictKeys() {
        withDependencies {
            $0[StrictTestKey.self] = "first"
            $0[AnotherStrictKey.self] = 42
        } operation: {
            let first = Dependency<Never>.Context.current[StrictTestKey.self]
            let second = Dependency<Never>.Context.current[AnotherStrictKey.self]
            #expect(first == "first")
            #expect(second == 42)
        }
    }
}

// MARK: - Performance Tests

extension DependencyKeyStrictTests.Test.Performance {
    @Test("Strict key resolution with override", .timed(iterations: 1000, warmup: 100))
    func strictKeyResolution() {
        withDependencies {
            $0[StrictTestKey.self] = "perf-test"
        } operation: {
            for _ in 0..<100 {
                _ = Dependency<Never>.Context.current[StrictTestKey.self]
            }
        }
    }

    @Test("Strict key liveValue access", .timed(iterations: 1000, warmup: 100))
    func strictKeyLiveValue() {
        for _ in 0..<100 {
            _ = StrictTestKey.liveValue
        }
    }
}

// MARK: - Test Support

/// A strict dependency key for testing
enum StrictTestKey: Dependency<Never>.Key.Strict {
    typealias Value = String
    static var liveValue: String { "strict-live" }
}

/// Another strict key with different value type
enum AnotherStrictKey: Dependency<Never>.Key.Strict {
    typealias Value = Int
    static var liveValue: Int { 0 }
}

/// Extension to add keypath access
extension Dependency<Never>.Values {
    var strictTest: String {
        get { self[StrictTestKey.self] }
        set { self[StrictTestKey.self] = newValue }
    }
}
