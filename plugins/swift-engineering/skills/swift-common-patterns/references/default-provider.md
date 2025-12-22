# DefaultProvider Protocol Pattern

**Use for:** Configuration types, theme tokens, style objects, default values

**Problem:** Need consistent defaults and easy comparison across configuration types.

**Solution:**
```swift
public protocol DefaultProvider: Sendable {
    static var defaultValue: Self { get }
    var isDefault: Bool { get }
}

// Implementation
public struct ArticleCardConfig: DefaultProvider, Sendable {
    public static let defaultValue = ArticleCardConfig(
        showThumbnail: true,
        titleLines: 2,
        showAuthor: true
    )

    public var isDefault: Bool {
        self == .defaultValue
    }

    public let showThumbnail: Bool
    public let titleLines: Int
    public let showAuthor: Bool
}

// Usage
let config: ArticleCardConfig = .defaultValue
if config.isDefault {
    // Use optimized rendering
}
```

**Benefits:**
- Consistent default pattern across all config types
- Easy to check if using default (no magic values)
- Sendable compliance built-in
- Self-documenting code
