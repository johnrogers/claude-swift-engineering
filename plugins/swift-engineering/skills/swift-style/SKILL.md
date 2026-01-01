---
name: swift-style
description: Swift code style conventions for clean, readable code. Use when writing Swift code to ensure consistent formatting, naming, organization, and idiomatic patterns.
---

# Swift Style Guide

Code style conventions for clean, readable Swift code.

## Core Principles

**Clarity > Brevity > Consistency**

Code should compile without warnings.

## Naming

- `UpperCamelCase` — Types, protocols
- `lowerCamelCase` — Everything else
- Clarity at call site
- No abbreviations except universal (URL, ID)

```swift
// Preferred
let maximumWidgetCount = 100
func fetchUser(byID id: String) -> User
```

## Golden Path

Left-hand margin is the happy path. Don't nest `if` statements.

```swift
// Preferred
func process(value: Int?) throws -> Result {
    guard let value = value else {
        throw ProcessError.nilValue
    }
    guard value > 0 else {
        throw ProcessError.invalidValue
    }
    return compute(value)
}
```

## Code Organization

Use extensions and MARK comments:

```swift
class MyViewController: UIViewController {
    // Core implementation
}

// MARK: - UITableViewDataSource
extension MyViewController: UITableViewDataSource { }
```

## Spacing

- Braces open on same line, close on new line
- One blank line between methods
- Colon: no space before, one space after

## Self

Avoid `self` unless required by compiler.

```swift
// Preferred
func configure() {
    backgroundColor = .systemBackground
}
```

## Computed Properties

Omit `get` for read-only:

```swift
var diameter: Double {
    radius * 2
}
```

## Closures

Trailing closure only for single closure parameter.

## Type Inference

Let compiler infer when clear. For empty collections, use type annotation:

```swift
var names: [String] = []
```

## Syntactic Sugar

```swift
// Preferred
var items: [String]
var cache: [String: Int]
var name: String?
```

## Access Control

- `private` over `fileprivate`
- Don't add `internal` (it's the default)
- Access control as leading specifier

## Memory Management

```swift
resource.request().onComplete { [weak self] response in
    guard let self else { return }
    self.updateModel(response)
}
```

## Comments

- Explain **why**, not what
- Use `//` or `///`, avoid `/* */`
- Keep up-to-date or delete

## Constants

Use case-less enum for namespacing:

```swift
enum Math {
    static let pi = 3.14159
}
```

## Common Mistakes

1. **Abbreviations beyond URL, ID, UUID** — Abbreviations like `cfg`, `mgr`, `ctx`, `desc` hurt readability. Spell them out: `configuration`, `manager`, `context`, `description`. The three exceptions are URL, ID, UUID.

2. **Nested guard/if statements** — Deep nesting makes code hard to follow. Use early returns and guards to keep the happy path left-aligned.

3. **Inconsistent self usage** — Either always omit `self` (preferred) or always use it. Mixing makes code scanning harder and confuses capture semantics.

4. **Overly generic type names** — `Manager`, `Handler`, `Helper`, `Coordinator` are too vague. Names should explain responsibility: `PaymentProcessor`, `EventDispatcher`, `ImageCache`, `NavigationCoordinator`.

5. **Implied access control** — Don't skip access control. Explicit `private`, `public` helps future maintainers understand module boundaries. `internal` is default, so omit it.
