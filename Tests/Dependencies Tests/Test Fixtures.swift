// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-dependencies open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-dependencies
// project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Testing
public import Dependencies

/// Test witness for basic dependency operations.
@Witness
struct TestAPI: Sendable {
    var fetch: @Sendable (_ id: Int) async throws(Witness.Unimplemented.Error) -> String
    var update: @Sendable (_ id: Int, _ value: String) async throws(Witness.Unimplemented.Error) -> Void
}

extension TestAPI: Dependency.Key {
    static var liveValue: TestAPI {
        TestAPI(
            fetch: { id in "Live result for \(id)" },
            update: { _, _ in }
        )
    }

    static var testValue: TestAPI {
        TestAPI(
            fetch: { id in "Test result for \(id)" },
            update: { _, _ in }
        )
    }
}

/// Extension for KeyPath-based access.
extension __DependencyValues {
    var testAPI: TestAPI {
        get { self[TestAPI.self] }
        set { self[TestAPI.self] = newValue }
    }
}

/// Simple non-witness key for basic testing.
struct SimpleKey: Dependency.Key {
    typealias Value = String
    static var liveValue: String { "live" }
    static var testValue: String { "test" }
    static var previewValue: String { "preview" }
}

/// Extension for KeyPath-based access.
extension __DependencyValues {
    var simple: String {
        get { self[SimpleKey.self] }
        set { self[SimpleKey.self] = newValue }
    }
}
