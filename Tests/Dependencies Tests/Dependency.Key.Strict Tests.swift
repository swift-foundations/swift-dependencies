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
struct `Dependency.Key.Strict Tests` {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Unit Tests

extension `Dependency.Key.Strict Tests`.Test.Unit {
    @Test
    func `Strict key conforms to Witness.Key`() {
        // Verify StrictTestKey conforms to the protocol hierarchy
        let _: any Dependency<Never>.Key.Strict.Type = StrictTestKey.self
        let _: any Dependency<Never>.Key.Type = StrictTestKey.self
        #expect(Bool(true))
    }

    @Test
    func `Strict key has liveValue`() {
        let value = StrictTestKey.liveValue
        #expect(value == "strict-live")
    }
}

// MARK: - Edge Case Tests

extension `Dependency.Key.Strict Tests`.Test.`Edge Case` {
    @Test
    func `Strict key override works in test mode`() {
        withDependencies(mode: .test) {
            $0[StrictTestKey.self] = "overridden"
        } operation: {
            let value = Dependency<Never>.Context.current[StrictTestKey.self]
            #expect(value == "overridden")
        }
    }

    @Test
    func `Strict key override works in preview mode`() {
        withDependencies(mode: .preview) {
            $0[StrictTestKey.self] = "preview-override"
        } operation: {
            let value = Dependency<Never>.Context.current[StrictTestKey.self]
            #expect(value == "preview-override")
        }
    }

    @Test
    func `Strict key works in live mode without override`() {
        // In live mode, strict keys use their liveValue
        withDependencies(mode: .live) { _ in
        } operation: {
            let value = Dependency<Never>.Context.current[StrictTestKey.self]
            #expect(value == "strict-live")
        }
    }
}

// MARK: - Integration Tests

extension `Dependency.Key.Strict Tests`.Test.Integration {
    @Test
    func `Strict key with property wrapper`() {
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

    @Test
    func `Multiple strict keys can be overridden together`() {
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

extension `Dependency.Key.Strict Tests`.Test.Performance {
    //    @Test("Strict key resolution with override", .timed(iterations: 1000, warmup: 100))
    //    func strictKeyResolution() {
    //        withDependencies {
    //            $0[StrictTestKey.self] = "perf-test"
    //        } operation: {
    //            for _ in 0..<100 {
    //                _ = Dependency<Never>.Context.current[StrictTestKey.self]
    //            }
    //        }
    //    }
    //
    //    @Test("Strict key liveValue access", .timed(iterations: 1000, warmup: 100))
    //    func strictKeyLiveValue() {
    //        for _ in 0..<100 {
    //            _ = StrictTestKey.liveValue
    //        }
    //    }
}

// MARK: - Test Support

/// A strict dependency key for testing
enum StrictTestKey: Dependency<Never>.Key.Strict {}

extension StrictTestKey {
    typealias Value = String
    static var liveValue: String { "strict-live" }
}

/// Another strict key with different value type
enum AnotherStrictKey: Dependency<Never>.Key.Strict {}

extension AnotherStrictKey {
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
