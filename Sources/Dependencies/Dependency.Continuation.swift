public import Witnesses

extension Dependency {

    public typealias Continuation = Witness.Context.Escaped
}

extension __DependencyContext {

    @inlinable
    public static func withEscaped<R, E: Swift.Error>(
        _ operation: (Dependency<Never>.Continuation) throws(E) -> R
    ) throws(E) -> R {
        try Witness.Context.withEscaped(operation)
    }

    @inlinable
    public static func withEscaped<R, E: Swift.Error>(
        _ operation: (Dependency<Never>.Continuation) async throws(E) -> R
    ) async throws(E) -> R {
        try await Witness.Context.withEscaped(operation)
    }
}
