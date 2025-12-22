# Macros (Swift 5.9+)

Swift macros enable compile-time code generation and transformation.

## Two Types of Macros

### Freestanding Macros
Start with `#`, expand to code at the call site.

```swift
// Usage
let url = #URL("https://example.com")

// Expands to compile-time validated URL
```

### Attached Macros
Start with `@`, modify or add to declarations.

```swift
// Usage
@OptionSet
struct Permission {
    private enum Options: Int {
        case read = 1
        case write = 2
        case delete = 4
    }
}

// Expands to add conformance, properties, initializers
```

## Common Freestanding Macros

### #URL
```swift
// Compile-time URL validation
let api = #URL("https://api.example.com/users")
// Error if URL is invalid
```

### #selector, #keyPath
```swift
// Type-safe selectors (UIKit)
button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)

// Type-safe key paths
let name = user[keyPath: #keyPath(User.name)]
```

## Common Attached Macros

### @OptionSet
Generates RawRepresentable conformance for option sets.

```swift
@OptionSet<UInt8>
struct ShippingOptions {
    private enum Options: Int {
        case nextDay
        case priority
        case gift
    }
}

// Generated: init, contains, insert, remove, etc.
let options: ShippingOptions = [.nextDay, .gift]
```

### @Observable (SwiftUI)
Generates observation infrastructure for SwiftUI.

```swift
@Observable
class ViewModel {
    var count = 0
}

// No need for @Published or ObservableObject
```

## Macro Roles

Macros are defined with specific roles that determine what they can do:

| Role | What It Does | Example |
|------|--------------|---------|
| `@freestanding(expression)` | Expands to an expression | `#URL` |
| `@attached(member)` | Adds members to a type | `@Observable` |
| `@attached(peer)` | Adds peer declarations | `@Test` generates async variant |
| `@attached(accessor)` | Adds getters/setters | `@Observable` property wrapper |
| `@attached(memberAttribute)` | Adds attributes to members | Apply `@MainActor` to all members |
| `@attached(conformance)` | Adds protocol conformances | `@OptionSet` adds `OptionSet` |

## When to Use Macros

### ✅ Good Use Cases
- Eliminating boilerplate (OptionSet, Observable)
- Compile-time validation (#URL, #require)
- Code generation from declarations
- Type-safe wrappers

### ❌ Avoid For
- Runtime logic (use functions)
- Simple code reuse (use functions/protocols)
- Complex transformations (hard to debug)
- Anything achievable with protocols/generics

## Macro Expansion

Macros expand at compile time. View expansions in Xcode:
- Right-click macro usage
- "Expand Macro" to see generated code

```swift
@OptionSet
struct Permissions {
    private enum Options: Int {
        case read, write
    }
}

// Expand to see:
// - OptionSet conformance
// - Static properties
// - Initializers
// - Insert/remove methods
```

## Creating Macros (High-Level)

Macros are separate Swift packages:

1. **Define** the macro signature in your package
2. **Implement** using SwiftSyntax in a macro target
3. **Test** the expansion
4. **Use** in your code

This is advanced - most developers only **use** macros, not create them.

## Key Principles

1. **Additive only** - Macros can't remove code
2. **Deterministic** - Same input = same output
3. **Sandboxed** - No file system, network, etc.
4. **Inspectable** - Always viewable via "Expand Macro"
