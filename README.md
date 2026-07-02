# swift-dependencies

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Type-safe dependency injection for Swift: the `@Dependency` property wrapper resolves values through a live, preview, and test chain, with scoped overrides supplied by `withDependencies`.

---

## Key Features

- **`@Dependency` property wrapper** — Reaches a dependency by KeyPath or key type, with no constructor threading through the call graph.
- **Live, preview, and test resolution** — Each `Dependency.Key` resolves through `testValue → previewValue → liveValue`, selected by the current `Dependency.Context` mode.
- **Scoped overrides** — `withDependencies` replaces values for the duration of a synchronous or asynchronous operation; nested scopes inherit and override outer values.
- **Typed throws preserved** — Operations carry their concrete error type through the scope (`throws(E)`), so the API surface introduces no `any Error`.
- **Strict keys** — `Dependency.Key.Strict` makes a dependency fail fast in tests unless an explicit override is supplied.
- **Escaping-closure capture** — `Dependency.Continuation` carries the active context into timers, callbacks, and other escaping closures.
- **Task-local storage** — Resolution is backed by task-local state rather than global mutable state.

---

## Quick Start

Declare a dependency with a live value and a deterministic test value, register it for KeyPath access, and reach it from feature code through `@Dependency`. The feature type takes no initializer parameter for the collaborator:

```swift
import Dependencies

struct RandomNumbers: Sendable {
    var next: @Sendable () -> Int
}

extension RandomNumbers: Dependency.Key {
    static var liveValue: RandomNumbers { RandomNumbers { Int.random(in: 1...100) } }
    static var testValue: RandomNumbers { RandomNumbers { 42 } }  // deterministic
}

extension Dependency.Values {
    var randomNumbers: RandomNumbers {
        get { self[RandomNumbers.self] }
        set { self[RandomNumbers.self] = newValue }
    }
}

struct DiceGame {
    @Dependency(\.randomNumbers) var randomNumbers

    func roll() -> Int { randomNumbers.next() }
}
```

In a test, pin the dependency to a fixed value for one scope — `DiceGame` is never modified or re-initialized to accept the substitute:

```swift
let outcome = withDependencies {
    $0.randomNumbers = RandomNumbers { 6 }
} operation: {
    DiceGame().roll()
}
// outcome == 6
```

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-foundations/swift-dependencies.git", branch: "main")
]
```

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies")
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26.

---

## Architecture

Three library products. Module import names replace spaces with underscores (`import Dependencies`, `import Clocks_Dependency`, `import Dependencies_Test_Support`).

| Product | When to import |
|---------|----------------|
| `Dependencies` | App and library code: the `@Dependency` wrapper, `withDependencies`, `prepareDependencies`, and the `Dependency.Key` / `Dependency.Values` / `Dependency.Context` surface. |
| `Clocks Dependency` | Code that needs a ready-made `\.clock` dependency resolving to a real clock when live and an immediate clock in tests and previews. Gated behind the `Clocks` package trait. |
| `Dependencies Test Support` | Test targets: re-exports `Dependencies` and adds Swift Testing traits (`.dependencies`, `.dependency(_:_:)`) for per-test and per-suite dependency isolation. |

---

## Community

<!-- BEGIN: discussion -->
*Discussion thread will be created at first public release.*
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE](LICENSE.md).
