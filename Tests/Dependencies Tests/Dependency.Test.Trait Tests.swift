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
#endif
