# Right-to-Left (RTL) Support

Supporting RTL languages (Arabic, Hebrew, Persian, Urdu) is essential for global apps. SwiftUI handles most mirroring automatically, but requires semantic layout choices.

## Automatic Layout Mirroring

SwiftUI automatically mirrors layouts for RTL languages:

```swift
// Automatically mirrors for Arabic/Hebrew
HStack {
    Image(systemName: "chevron.right")
    Text("Next")
}

// LTR (English): [>] Next
// RTL (Arabic):  Next [<]
```

## Leading/Trailing vs Left/Right

**Always use semantic directions** that adapt to layout direction:

```swift
// CORRECT - mirrors automatically
.padding(.leading, 16)
.padding(.trailing, 8)
.frame(maxWidth: .infinity, alignment: .leading)

// WRONG - doesn't mirror, breaks RTL
.padding(.left, 16)
.padding(.right, 8)
.frame(maxWidth: .infinity, alignment: .left)
```

### Alignment

```swift
// CORRECT
VStack(alignment: .leading) {
    Text("Title")
    Text("Subtitle")
}

// WRONG
VStack(alignment: .left) {  // Doesn't exist, but conceptually wrong
    Text("Title")
}
```

### Edge Insets

```swift
// CORRECT - semantic edges
.padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

// For non-mirroring needs (rare)
.padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    .environment(\.layoutDirection, .leftToRight)
```

## Images and Icons

### SF Symbols

SF Symbols handle directionality automatically:

```swift
// Directional - mirrors for RTL
Image(systemName: "chevron.forward")  // Points right in LTR, left in RTL
Image(systemName: "chevron.backward") // Points left in LTR, right in RTL

// Non-directional - never mirrors
Image(systemName: "star.fill")
Image(systemName: "heart.fill")
```

### Custom Images

Mark images that should flip:

```swift
// Image should mirror
Image("backArrow")
    .flipsForRightToLeftLayoutDirection(true)

// Image should NOT mirror (logos, photos)
Image("companyLogo")
    .flipsForRightToLeftLayoutDirection(false)  // Default
```

### Asset Catalog Settings

In Asset Catalog:
1. Select image asset
2. Attributes Inspector > Direction
3. Choose: "Fixed" (never flip) or "Mirrors" (flip for RTL)

## Text Alignment

```swift
// Adapts to layout direction
Text("Hello")
    .multilineTextAlignment(.leading)  // Left in LTR, right in RTL

// Force specific alignment (rare)
Text("Code sample")
    .multilineTextAlignment(.trailing)
```

### Mixed Content

```swift
// Numbers and punctuation in RTL text
Text("Price: $99.99")  // System handles bidirectional text

// Force LTR for specific content
Text("\u{200E}$99.99")  // Left-to-right mark
```

## Detecting Layout Direction

### Environment Value

```swift
struct DirectionalView: View {
    @Environment(\.layoutDirection) var layoutDirection

    var body: some View {
        HStack {
            if layoutDirection == .rightToLeft {
                trailingContent
                Spacer()
                leadingContent
            } else {
                leadingContent
                Spacer()
                trailingContent
            }
        }
    }
}
```

### Conditional Modifiers

```swift
extension View {
    @ViewBuilder
    func rtlAware() -> some View {
        self.environment(\.layoutDirection,
            Locale.current.language.characterDirection == .rightToLeft
                ? .rightToLeft
                : .leftToRight)
    }
}
```

## Scroll Views

```swift
// Automatically adapts scroll direction
ScrollView(.horizontal) {
    HStack {
        ForEach(items) { item in
            ItemView(item: item)
        }
    }
}
// LTR: scrolls left-to-right
// RTL: scrolls right-to-left
```

## Lists and Navigation

```swift
// List disclosure indicators mirror automatically
List(items) { item in
    NavigationLink(destination: DetailView(item: item)) {
        Text(item.name)
    }
}
// LTR: Text [>]
// RTL: [<] Text
```

## Testing RTL Layouts

### Xcode Scheme

1. Edit Scheme > Run > Options
2. Application Language > Arabic or Hebrew
3. OR: App Language > Right-to-Left Pseudolanguage

### SwiftUI Preview

```swift
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDisplayName("LTR")

            ContentView()
                .environment(\.layoutDirection, .rightToLeft)
                .environment(\.locale, Locale(identifier: "ar"))
                .previewDisplayName("RTL")
        }
    }
}
```

### Simulator

Settings > General > Language & Region > Preferred Language Order > Add Arabic/Hebrew

## UIKit Considerations

### UIView

```swift
// Check effective layout direction
if view.effectiveUserInterfaceLayoutDirection == .rightToLeft {
    // RTL-specific adjustments
}

// Semantic content attribute
view.semanticContentAttribute = .forceLeftToRight  // Override mirroring
view.semanticContentAttribute = .unspecified       // Follow system
```

### Auto Layout

```swift
// CORRECT - semantic constraints
leadingAnchor.constraint(equalTo: other.leadingAnchor)
trailingAnchor.constraint(equalTo: other.trailingAnchor)

// WRONG - absolute constraints
leftAnchor.constraint(equalTo: other.leftAnchor)
rightAnchor.constraint(equalTo: other.rightAnchor)
```

## Common Patterns

### Progress Indicators

```swift
// Progress should typically NOT mirror
ProgressView(value: 0.7)
    .environment(\.layoutDirection, .leftToRight)
```

### Media Controls

```swift
// Playback controls typically don't mirror
HStack {
    Button(action: rewind) {
        Image(systemName: "backward.fill")
    }
    Button(action: playPause) {
        Image(systemName: "play.fill")
    }
    Button(action: forward) {
        Image(systemName: "forward.fill")
    }
}
.environment(\.layoutDirection, .leftToRight)
```

### Form Layouts

```swift
// Forms mirror correctly with semantic alignment
Form {
    HStack {
        Text("Email")
        Spacer()
        TextField("email@example.com", text: $email)
            .multilineTextAlignment(.trailing)
    }
}
```

## Best Practices

1. **Use leading/trailing** - Never left/right for layout
2. **Test with RTL pseudolanguage** - Catches issues without translation
3. **Use directional SF Symbols** - chevron.forward, not chevron.right
4. **Don't mirror logos and photos** - Only directional UI elements
5. **Test bidirectional text** - Mix of Arabic/Hebrew with numbers
6. **Consider reading order** - Important content should be at "start"

## Troubleshooting

**Layout not mirroring**:
- Check for hardcoded .left/.right usage
- Verify parent views aren't forcing LTR
- Check asset catalog Direction settings

**Text alignment wrong**:
- Use .leading/.trailing, not .left/.right
- Check multilineTextAlignment setting

**Images not flipping**:
- Add .flipsForRightToLeftLayoutDirection(true)
- Or configure in Asset Catalog

**Scroll direction wrong**:
- ScrollView mirrors automatically
- Check if parent overrides layoutDirection
