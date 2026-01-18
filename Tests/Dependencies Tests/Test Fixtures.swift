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
public import Dependencies

/// Test witness for basic dependency operations.
@Witness
struct TestAPI: Sendable {
    var fetch: @Sendable (_ id: Int) async throws(Witness.Unimplemented.Error) -> String
    var update: @Sendable (_ id: Int, _ value: String) async throws(Witness.Unimplemented.Error) -> Void
}

extension TestAPI: Dependency.Key {
    static var liveValue: TestAPI {
        TestAPI(
            fetch: { id in "Live result for \(id)" },
            update: { _, _ in }
        )
    }

    static var testValue: TestAPI {
        TestAPI(
            fetch: { id in "Test result for \(id)" },
            update: { _, _ in }
        )
    }
}

/// Extension for KeyPath-based access.
extension __DependencyValues {
    var testAPI: TestAPI {
        get { self[TestAPI.self] }
        set { self[TestAPI.self] = newValue }
    }
}

/// Simple non-witness key for basic testing.
struct SimpleKey: Dependency.Key {
    typealias Value = String
    static var liveValue: String { "live" }
    static var testValue: String { "test" }
    static var previewValue: String { "preview" }
}

/// Extension for KeyPath-based access.
extension __DependencyValues {
    var simple: String {
        get { self[SimpleKey.self] }
        set { self[SimpleKey.self] = newValue }
    }
}

// MARK: - Additional Test Keys

/// Int key for testing
enum IntKey: Dependency.Key {
    static var liveValue: Int { -1 }
    static var testValue: Int { 42 }
}

extension __DependencyValues {
    var intValue: Int {
        get { self[IntKey.self] }
        set { self[IntKey.self] = newValue }
    }
}

/// String key for testing (distinct from SimpleKey)
enum StringKey: Dependency.Key {
    static var liveValue: String { "live-string" }
    static var testValue: String { "test-string" }
}

extension __DependencyValues {
    var stringValue: String {
        get { self[StringKey.self] }
        set { self[StringKey.self] = newValue }
    }
}

/// Eager child dependency - resolved at access time
enum EagerChildKey: Dependency.Key {
    static var liveValue: Int { 1729 }
    static var testValue: Int { 1729 }
}

extension __DependencyValues {
    var eagerChild: Int {
        get { self[EagerChildKey.self] }
        set { self[EagerChildKey.self] = newValue }
    }
}

/// Lazy child dependency - resolved when closure is called
enum LazyChildKey: Dependency.Key {
    static var liveValue: @Sendable () -> Int { { 1729 } }
    static var testValue: @Sendable () -> Int { { 1729 } }
}

extension __DependencyValues {
    var lazyChild: @Sendable () -> Int {
        get { self[LazyChildKey.self] }
        set { self[LazyChildKey.self] = newValue }
    }
}

/// Key with distinct values for each mode
enum ModeAwareKey: Dependency.Key {
    static var liveValue: String { "live-default" }
    static var testValue: String { "test-default" }
    static var previewValue: String { "preview-default" }
}

extension __DependencyValues {
    var modeAware: String {
        get { self[ModeAwareKey.self] }
        set { self[ModeAwareKey.self] = newValue }
    }
}

/// Key with optional value
enum OptionalKey: Dependency.Key {
    static var liveValue: String? { "live-optional" }
    static var testValue: String? { nil }
}

extension __DependencyValues {
    var optionalValue: String? {
        get { self[OptionalKey.self] }
        set { self[OptionalKey.self] = newValue }
    }
}

/// Counting client for isolation testing
struct CountingClient: Sendable {
    private let _increment: @Sendable () -> Int

    init(_ increment: @escaping @Sendable () -> Int) {
        self._increment = increment
    }

    func increment() -> Int {
        _increment()
    }
}

/// Unsafe container for testing (not for production use)
final class UnsafeCurrentValueContainer<Value>: @unchecked Sendable {
    var value: Value

    init(_ value: Value) {
        self.value = value
    }
}

/// Counting key that tracks invocations
enum CountingKey: Dependency.Key {
    static var liveValue: CountingClient {
        let count = UnsafeCurrentValueContainer(0)
        return CountingClient {
            count.value += 1
            return count.value
        }
    }

    static var testValue: CountingClient {
        let count = UnsafeCurrentValueContainer(0)
        return CountingClient {
            count.value += 1
            return count.value
        }
    }
}

extension __DependencyValues {
    var counting: CountingClient {
        get { self[CountingKey.self] }
        set { self[CountingKey.self] = newValue }
    }
}
