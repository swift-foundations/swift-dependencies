public import Dependencies
public import Testing

extension Dependency.Test {

    @inlinable
    public static func assertMode(
        _ expected: Dependency<Never>.Context.Mode,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        let actual = Dependency<Never>.Context.mode
        #expect(
            actual == expected,
            "Expected mode \(expected) but got \(actual)",
            sourceLocation: sourceLocation
        )
    }

    @inlinable
    public static func assertValue<V: Equatable & Sendable>(
        _ keyPath: KeyPath<Dependency<Never>.Values, V>,
        equals expected: V,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        let actual = Dependency<Never>.Context.current[keyPath: keyPath]
        #expect(
            actual == expected,
            "Dependency value mismatch",
            sourceLocation: sourceLocation
        )
    }
}
