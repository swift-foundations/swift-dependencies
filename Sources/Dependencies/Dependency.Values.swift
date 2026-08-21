public import Dependency_Primitives
public import Witnesses

public struct __DependencyValues: Sendable {

    public var _witnessValues: Witness.Values

    public var _l1Values: Dependency_Primitives.Dependency.Values

    @inlinable
    public init(
        _witnessValues: Witness.Values = Witness.Values(),
        _l1Values: Dependency_Primitives.Dependency.Values = .init()
    ) {
        self._witnessValues = _witnessValues
        self._l1Values = _l1Values
    }
}

extension __DependencyValues {

    @inlinable
    public subscript<K: Witness.Key>(key: K.Type) -> K.Value where K.Value: Copyable {
        get { Witness.Context[key] }
        set { _witnessValues[key] = newValue }
    }
}

extension __DependencyValues {

    @inlinable
    public subscript<K: Witness.Key.Test>(key: K.Type) -> K.Value where K.Value: Copyable {
        get { Witness.Context[key] }
        set { _witnessValues[key] = newValue }
    }
}

extension __DependencyValues {

    @inlinable
    public subscript<K: __DependencyKey>(key: K.Type) -> K.Value where K.Value: Copyable {
        get { _l1Values[K.self] }
        set { _l1Values[K.self] = newValue }
    }
}
