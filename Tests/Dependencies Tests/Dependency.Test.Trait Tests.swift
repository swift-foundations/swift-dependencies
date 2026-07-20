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

#if canImport(Testing) && compiler(>=6)
    import Testing
    import Dependencies
    import Dependencies_Test_Support

    // MARK: - Basic Trait Tests

    @Suite(.dependencies)
    struct `Dependency Test Traits` {

        @Test
        func `dependencies trait sets test mode`() {
            Dependency<Never>.Test.assertMode(.test)
        }

        @Test
        func `dependencies trait provides isolation`() {
            @Dependency(\.counting) var counting
            let client = counting  // Resolve once to preserve state
            #expect(client.increment() == 1)
            #expect(client.increment() == 2)
        }
    }

    // MARK: - Single Dependency Override Tests

    @Suite(.dependencies)
    struct `Single Dependency Override` {

        @Test("dependency trait overrides via KeyPath", .dependency(\.simple, "trait-override"))
        func `keyPathOverride`() {
            @Dependency(\.simple) var simple
            #expect(simple == "trait-override")
        }

        @Test("dependency trait overrides int value", .dependency(\.intValue, 999))
        func `intOverride`() {
            @Dependency(\.intValue) var intValue
            #expect(intValue == 999)
        }

        @Test("dependency trait with nil optional", .dependency(\.optionalValue, nil))
        func `nilOptionalOverride`() {
            @Dependency(\.optionalValue) var optionalValue
            #expect(optionalValue == nil)
        }

        @Test("dependency trait with some optional", .dependency(\.optionalValue, "some-value"))
        func `someOptionalOverride`() {
            @Dependency(\.optionalValue) var optionalValue
            #expect(optionalValue == "some-value")
        }
    }

    // MARK: - Multiple Dependencies Override Tests

    @Suite(.dependencies)
    struct `Multiple Dependencies Override` {

        @Test(
            "dependencies closure overrides multiple values",
            .dependencies {
                $0.simple = "multi-1"
                $0.intValue = 42
                $0.stringValue = "multi-2"
            }
        )
        func `multipleOverrides`() {
            @Dependency(\.simple) var simple
            @Dependency(\.intValue) var intValue
            @Dependency(\.stringValue) var stringValue

            #expect(simple == "multi-1")
            #expect(intValue == 42)
            #expect(stringValue == "multi-2")
        }

        @Test(
            "dependencies closure can override witness types",
            .dependencies {
                $0.testAPI = TestAPI(
                    fetch: { _ in "custom-fetch" },
                    update: { _, _ in }
                )
            }
        )
        func `witnessOverride`() async throws {
            @Dependency(\.testAPI) var api
            let result = try await api.fetch(id: 1)
            #expect(result == "custom-fetch")
        }
    }

    // MARK: - Nested Suite Tests

    @Suite(.dependencies)
    struct `Nested Suite Traits` {

        @Suite(.dependency(\.simple, "outer"))
        struct `Inner Suite with Override` {

            @Test
            func `inherits outer override`() {
                @Dependency(\.simple) var simple
                #expect(simple == "outer")
            }

            @Test("can add additional override", .dependency(\.intValue, 123))
            func `additionalOverride`() {
                @Dependency(\.simple) var simple
                @Dependency(\.intValue) var intValue
                #expect(simple == "outer")
                #expect(intValue == 123)
            }

            @Test("can replace outer override", .dependency(\.simple, "inner"))
            func `replacesOuter`() {
                @Dependency(\.simple) var simple
                #expect(simple == "inner")
            }
        }
    }

    // MARK: - Isolation Tests

    @Suite(.dependencies)
    struct `Trait Isolation` {

        @Test
        func `test 1 - counting starts fresh`() {
            @Dependency(\.counting) var counting
            let client = counting  // Resolve once to preserve state
            #expect(client.increment() == 1)
            #expect(client.increment() == 2)
        }

        @Test
        func `test 2 - counting also starts fresh (isolated from test 1)`() {
            @Dependency(\.counting) var counting
            let client = counting  // Resolve once to preserve state
            #expect(client.increment() == 1)
            #expect(client.increment() == 2)
        }
    }

    // MARK: - Mode Resolution Tests

    @Suite(.dependencies)
    struct `Mode Resolution with Traits` {

        @Test
        func `uses testValue by default in trait scope`() {
            @Dependency(\.modeAware) var modeAware
            #expect(modeAware == "test-default")
        }

        @Test("override takes precedence over testValue", .dependency(\.modeAware, "overridden"))
        func `overrideTakesPrecedence`() {
            @Dependency(\.modeAware) var modeAware
            #expect(modeAware == "overridden")
        }
    }

    // MARK: - L1 Scope Tests (F-001)
    //
    // `provideScope` used to modify a throwaway, freshly-initialized L1 `Dependency.Values`
    // and discard it: any L1-only key override supplied via `.dependencies { }` never
    // reached the pushed scope, so it read back as the key's un-overridden default. This
    // suite pins down the fix — provideScope now round-trips L1 through the same
    // two-store `Witness.Context._withScope` mechanism `withDependencies` uses.
    //
    // [INST-TEST-013] extension-pattern suite for `__DependencyTestTrait`, the source
    // type that owns `provideScope`.

    extension __DependencyTestTrait {
        @Suite struct `L1 Scope` {
            @Suite struct Unit {}
            @Suite struct `Edge Case` {}
        }
    }

    extension __DependencyTestTrait.`L1 Scope`.Unit {
        @Test(.dependencies { $0[L1OnlyKey.self] = "trait-l1-override" })
        func `provideScope pushes an L1-only override into scope`() {
            #expect(Dependency<Never>.Context.current[L1OnlyKey.self] == "trait-l1-override")
        }
    }

    extension __DependencyTestTrait.`L1 Scope`.`Edge Case` {
        // Mirrors the pre-existing "Nested Suite Traits" coverage for Witness-backed
        // keys, but for an L1-only key: since the discard bug applied at every nesting
        // level (not just the root), a nested override was silently dropped too.
        @Suite(.dependencies { $0[L1OnlyKey.self] = "outer-l1" })
        struct `Nested L1 Override` {
            @Test
            func `outer scope sees the outer L1-only override`() {
                #expect(Dependency<Never>.Context.current[L1OnlyKey.self] == "outer-l1")
            }

            @Suite(.dependencies { $0[L1OnlyKey.self] = "inner-l1" })
            struct `Inner Suite with Override` {
                @Test
                func `inner scope sees its own L1-only override, not the outer one`() {
                    #expect(Dependency<Never>.Context.current[L1OnlyKey.self] == "inner-l1")
                }
            }
        }
    }
#endif
