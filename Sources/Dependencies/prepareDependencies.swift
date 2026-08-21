public import Witnesses

nonisolated(nonsending)
    public func prepareDependencies<T, E: Swift.Error>(
        _ configure: (Witness.Preparation.Store) -> Void,
        operation: nonisolated(nonsending) () async throws(E) -> T
    ) async throws(E) -> T
{
    try await Witness.Preparation.with(configure, operation: operation)
}

public func prepareDependencies<T, E: Swift.Error>(
    _ configure: (Witness.Preparation.Store) -> Void,
    operation: () throws(E) -> T
) throws(E) -> T {
    try Witness.Preparation.with(configure, operation: operation)
}
