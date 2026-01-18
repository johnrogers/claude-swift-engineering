# Liquid Glass Design System

**iOS 26+, iPadOS 26+, macOS Tahoe+, visionOS 3+**

## What is Liquid Glass?

Apple's next-generation material that dynamically bends light (lensing) rather than scattering it. Unlike blur effects, Liquid Glass:
- Moves organically like lightweight liquid
- Adapts automatically to size, environment, and light/dark modes
- Provides separation through instinctive visual cues

## Visual Properties

### Lensing (Primary Characteristic)
```swift
// Glass warps and bends light in real-time
Text("Hello")
    .glassEffect() // Lensing effect, not blur
```
- Concentrates and shapes light dynamically
- Elements feel ultra-lightweight yet distinguishable
- Materializes in/out by modulating light bending (not fading)

### Motion & Fluidity
- Instant flex and energize on interaction
- Gel-like flexibility for transient UI
- Dynamic morphing between app states
- Lightweight transitions (menus pop open in-line)

### Adaptive Behavior
- Shadows increase when text scrolls underneath
- Independently switches light/dark per element
- Larger elements (menus, sidebars) simulate thicker material
- Ambient environment subtly spills onto surface

## Variants: Regular vs Clear

**CRITICAL**: Never mix Regular and Clear in the same interface.

### Regular Variant (Default - Use 95% of Time)
```swift
// Regular is the default — most versatile
NavigationView {
    Content()
}
.glassEffect() // Full adaptive effects, auto-legibility

// With custom shape
Button("Tap Me") { }
    .glassEffect(in: RoundedRectangle(cornerRadius: 12))
```
- Works in any size, over any content
- Provides legibility regardless of context
- Anything can be placed on top

### Clear Variant (Special Cases Only)
```swift
// Use ONLY when ALL THREE conditions are met:
// 1. Over media-rich content
// 2. Dimming layer acceptable
// 3. Content above is bold and bright

ZStack {
    VideoPlayer(player: player)
        .overlay(.black.opacity(0.3)) // Required dimming layer

    PlayButton()
        .glassEffect(.clear) // Clear variant
}
```

**WARNING**: Clear without meeting all three conditions = poor legibility.

## Layer Architecture

### Navigation Layer (Use Glass Here)
```swift
// Correct — glass on navigation elements
.toolbar {
    ToolbarItem {
        Button("Add") { }
            .glassEffect()
    }
}
```

### Content Layer (No Glass)
```swift
// Wrong — don't apply glass to content
List(items) { item in
    ItemRow(item)
        .glassEffect() // Never do this
}
```

## DO: Best Practices

```swift
// Reserve glass for navigation layer
TabView { ... } // Gets glass automatically

// Use fills for elements ON TOP of glass
ZStack {
    NavigationBar()
        .glassEffect()

    FloatingButton()
        .foregroundStyle(.primary) // Fills, not glass
}

// Use adaptive tinting for primary actions
Button("View Bag") { }
    .tint(.red)
    .glassEffect()
```

## DON'T: Common Mistakes

```swift
// Don't stack glass on glass
ZStack {
    Toolbar().glassEffect()
    Button().glassEffect() // Wrong
}

// Don't use solid fills on glass
Button("Action") { }
    .background(.red) // Breaks glass character
    .glassEffect()

// Don't tint everything
VStack {
    Button("A").tint(.blue).glassEffect()
    Button("B").tint(.green).glassEffect() // No hierarchy
}
```

## Scroll Edge Effects

```swift
ScrollView {
    Content()
}
.scrollEdgeEffectStyle(.hard, for: .top) // Uniform effect

// .soft for gradual fade
// .hard for pinned accessories
// .automatic for system default
```

## Accessibility

All features automatic when using glass:
- **Reduced Transparency**: Makes glass frostier
- **Increased Contrast**: Black/white with contrasting border
- **Reduced Motion**: Decreases effect intensity

## GlassEffectContainer

Group multiple glass effects for performance and morphing animations:

```swift
GlassEffectContainer(spacing: 8) {
    HStack(spacing: 8) {
        Button { } label: { Image(systemName: "plus") }
            .glassEffect()
            .glassEffectID("add", in: namespace)

        Button { } label: { Image(systemName: "share") }
            .glassEffect()
            .glassEffectID("share", in: namespace)
    }
}
```

- Groups glass effects for better rendering performance
- Enables morphing transitions between elements
- Use `spacing` parameter to control when effects blend together

## Morphing with glassEffectID

Use `@Namespace` and `.glassEffectID()` for smooth morphing transitions:

```swift
@Namespace var namespace

// Elements with same ID morph into each other during transitions
if isExpanded {
    ExpandedView()
        .glassEffect()
        .glassEffectID("panel", in: namespace)
} else {
    CollapsedView()
        .glassEffect()
        .glassEffectID("panel", in: namespace)
}
```

## Interactive Glass

Add touch response with `.interactive()` chained on the glass variant:

```swift
// Correct - chain .interactive() on the variant
Button("Tap") { }
    .glassEffect(.regular.interactive())

// With tint
Button("Tap") { }
    .glassEffect(.regular.interactive().tint(.blue))

// With custom shape
Button("Tap") { }
    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 12))
```

**Caution**: Avoid `.interactive()` on draggable rows - it can interfere with drag gestures.

## Known Limitations

**Drag previews**: Glass effects don't render correctly in drag previews. When using `.contentShape(.dragPreview, ...)`, the glass material won't appear during the lift animation. Use simple shapes for drag previews:

```swift
// Glass won't show in drag preview - this is expected
MyGlassCard()
    .glassEffect()
    .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 12))
```

## API Reference

```swift
// Basic glass effect
func glassEffect<S: Shape>(
    _ glass: Glass = .regular,
    in shape: S = Capsule()
) -> some View

// Glass variant modifiers (chainable)
Glass.regular.interactive()           // Adds touch response
Glass.regular.tint(.color)            // Adds color tint
Glass.regular.interactive().tint(.color) // Both

// Morphing support
func glassEffectID<ID: Hashable>(_ id: ID, in namespace: Namespace.ID) -> some View

// Container for multiple effects
GlassEffectContainer(spacing: CGFloat) { content }

// For custom views (reflects surrounding content)
func glassBackgroundEffect() -> some View

// Scroll edge styling
func scrollEdgeEffectStyle(_ style: ScrollEdgeStyle, for edges: Edge.Set) -> some View
```
