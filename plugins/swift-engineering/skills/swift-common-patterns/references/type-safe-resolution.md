# ConcreteResolvable Pattern (Type-Safe Token Resolution)

**Use for:** Theme tokens, design systems, configuration resolution with fallbacks

**Problem:** Need type-safe resolution of design tokens with graceful fallbacks, no runtime casting.

**Solution:**
```swift
// Phantom type pattern: Resolvable → Concrete transformation
public protocol ConcreteResolvable: Sendable {
    associatedtype C: Sendable & DefaultProvider
    func resolveConcrete(in resolver: ThemeResolver, for context: ThemeContext) throws -> C
}

// Token type (resolvable)
public struct ColorToken: ConcreteResolvable, Sendable {
    public typealias C = UIColor

    let tokenPath: String

    public func resolveConcrete(in resolver: ThemeResolver, for context: ThemeContext) throws -> UIColor {
        // Try to resolve from theme
        if let color = try? resolver.resolveColor(tokenPath, context: context) {
            return color
        }
        // Fallback to default
        return UIColor.defaultValue
    }
}

// Usage
extension UIColor: DefaultProvider {
    public static var defaultValue: UIColor { .systemGray }
    public var isDefault: Bool { self == .systemGray }
}

let token = ColorToken(tokenPath: "semantic.background.base")
let resolvedColor = try token.resolveConcrete(in: themeResolver, for: .light) // UIColor
```

**Benefits:**
- Compile-time type safety (no runtime casting)
- Graceful fallback to defaults
- Works with any Sendable + DefaultProvider type
- Phantom type ensures correct resolution
