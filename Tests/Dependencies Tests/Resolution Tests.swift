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

@Suite("Resolution")
struct ResolutionTests {
    #TestSuites
}

// MARK: - Unit Tests

extension ResolutionTests.Test.Unit {
    @Test("Eager dependency resolution")
    func eagerResolution() {
        @Dependency(\.eagerChild) var eagerChild: Int

        #expect(eagerChild == 1729)
    }

    @Test("Lazy dependency resolution")
    func lazyResolution() {
        @Dependency(\.lazyChild) var lazyChild: @Sendable () -> Int

        #expect(lazyChild() == 1729)
    }

    @Test("Dependency access outside scope uses defaults")
    func defaultsOutsideScope() {
        @Dependency(\.simple) var simple: String

        // Outside withDependencies, uses mode-based default
        #expect(simple == "test" || simple == "live")
    }
}

// MARK: - Edge Case Tests

extension ResolutionTests.Test.EdgeCase {
    @Test("Eager dependency with override")
    func eagerDependencyWithOverride() {
        @Dependency(\.eagerChild) var eagerChild: Int

        #expect(eagerChild == 1729)

        withDependencies {
            $0.eagerChild = 42
        } operation: {
            #expect(eagerChild == 42)
        }
    }

    @Test("Lazy dependency with override")
    func lazyDependencyWithOverride() {
        @Dependency(\.lazyChild) var lazyChild: @Sendable () -> Int

        #expect(lazyChild() == 1729)

        withDependencies {
            $0.lazyChild = { 42 }
        } operation: {
            #expect(lazyChild() == 42)
        }
    }

    @Test("Deep nesting preserves overrides")
    func deepNestingPreservesOverrides() {
        withDependencies {
            $0.simple = "level-1"
        } operation: {
            let level1 = Dependency<Never>.Context.current.simple
            #expect(level1 == "level-1")

            withDependencies {
                $0.simple = "level-2"
            } operation: {
                let level2 = Dependency<Never>.Context.current.simple
                #expect(level2 == "level-2")

                withDependencies {
                    $0.simple = "level-3"
                } operation: {
                    let level3 = Dependency<Never>.Context.current.simple
                    #expect(level3 == "level-3")
                }

                // Back to level 2
                let backToLevel2 = Dependency<Never>.Context.current.simple
                #expect(backToLevel2 == "level-2")
            }

            // Back to level 1
            let backToLevel1 = Dependency<Never>.Context.current.simple
            #expect(backToLevel1 == "level-1")
        }
    }
}

// MARK: - Integration Tests

extension ResolutionTests.Test.Integration {
    @Test("Multiple dependencies resolved together")
    func multipleDependenciesResolved() {
        withDependencies {
            $0.simple = "a"
            $0.eagerChild = 100
        } operation: {
            let simple = Dependency<Never>.Context.current.simple
            let eager = Dependency<Never>.Context.current.eagerChild

            #expect(simple == "a")
            #expect(eager == 100)
        }
    }

    @Test("Async resolution preserves context")
    func asyncResolutionPreservesContext() async {
        await withDependencies {
            $0.simple = "async-value"
        } operation: {
            // Simulate async work
            await Task.yield()

            let value = Dependency<Never>.Context.current.simple
            #expect(value == "async-value")
        }
    }

    @Test("Resolution with mode switching")
    func resolutionWithModeSwitching() {
        // Start in test mode
        withDependencies(mode: .test) { _ in
        } operation: {
            let testValue = Dependency<Never>.Context.current.simple
            #expect(testValue == "test")

            // Switch to preview mode
            withDependencies(mode: .preview) { _ in
            } operation: {
                let previewValue = Dependency<Never>.Context.current.simple
                #expect(previewValue == "preview")
            }

            // Back to test mode
            let backToTest = Dependency<Never>.Context.current.simple
            #expect(backToTest == "test")
        }
    }
}

// MARK: - Performance Tests

extension ResolutionTests.Test.Performance {
    @Test("Nested scope resolution", .timed(iterations: 100, warmup: 10))
    func nestedScopeResolution() {
        for _ in 0..<10 {
            withDependencies {
                $0.simple = "outer"
            } operation: {
                withDependencies {
                    $0.simple = "inner"
                } operation: {
                    _ = Dependency<Never>.Context.current.simple
                }
            }
        }
    }

    @Test("Multiple key access", .timed(iterations: 1000, warmup: 100))
    func multipleKeyAccess() {
        let values = Dependency<Never>.Context.current
        for _ in 0..<100 {
            _ = values.simple
            _ = values.eagerChild
        }
    }
}
