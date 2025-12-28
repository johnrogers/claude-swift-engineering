# Adaptive Layout

## Core Principle

Respond to your container, not assumptions about the device. Your layout should work if Apple ships a new device or multitasking mode tomorrow.

## Decision Tree

```
"I need my layout to adapt..."

TO AVAILABLE SPACE:
- Pick best-fitting variant? -> ViewThatFits
- Animated H/V switch? -> AnyLayout + condition
- Read size for calculations? -> onGeometryChange (iOS 16+)

TO PLATFORM TRAITS:
- Compact vs Regular width? -> horizontalSizeClass
- Accessibility text size? -> dynamicTypeSize.isAccessibilitySize
```

## Pattern 1: ViewThatFits

SwiftUI picks the first variant that fits.

```swift
ViewThatFits {
    HStack { Image(systemName: "star"); Text("Favorite"); Button("Add") { } }
    VStack { Image(systemName: "star"); Text("Favorite"); Button("Add") { } }
}
```

## Pattern 2: AnyLayout

Animated transitions between layouts.

```swift
@Environment(\.horizontalSizeClass) var sizeClass

var layout: AnyLayout {
    sizeClass == .compact
        ? AnyLayout(VStackLayout(spacing: 12))
        : AnyLayout(HStackLayout(spacing: 20))
}

var body: some View {
    layout { content }
        .animation(.default, value: sizeClass)
}
```

## Pattern 3: onGeometryChange

Read dimensions without GeometryReader side effects.

```swift
@State private var columnCount = 2

LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columnCount)) {
    ForEach(items) { ItemView(item: $0) }
}
.onGeometryChange(for: Int.self) { proxy in
    max(1, Int(proxy.size.width / 150))
} action: { columnCount = $0 }
```

## Size Class on iPad

| Configuration | Horizontal |
|--------------|------------|
| Full screen | `.regular` |
| 50% Split View | `.regular` |
| 33% Split View | `.compact` |
| Slide Over | `.compact` |

**Key insight**: Size class only goes `.compact` on iPad at ~33% width.

## Anti-Patterns

**Device orientation observer:**
```swift
// WRONG - reports device, not window
UIDevice.current.orientation

// CORRECT - read actual dimensions
.onGeometryChange(for: Bool.self) { $0.size.width > $0.size.height }
```

**Screen bounds:**
```swift
// WRONG - returns full screen
UIScreen.main.bounds.width

// CORRECT - read container size
.onGeometryChange(for: CGFloat.self) { $0.size.width }
```

**Device model checks:**
```swift
// WRONG - fails in multitasking
if UIDevice.current.userInterfaceIdiom == .pad { }

// CORRECT - respond to space
@Environment(\.horizontalSizeClass) var sizeClass
```

**Unconstrained GeometryReader:**
```swift
// WRONG - expands greedily
GeometryReader { geo in Text("\(geo.size)") }

// CORRECT - constrain it
GeometryReader { geo in Text("\(geo.size)") }
    .frame(height: 44)
```

## iOS 26 Changes

- `UIRequiresFullScreen` deprecated
- Free-form window resizing
- `NavigationSplitView` auto-adapts columns
- Remove full-screen-only from Info.plist
