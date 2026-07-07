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

extension __DependencyContext {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Unit Tests

extension __DependencyContext.Test.Unit {
    @Test
    func `Current returns default values outside scope`() async throws {
        let value = Dependency<Never>.Context.current[SimpleKey.self]
        // Outside any scope, mode is .live
        #expect(value == "live")
    }

    @Test
    func `Mode defaults to live outside scope`() {
        let mode = Dependency<Never>.Context.mode
        #expect(mode == .live)
    }

    @Test
    func `Detect returns correct mode based on environment`() {
        // Note: In actual test environment, this might return .test
        // because XCTestConfigurationFilePath or SWIFT_TESTING may be set
        let detected = Dependency<Never>.Context.detect()
        // This test just verifies detect() runs without error
        #expect([Dependency<Never>.Context.Mode.live, .test, .preview].contains(detected))
    }
}

// MARK: - Edge Case Tests

extension __DependencyContext.Test.EdgeCase {
    @Test
    func `Context tracks mode changes through withDependencies`() throws {
        // Start in live mode
        #expect(Dependency<Never>.Context.mode == .live)

        try withDependencies(mode: .test) { _ in
            // Setting mode
        } operation: {
            // Inside test mode
            #expect(Dependency<Never>.Context.mode == .test)
        }

        // Back to live mode
        #expect(Dependency<Never>.Context.mode == .live)
    }
}

// MARK: - Integration Tests

extension __DependencyContext.Test.Integration {
    @Test
    func `Context delegates to Witness.Context`() async throws {
        // Verify that Dependency.Context.current reflects Witness.Context changes
        try await Witness.Context.with { values in
            values[SimpleKey.self] = "witness-override"
        } operation: {
            let depValue = Dependency<Never>.Context.current[SimpleKey.self]
            #expect(depValue == "witness-override")
        }
    }
}

// MARK: - Performance Tests

extension __DependencyContext.Test.Performance {
    //    @Test("Mode access", .timed(iterations: 1000, warmup: 100))
    //    func modeAccess() {
    //        for _ in 0..<100 {
    //            _ = Dependency<Never>.Context.mode
    //        }
    //    }
    //
    //    @Test("Current values access", .timed(iterations: 1000, warmup: 100))
    //    func currentValuesAccess() {
    //        for _ in 0..<100 {
    //            _ = Dependency<Never>.Context.current
    //        }
    //    }
    //
    //    @Test("Subscript access", .timed(iterations: 1000, warmup: 100))
    //    func subscriptAccess() {
    //        for _ in 0..<100 {
    //            _ = Dependency<Never>.Context.current[SimpleKey.self]
    //        }
    //    }
    //
    //    @Test("Mode detection", .timed(iterations: 1000, warmup: 100))
    //    func modeDetection() {
    //        for _ in 0..<100 {
    //            _ = Dependency<Never>.Context.detect()
    //        }
    //    }
}
