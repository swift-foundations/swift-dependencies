public import Dependencies
import Witnesses

extension Dependency {

    public enum Test {}
}

extension Dependency.Test {

    public static func withOverrides<T, E: Swift.Error>(
        _ modify: @escaping (inout __DependencyValues) -> Void,
        operation: () throws(E) -> T
    ) throws(E) -> T {
        try Witness.Context._withScope(
            mode: .test,
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

    nonisolated(nonsending)
        public static func withOverrides<T, E: Swift.Error>(
            _ modify: @escaping (inout __DependencyValues) -> Void,
            operation: nonisolated(nonsending) () async throws(E) -> T
        ) async throws(E) -> T
    {
        try await Witness.Context._withScope(
            mode: .test,
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
}
