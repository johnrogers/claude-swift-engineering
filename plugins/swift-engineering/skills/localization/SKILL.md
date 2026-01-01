---
name: localization
description: Use when implementing internationalization (i18n), String Catalogs, pluralization, or right-to-left layout support. Covers modern localization workflows with Xcode String Catalogs and LocalizedStringKey patterns.
---

# Localization

Modern iOS localization using String Catalogs (.xcstrings) for managing translations, plural forms, and locale-aware content. Supports SwiftUI's LocalizedStringKey and String(localized:) APIs.

## Quick Reference

| Reference | Load When |
|-----------|-----------|
| **[String Catalogs](references/string-catalogs.md)** | Setting up or using Xcode 15+ String Catalogs |
| **[Pluralization](references/pluralization.md)** | Handling plural forms, stringsdict migration |
| **[Formatting](references/formatting.md)** | Date, number, currency locale-aware formatting |
| **[RTL Support](references/rtl-support.md)** | Right-to-left layouts, semantic directions |

## Core Workflow

1. Create String Catalog in Xcode (File > New > String Catalog)
2. Mark strings with `String(localized:comment:)` or use SwiftUI's automatic extraction
3. Add plural variants in String Catalog editor where needed
4. Test with pseudo-localization (Scheme > Run > Options > App Language)
5. Export for translation (File > Export Localizations)

## Key Patterns

```swift
// SwiftUI - automatic localization
Text("Welcome")
Button("Continue") { }

// Explicit localization with context
let title = String(localized: "Settings", comment: "Navigation title")

// Deferred localization for custom views
struct CardView: View {
    let title: LocalizedStringResource
    var body: some View { Text(title) }
}
```

## Build Settings

- **Use Compiler to Extract Swift Strings**: Yes
- **Localization Prefers String Catalogs**: Yes

## Common Mistakes

1. **Forgetting String Catalog in Build Phases** — Adding String Catalog but forgetting to check "Localize" in File Inspector means it's not embedded. Always verify in Build Phases > Copy Bundle Resources.

2. **Pseudo-localization not tested** — Not running your app with pseudo-localization (German/Chinese pseudo-locale) means you miss text overflow and RTL issues. Always test with pseudo-localization before translation.

3. **Hardcoded strings anywhere** — Even one hardcoded string outside the String Catalog breaks extraction and automation. Use `String(localized:)` everywhere or use `LocalizedStringResource` for deferred localization.

4. **Context loss in translations** — Providing no comment for translators means they guess context and get it wrong. Add comments explaining where the string appears and what it means.

5. **RTL layouts not tested** — Assuming LTR layout works for RTL languages (Arabic, Hebrew) fails miserably. Test with system language set to Arabic and verify semantic directions are used.
