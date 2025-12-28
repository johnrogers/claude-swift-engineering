# Pluralization

Handling plural forms correctly is critical for proper localization. Different languages have vastly different plural rules.

## Plural Categories by Language

| Language | Forms | Categories |
|----------|-------|------------|
| English | 2 | one, other |
| French | 2 | one, other |
| Russian | 3 | one, few, many |
| Polish | 3 | one, few, other |
| Arabic | 6 | zero, one, two, few, many, other |
| Japanese | 1 | other (no plural distinction) |

## SwiftUI Plural Handling

Xcode automatically creates plural variations when you interpolate numbers:

```swift
// Xcode creates plural variations automatically
Text("\(count) items")

// With custom formatting
Text("\(visitorCount) Recent Visitors")
```

In the String Catalog, Xcode generates entries for each plural form:

**String Catalog JSON**:
```json
{
  "%lld items": {
    "localizations": {
      "en": {
        "variations": {
          "plural": {
            "one": {
              "stringUnit": {
                "state": "translated",
                "value": "%lld item"
              }
            },
            "other": {
              "stringUnit": {
                "state": "translated",
                "value": "%lld items"
              }
            }
          }
        }
      }
    }
  }
}
```

## Multiple Variables

When strings have multiple numeric placeholders, Xcode creates variations for each:

```swift
let message = String(localized: "\(songCount) songs on \(albumCount) albums")
```

**Combinations generated**:
- songCount=one, albumCount=one: "1 song on 1 album"
- songCount=one, albumCount=other: "1 song on 3 albums"
- songCount=other, albumCount=one: "5 songs on 1 album"
- songCount=other, albumCount=other: "5 songs on 3 albums"

Total: 2 x 2 = 4 translation entries for English.

## Working with the String Catalog Editor

1. Select the string in String Catalog
2. Click "Vary by Plural" in the inspector
3. Add translations for each required form

**Important**: Always provide all required plural forms for each language. Missing forms fall back to "other".

## Legacy stringsdict Format

Before String Catalogs, plurals used .stringsdict files:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>%lld items</key>
    <dict>
        <key>NSStringLocalizedFormatKey</key>
        <string>%#@items@</string>
        <key>items</key>
        <dict>
            <key>NSStringFormatSpecTypeKey</key>
            <string>NSStringPluralRuleType</string>
            <key>NSStringFormatValueTypeKey</key>
            <string>lld</string>
            <key>one</key>
            <string>%lld item</string>
            <key>other</key>
            <string>%lld items</string>
        </dict>
    </dict>
</dict>
</plist>
```

**Migration**: Convert .stringsdict to String Catalog using Editor > Convert to String Catalog. Plural variations are preserved.

## Format Specifiers

| Specifier | Type | Example |
|-----------|------|---------|
| %lld | Int64 | `"\(count) items"` |
| %d | Int32 | Legacy, use %lld |
| %@ | String | `"\(name) items"` |
| %.2f | Double | `"\(price) dollars"` |

## Code Patterns

### Explicit Plural Handling

```swift
// Let String Catalog handle plurals
let itemLabel = String(localized: "\(itemCount) items",
                       comment: "Shopping cart item count")

// For complex cases, use AttributedString
let styled = AttributedString(localized: "You have **\(count)** items")
```

### Avoiding Plural Mistakes

```swift
// WRONG - grammatically incorrect in most languages
Text("\(count) item(s)")

// WRONG - hardcoded English logic
Text(count == 1 ? "1 item" : "\(count) items")

// CORRECT - let String Catalog handle it
Text("\(count) items")
```

### Zero Special Case

Some languages have special "zero" form:

```swift
// In English, we might want special zero handling
// String Catalog can provide device variations
Text("\(count) notifications")

// Zero: "No notifications"
// One: "1 notification"
// Other: "5 notifications"
```

Configure in String Catalog by adding "zero" variation.

## XLIFF Export

When exporting for translation, plural forms appear cleanly:

```xml
<trans-unit id="%lld items|==|plural.one">
    <source>%lld item</source>
    <target>%lld elemento</target>
</trans-unit>

<trans-unit id="%lld items|==|plural.other">
    <source>%lld items</source>
    <target>%lld elementos</target>
</trans-unit>
```

## Testing Plurals

**Scheme Options**:
1. Edit Scheme > Run > Options
2. App Language > Choose target language

**Preview Testing**:
```swift
struct ItemCountView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ItemCountView(count: 0)
            ItemCountView(count: 1)
            ItemCountView(count: 2)
            ItemCountView(count: 5)
            ItemCountView(count: 21)  // Tests Russian "one" form
        }
    }
}
```

## Troubleshooting

**Plural forms not appearing**:
1. Ensure string uses interpolation: `"\(count) items"`
2. Build project to extract strings
3. Check "Vary by Plural" is enabled in String Catalog

**Wrong plural form selected**:
- Verify you're testing with correct locale
- Check format specifier matches variable type
- Russian/Polish have complex rules - test with various numbers

**Stringsdict not converting**:
- Ensure .strings and .stringsdict have same base name
- Both files must be in same location
- Convert together for merged result
