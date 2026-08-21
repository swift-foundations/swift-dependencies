public import Dependencies
import Testing

@Witness
struct TestAPI: Sendable {
    var fetch: @Sendable (_ id: Int) async throws(Witness.Unimplemented.Error) -> String
    var update:
        @Sendable (_ id: Int, _ value: String) async throws(Witness.Unimplemented.Error) ->
            Void
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

extension Dependency.Values {
    var testAPI: TestAPI {
        get { self[TestAPI.self] }
        set { self[TestAPI.self] = newValue }
    }
}

struct SimpleKey: Dependency.Key {}

extension SimpleKey {
    typealias Value = String
    static var liveValue: String { "live" }
    static var testValue: String { "test" }
    static var previewValue: String { "preview" }
}

extension Dependency.Values {
    var simple: String {
        get { self[SimpleKey.self] }
        set { self[SimpleKey.self] = newValue }
    }
}

enum IntKey: Dependency.Key {}

extension IntKey {
    static var liveValue: Int { -1 }
    static var testValue: Int { 42 }
}

extension Dependency.Values {
    var intValue: Int {
        get { self[IntKey.self] }
        set { self[IntKey.self] = newValue }
    }
}

enum StringKey: Dependency.Key {}

extension StringKey {
    static var liveValue: String { "live-string" }
    static var testValue: String { "test-string" }
}

extension Dependency.Values {
    var stringValue: String {
        get { self[StringKey.self] }
        set { self[StringKey.self] = newValue }
    }
}

enum EagerChildKey: Dependency.Key {}

extension EagerChildKey {
    static var liveValue: Int { 1729 }
    static var testValue: Int { 1729 }
}

extension Dependency.Values {
    var eagerChild: Int {
        get { self[EagerChildKey.self] }
        set { self[EagerChildKey.self] = newValue }
    }
}

enum LazyChildKey: Dependency.Key {}

extension LazyChildKey {
    static var liveValue: @Sendable () -> Int { { 1729 } }
    static var testValue: @Sendable () -> Int { { 1729 } }
}

extension Dependency.Values {
    var lazyChild: @Sendable () -> Int {
        get { self[LazyChildKey.self] }
        set { self[LazyChildKey.self] = newValue }
    }
}

enum ModeAwareKey: Dependency.Key {}

extension ModeAwareKey {
    static var liveValue: String { "live-default" }
    static var testValue: String { "test-default" }
    static var previewValue: String { "preview-default" }
}

extension Dependency.Values {
    var modeAware: String {
        get { self[ModeAwareKey.self] }
        set { self[ModeAwareKey.self] = newValue }
    }
}

enum OptionalKey: Dependency.Key {}

extension OptionalKey {
    static var liveValue: String? { "live-optional" }
    static var testValue: String? { nil }
}

extension Dependency.Values {
    var optionalValue: String? {
        get { self[OptionalKey.self] }
        set { self[OptionalKey.self] = newValue }
    }
}

struct CountingClient: Sendable {
    private let _increment: @Sendable () -> Int

    init(_ increment: @escaping @Sendable () -> Int) {
        self._increment = increment
    }
}

extension CountingClient {
    func increment() -> Int {
        _increment()
    }
}

final class UnsafeCurrentValueContainer<Value>: @unchecked Sendable {
    var value: Value

    init(_ value: Value) {
        self.value = value
    }
}

enum CountingKey: Dependency.Key {}

extension CountingKey {
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

extension Dependency.Values {
    var counting: CountingClient {
        get { self[CountingKey.self] }
        set { self[CountingKey.self] = newValue }
    }
}
