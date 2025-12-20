# Visual Design

Apple Human Interface Guidelines for color, materials, and contrast.

## Critical Rules

- Prefer **semantic system styles** (`.tint`, `.secondary`, `.tertiary`, `Material`) over custom colors
- Support **light and dark mode**; don't rely on "always light" colors
- Maintain **sufficient contrast** for text and controls, including in accessibility settings
- Use color to **reinforce meaning**, not as the only indicator (pair with text/icons)
- Avoid decorative gradients/materials that reduce readability or increase visual noise

## Examples

### Semantic System Styles

```swift
// ✅ Semantic styles that adapt automatically
HStack {
    Image(systemName: "link")
        .foregroundStyle(.tint)
    Text("Open link")
        .foregroundStyle(.primary)
    Spacer()
    Text("Optional")
        .foregroundStyle(.secondary)
}
.padding()
.background(.thinMaterial)
.clipShape(.rect(cornerRadius: 12))

// ❌ Hard-coded colors that can break contrast in dark mode
HStack {
    Text("Open link")
        .foregroundStyle(Color.white)
}
.padding()
.background(Color.yellow)
.clipShape(.rect(cornerRadius: 12))
```

### Light and Dark Mode Support

```swift
// ✅ Adapts to light/dark mode automatically
VStack {
    Text("Title")
        .foregroundStyle(.primary)
    Text("Subtitle")
        .foregroundStyle(.secondary)
}
.background(.background)

// ❌ Hard-coded colors don't adapt
VStack {
    Text("Title")
        .foregroundStyle(Color.black)
    Text("Subtitle")
        .foregroundStyle(Color.gray)
}
.background(Color.white)
```

### Color + Meaning

```swift
// ✅ Color reinforces meaning with text/icon
Label("Error occurred", systemImage: "exclamationmark.triangle")
    .foregroundStyle(.red)

// ❌ Color alone conveys meaning
Circle()
    .fill(Color.red)
    .frame(width: 8, height: 8)
```

## Summary

**Key Principles**:
1. Use semantic color styles (`.primary`, `.secondary`, `.tint`)
2. Support both light and dark appearance modes
3. Ensure sufficient contrast for readability
4. Pair color with text or icons for meaning
5. Use materials (`.thinMaterial`, `.regularMaterial`) for depth
