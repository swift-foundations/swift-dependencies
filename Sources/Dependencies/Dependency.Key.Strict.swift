public import Witnesses

public protocol __DependencyKeyStrict: Witness.Key {}

extension __DependencyKeyStrict {

    public static var testValue: Value {
        fatalError(
            """
            '\(Self.self)' is a strict dependency that must be explicitly overridden in tests.

            Override in your test:
                withDependencies {
                    $0[\(Self.self).self] = .testDouble
                } operation: {
                    // ...
                }
            """
        )
    }
}

extension Dependency.Key {

    public typealias Strict = __DependencyKeyStrict
}
