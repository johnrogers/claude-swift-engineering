# Modern Attributes (Swift 5.9-6.2)

New attributes introduced in recent Swift versions.

## @preconcurrency

Suppresses strict concurrency warnings for legacy code during migration.

### On Imports
```swift
// Suppress warnings from dependencies not yet updated for Swift 6
@preconcurrency import LegacyNetworking

// Use LegacyNetworking types without Sendable warnings
```

### On Protocols
```swift
// Allow non-Sendable types to conform during migration
@preconcurrency
protocol DataSource {
    func fetchData() async -> Data
}

// Classes can conform without Sendable requirement
class LocalDataSource: DataSource {
    func fetchData() async -> Data { ... }
}
```

### On Types
```swift
// Mark type as "will be Sendable eventually"
@preconcurrency
class LegacyManager {
    var state: String = ""
}
```

## @backDeployed

Makes new API implementations available on older OS versions.

```swift
extension String {
    // Available on iOS 13+, but implemented on iOS 17+
    @backDeployed(before: iOS 17)
    @available(iOS 13, *)
    func trimmed() -> String {
        trimmingCharacters(in: .whitespaces)
    }
}

// iOS 13-16: Uses the provided implementation
// iOS 17+: Uses system implementation (if different)
```

### When to Use
- Library evolution
- Backporting system APIs
- Gradual feature rollout

## package Access Control (Swift 5.9)

New access level between `internal` and `public`.

```swift
// MyLibrary/Sources/Core/User.swift
package struct User {
    package let id: String
    package let name: String
}

// MyLibrary/Sources/Networking/API.swift
package func fetchUser() -> User {
    // Visible within MyLibrary package
}

// App/main.swift
import MyLibrary
// User and fetchUser are NOT visible here
```

### Access Levels Summary
```
private < fileprivate < internal < package < public < open
```

| Level | Visible To |
|-------|------------|
| `private` | Current declaration |
| `fileprivate` | Current file |
| `internal` | Current module |
| `package` | Current package |
| `public` | Importers (no subclass/override) |
| `open` | Importers (can subclass/override) |

## @available(*, noasync)

Prevents async usage of specific APIs.

```swift
@available(*, noasync)
func dangerousBlockingOperation() {
    // Blocks thread - don't call from async context
    Thread.sleep(forTimeInterval: 5)
}

// ❌ Compile error in async context
async {
    dangerousBlockingOperation()
}
```

### Use Cases
- Mark blocking I/O
- Prevent deadlocks
- Legacy synchronous APIs

## @_exported (Underscore Attributes)

Re-exports a module's public API.

```swift
// In your module
@_exported import Foundation

// Users importing your module get Foundation too
import MyModule
// Can use Foundation types without separate import
```

**Warning**: `@_exported` is underscored = not stable API. Use sparingly.

## Macro Attributes

See [macros.md](macros.md) for:
- `@attached(member)`
- `@attached(peer)`
- `@attached(accessor)`
- `@attached(memberAttribute)`
- `@attached(conformance)`
- `@freestanding(expression)`

## Migration Patterns

### Swift 5.x to Swift 6
```swift
// 1. Add @preconcurrency to imports
@preconcurrency import LegacySDK

// 2. Use package for internal APIs
package func helperMethod() { }

// 3. Mark blocking code
@available(*, noasync)
func blockingWork() { }
```

### Library Evolution
```swift
// Backport new features
@backDeployed(before: iOS 18)
@available(iOS 15, *)
func modernFeature() { }
```
