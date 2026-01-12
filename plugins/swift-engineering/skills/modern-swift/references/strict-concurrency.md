# Strict Concurrency (Swift 6)

Swift 6's strict concurrency checking eliminates data races at compile time.

## Enabling Strict Concurrency

### Package.swift
```swift
.target(
    name: "MyTarget",
    swiftSettings: [
        .enableUpcomingFeature("StrictConcurrency")
    ]
)
```

### Build Settings (Xcode)
- SWIFT_STRICT_CONCURRENCY = complete

## What Strict Mode Enforces

1. **Sendable conformance** for values crossing actor boundaries
2. **Isolation checking** for @MainActor and actor types
3. **No implicit captures** of non-Sendable types in async contexts
4. **Proper annotations** on global variables and functions

## Typed Throws (Swift 6.2)

Specify the exact error type a function throws.

### Basic Typed Throws
```swift
enum ValidationError: Error {
    case tooShort
    case invalidFormat
}

func validate(_ input: String) throws(ValidationError) {
    guard input.count > 5 else {
        throw ValidationError.tooShort
    }
}

// Caller knows exact error type
do {
    try validate("abc")
} catch {
    // error is ValidationError, not any Error
    switch error {
    case .tooShort: print("Too short")
    case .invalidFormat: print("Invalid")
    }
}
```

### Never Throws
```swift
func parseInteger(_ string: String) throws(Never) -> Int {
    // Compiler knows this never throws
    Int(string) ?? 0
}

// No try needed
let value = parseInteger("123")
```

### Generic Throws
```swift
func transform<E: Error>(
    _ value: String,
    using: (String) throws(E) -> Int
) throws(E) -> Int {
    try using(value)
}
```

## Common Strict Concurrency Fixes

### Global Variables
```swift
// ❌ Error: Global mutable state
var sharedCache: [String: Data] = [:]

// ✅ Use actor
actor SharedCache {
    private var cache: [String: Data] = [:]
}

// ✅ Or @MainActor for UI state
@MainActor
var currentTheme: Theme = .light
```

### Closures Capturing Non-Sendable
```swift
class ViewModel {
    var items: [Item] = []

    func load() {
        // ❌ Error: Capturing non-Sendable self
        Task {
            self.items = await fetch()
        }
    }
}

// ✅ Make ViewModel @MainActor
@MainActor
class ViewModel {
    var items: [Item] = []

    func load() {
        Task {
            self.items = await fetch()
        }
    }
}
```

### Non-Sendable Function Parameters
```swift
// ❌ Error: Non-Sendable closure
func runAsync(_ action: () -> Void) async {
    action()
}

// ✅ Require Sendable
func runAsync(_ action: @Sendable () -> Void) async {
    action()
}
```

## Sendable Inference

Swift 6 automatically infers Sendable for:
- Structs with all Sendable stored properties
- Enums with all Sendable associated values
- Actors
- Final classes with only immutable Sendable properties

```swift
// Automatically Sendable
struct User {
    let id: String
    let name: String
}

// NOT automatically Sendable (has var)
struct MutableUser {
    var name: String
}
```

## @unchecked Sendable for External Types

When your type contains types from external packages that aren't yet Sendable, use `@unchecked Sendable` with a TODO comment:

```swift
@Reducer public struct FeatureTracking {
    public struct Tracker: Sendable {
        // TODO: @unchecked Sendable - Contains LegacyRecord (LegacySDK) and CLLocation (CoreLocation)
        // which are not marked Sendable. Revisit when LegacySDK is modernized to Swift 6.
        public enum Event: Equatable, @unchecked Sendable {
            case operationRequested(
                record: LegacyRecord,    // External type — not Sendable
                location: CLLocation?    // Apple type — not Sendable
            )
            case operationSuccess
            case operationFailure(String)
        }
    }
}
```

### When to Use @unchecked Sendable

| Scenario | Use @unchecked Sendable? |
|----------|-------------------------|
| External type not Sendable (CLLocation, etc.) | ✅ Yes, with TODO |
| Apple framework type not Sendable | ✅ Yes, with TODO |
| Your own mutable class | ❌ No, make it an actor |
| Immutable reference type | ✅ Yes, if truly immutable |
| Type with `var` properties | ❌ No, use actor or redesign |

### Common External Types Requiring @unchecked

- `CLLocation`, `CLLocationCoordinate2D` (CoreLocation)
- Types from legacy Obj-C frameworks not yet audited for Sendable
- Third-party SDK types

### @preconcurrency import Alternative

For imports from packages not yet migrated, use `@preconcurrency import`:

```swift
@preconcurrency import LegacySDK  // Suppresses Sendable warnings for LegacyRecord, LegacyUser, etc.
import CoreLocation  // CLLocation still requires @unchecked Sendable
```

**Prefer @preconcurrency** for entire modules. Use **@unchecked Sendable** for individual types when the import approach isn't sufficient.

## Migration Strategy

1. Enable strict concurrency in one module at a time
2. Fix global mutable state first (use actors or @MainActor)
3. Add @MainActor to view models and UI classes
4. Add @Sendable to closure parameters
5. Use @preconcurrency for legacy dependencies (see modern-attributes.md)
6. Add TODO comments to @unchecked Sendable uses for future cleanup
