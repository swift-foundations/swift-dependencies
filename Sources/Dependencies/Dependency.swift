public import Witnesses

@propertyWrapper
public struct Dependency<Value: Sendable>: Sendable {
    @usableFromInline
    internal let accessor: _Accessor<Value>

    @usableFromInline
    internal let fileID: StaticString

    @usableFromInline
    internal let line: UInt

    @inlinable
    public init(
        _ keyPath: KeyPath<__DependencyValues, Value>,
        fileID: StaticString = #fileID,
        line: UInt = #line
    ) {
        self.accessor = .keyPath(keyPath)
        self.fileID = fileID
        self.line = line
    }

    @inlinable
    public init<Key: Dependency.Key>(
        _ key: Key.Type,
        fileID: StaticString = #fileID,
        line: UInt = #line
    ) where Key.Value == Value {
        self.accessor = .closure { $0[Key.self] }
        self.fileID = fileID
        self.line = line
    }

    @inlinable
    public var wrappedValue: Value {
        accessor.getValue(from: __DependencyContext.current)
    }
}

@usableFromInline
internal enum _Accessor<Value: Sendable>: @unchecked Sendable {
    case keyPath(KeyPath<__DependencyValues, Value>)
    case closure(@Sendable (__DependencyValues) -> Value)

    @usableFromInline
    func getValue(from values: __DependencyValues) -> Value {
        switch self {
        case .keyPath(let keyPath):
            return values[keyPath: keyPath]

        case .closure(let getter):
            return getter(values)
        }
    }
}

extension Dependency {

    public typealias Values = __DependencyValues

    public typealias Context = __DependencyContext
}
