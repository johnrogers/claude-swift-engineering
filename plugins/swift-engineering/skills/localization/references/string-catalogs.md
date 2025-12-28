# String Catalogs

Xcode 15+ unified format for managing app localization. Replaces legacy .strings and .stringsdict files with a single JSON-based format.

## Creating a String Catalog

**Method 1: Xcode Navigator**
1. File > New > File
2. Choose "String Catalog"
3. Name it `Localizable.xcstrings`
4. Add to target

**Method 2: Automatic Extraction**
Build the project - Xcode extracts strings from:
- SwiftUI views (Text, Label, Button string literals)
- Swift code (`String(localized:)`)
- Objective-C (`NSLocalizedString`)
- Interface Builder files (.storyboard, .xib)
- Info.plist values

## SwiftUI Localization

### LocalizedStringKey (Automatic)

```swift
// Automatically localizable - Xcode extracts these
Text("Welcome to the App!")
Label("Shopping Cart", systemImage: "cart")
Button("Checkout") { }
```

### String(localized:) with Comments

```swift
// Basic
let title = String(localized: "Welcome")

// With translator comment (recommended)
let title = String(localized: "Welcome",
                   comment: "Main screen greeting")

// With custom table
let title = String(localized: "Welcome",
                   table: "Onboarding",
                   comment: "First launch greeting")

// With default value (key != English text)
let title = String(localized: "WELCOME_TITLE",
                   defaultValue: "Welcome to the App!",
                   comment: "Main screen title")
```

### LocalizedStringResource (Deferred Lookup)

Use when passing localizable strings to custom views:

```swift
struct CardView: View {
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource

    var body: some View {
        VStack {
            Text(title)      // Resolved at render time
            Text(subtitle)
        }
    }
}

// Usage
CardView(
    title: "Recent Purchases",
    subtitle: "Items from the past week"
)
```

### AttributedString with Markdown

```swift
// Markdown preserved across localizations
let styled = AttributedString(localized: "**Bold** and _italic_ text")
```

## String Catalog Structure

Each entry contains:
- **Key**: Unique identifier (default: the English string)
- **Default Value**: Fallback if translation missing
- **Comment**: Context for translators
- **State**: New, Needs Review, Reviewed, Stale

**Example .xcstrings JSON**:
```json
{
  "sourceLanguage": "en",
  "strings": {
    "Thanks for shopping with us!": {
      "comment": "Label above checkout button",
      "localizations": {
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "Thanks for shopping with us!"
          }
        },
        "es": {
          "stringUnit": {
            "state": "translated",
            "value": "Gracias por comprar con nosotros!"
          }
        }
      }
    }
  },
  "version": "1.0"
}
```

## Translation States

| State | Icon | Meaning |
|-------|------|---------|
| New | (empty) | Not yet translated |
| Needs Review | (yellow) | Source changed, check translation |
| Reviewed | (green) | Translation approved |
| Stale | (red) | String no longer in source code |

## UIKit & Foundation

### NSLocalizedString

```swift
let title = NSLocalizedString("Recent Purchases",
                              comment: "Section header")

// With table
let title = NSLocalizedString("Recent Purchases",
                              tableName: "Shopping",
                              comment: "Section header")
```

### Bundle.localizedString

```swift
let customBundle = Bundle(for: MyFramework.self)
let text = customBundle.localizedString(
    forKey: "Welcome",
    value: nil,
    table: "MyFramework"
)
```

## Migration from Legacy Files

### Converting .strings to .xcstrings

1. Select .strings file in Navigator
2. Editor > Convert to String Catalog
3. Xcode creates .xcstrings preserving translations

### Gradual Migration

- Keep legacy .strings for old code initially
- New code uses String Catalogs
- Both work together - Xcode checks both
- Convert one table at a time

## Common Mistakes

```swift
// WRONG - not localizable
let title = "Settings"

// CORRECT - localizable
let title = String(localized: "Settings")

// WRONG - concatenation breaks word order
let msg = String(localized: "You have") + " \(count) " + String(localized: "items")

// CORRECT - single string with substitution
let msg = String(localized: "You have \(count) items")

// WRONG - no context for translator
String(localized: "Confirm")

// CORRECT - clear context
String(localized: "Confirm", comment: "Button to confirm deletion")
```

## Troubleshooting

**Strings not appearing in catalog:**
1. Build Settings > "Use Compiler to Extract Swift Strings" > Yes
2. Clean Build Folder (Cmd+Shift+K)
3. Build project

**Translations not showing:**
1. Project > Info > Localizations > Add language
2. Check string isn't marked "Stale"
