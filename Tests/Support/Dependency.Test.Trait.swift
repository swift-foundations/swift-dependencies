#if canImport(Testing) && compiler(>=6)
    public import Testing
    public import Dependencies
    public import Dependency_Primitives
    public import Witnesses

    @_documentation(visibility: private)
    public struct __DependencyTestTrait: TestScoping, TestTrait, SuiteTrait {

        let updateValues: @Sendable (inout __DependencyValues) -> Void
    }

    extension __DependencyTestTrait {

        @TaskLocal static var isRoot = true

        public var isRecursive: Bool { true }

        @concurrent public func provideScope(
            for test: Testing.Test,
            testCase: Testing.Test.Case?,
            performing function: @Sendable @concurrent () async throws -> Void
        ) async throws {
            try await Witness.Context._withScope(
                mode: .test,
                { witnessValues, l1Values in
                    if Self.isRoot {
                        witnessValues = Witness.Values()

                        l1Values = Dependency_Primitives.Dependency.Values.forTesting()
                    }
                    var depValues = __DependencyValues(_witnessValues: witnessValues, _l1Values: l1Values)
                    updateValues(&depValues)
                    witnessValues = depValues._witnessValues
                    l1Values = depValues._l1Values
                },
                operation: {
                    try await Self.$isRoot.withValue(false) {
                        try await function()
                    }
                }
            )
        }
    }

    extension Dependencies.Dependency.Test {

        public typealias _Trait = __DependencyTestTrait
    }
#endif
