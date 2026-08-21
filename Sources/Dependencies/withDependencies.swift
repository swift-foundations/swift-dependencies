public import Dependency_Primitives
public import Witnesses

@inlinable
public func withDependencies<T, E: Swift.Error>(
    _ modify: (inout __DependencyValues) -> Void,
    operation: () throws(E) -> T
) throws(E) -> T {
    try Witness.Context._withScope(
        { witnessValues, l1Values in
            var depValues = __DependencyValues(
                _witnessValues: witnessValues,
                _l1Values: l1Values
            )
            modify(&depValues)
            witnessValues = depValues._witnessValues
            l1Values = depValues._l1Values
        },
        operation: operation
    )
}

@inlinable
nonisolated(nonsending)
    public func withDependencies<T, E: Swift.Error>(
        _ modify: (inout __DependencyValues) -> Void,
        operation: nonisolated(nonsending) () async throws(E) -> T
    ) async throws(E) -> T
{
    try await Witness.Context._withScope(
        { witnessValues, l1Values in
            var depValues = __DependencyValues(
                _witnessValues: witnessValues,
                _l1Values: l1Values
            )
            modify(&depValues)
            witnessValues = depValues._witnessValues
            l1Values = depValues._l1Values
        },
        operation: operation
    )
}

@inlinable
public func withDependencies<T, E: Swift.Error>(
    mode: __DependencyContext.Mode,
    _ modify: ((inout __DependencyValues) -> Void)? = nil,
    operation: () throws(E) -> T
) throws(E) -> T {
    try Witness.Context._withScope(
        mode: mode,
        { witnessValues, l1Values in
            if let modify {
                var depValues = __DependencyValues(
                    _witnessValues: witnessValues,
                    _l1Values: l1Values
                )
                modify(&depValues)
                witnessValues = depValues._witnessValues
                l1Values = depValues._l1Values
            }
        },
        operation: operation
    )
}

@inlinable
nonisolated(nonsending)
    public func withDependencies<T, E: Swift.Error>(
        mode: __DependencyContext.Mode,
        _ modify: ((inout __DependencyValues) -> Void)? = nil,
        operation: nonisolated(nonsending) () async throws(E) -> T
    ) async throws(E) -> T
{
    try await Witness.Context._withScope(
        mode: mode,
        { witnessValues, l1Values in
            if let modify {
                var depValues = __DependencyValues(
                    _witnessValues: witnessValues,
                    _l1Values: l1Values
                )
                modify(&depValues)
                witnessValues = depValues._witnessValues
                l1Values = depValues._l1Values
            }
        },
        operation: operation
    )
}
