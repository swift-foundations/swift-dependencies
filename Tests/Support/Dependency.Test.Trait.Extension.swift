#if canImport(Testing) && compiler(>=6)
    public import Testing
    public import Dependencies
    internal import Reference_Primitives

    extension Trait where Self == __DependencyTestTrait {

        public static var dependencies: Self {
            Self { _ in }
        }

        public static func dependency<Value: Sendable>(
            _ keyPath: WritableKeyPath<__DependencyValues, Value>,
            _ value: @autoclosure @escaping @Sendable () -> Value
        ) -> Self {
            let kp = Reference.Sendability.Unchecked(__unchecked: keyPath)
            return Self { $0[keyPath: kp.value] = value() }
        }

        public static func dependency<Key: Witness.Key>(
            _ value: @autoclosure @escaping @Sendable () -> Key
        ) -> Self where Key.Value == Key {
            Self { $0[Key.self] = value() }
        }

        public static func dependencies(
            _ updateValues: @escaping @Sendable (inout __DependencyValues) -> Void
        ) -> Self {
            Self(updateValues: updateValues)
        }
    }
#endif
