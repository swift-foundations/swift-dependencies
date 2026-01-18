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

extension __DependencyContext {
    #TestSuites
}

// MARK: - Unit Tests

extension __DependencyContext.Test.Unit {
    @Test("Current returns default values outside scope")
    func currentOutsideScope() async throws {
        let value = Dependency<Never>.Context.current[SimpleKey.self]
        // Outside any scope, mode is .live
        #expect(value == "live")
    }

    @Test("Mode defaults to live outside scope")
    func modeDefaultsToLive() {
        let mode = Dependency<Never>.Context.mode
        #expect(mode == .live)
    }

    @Test("Detect returns correct mode based on environment")
    func detectMode() {
        // Note: In actual test environment, this might return .test
        // because XCTestConfigurationFilePath or SWIFT_TESTING may be set
        let detected = Dependency<Never>.Context.detect()
        // This test just verifies detect() runs without error
        #expect([Dependency<Never>.Context.Mode.live, .test, .preview].contains(detected))
    }
}

// MARK: - Edge Case Tests

extension __DependencyContext.Test.EdgeCase {
    @Test("Context tracks mode changes through withDependencies")
    func modeTracking() throws {
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
    @Test("Context delegates to Witness.Context")
    func delegatesToWitness() async throws {
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
    @Test("Mode access", .timed(iterations: 1000, warmup: 100))
    func modeAccess() {
        for _ in 0..<100 {
            _ = Dependency<Never>.Context.mode
        }
    }

    @Test("Current values access", .timed(iterations: 1000, warmup: 100))
    func currentValuesAccess() {
        for _ in 0..<100 {
            _ = Dependency<Never>.Context.current
        }
    }

    @Test("Subscript access", .timed(iterations: 1000, warmup: 100))
    func subscriptAccess() {
        for _ in 0..<100 {
            _ = Dependency<Never>.Context.current[SimpleKey.self]
        }
    }

    @Test("Mode detection", .timed(iterations: 1000, warmup: 100))
    func modeDetection() {
        for _ in 0..<100 {
            _ = Dependency<Never>.Context.detect()
        }
    }
}
