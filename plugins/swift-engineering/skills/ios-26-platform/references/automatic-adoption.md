# Automatic vs Explicit Adoption

**iOS 26+**

## What Changes Automatically (Recompile Only)

### Standard Components Get Liquid Glass
Simply recompile with Xcode 26 — no code changes:

```swift
// All these get glass automatically:
NavigationView { ... }
TabView { ... }
.toolbar { ... }
.sheet { ... }
.popover { ... }
List { ... }
```

### Controls Get New Appearance
- Toggles, segmented pickers, sliders
- Knobs transform into glass during interaction
- Buttons morph into menus/popovers

### Search Placement
```swift
NavigationSplitView {
    List { }
        .searchable(text: $searchText)
}
// Automatically:
// - Bottom-aligned on iPhone (ergonomic)
// - Top trailing on iPad
```

### Performance Improvements
- **6x faster loading** for 100k+ item lists (macOS)
- **16x faster updates** for large lists
- Reduced dropped frames during scrolling
- Better nested ScrollView performance with lazy stacks

## What Requires Code Changes

### Toolbar Customization
```swift
.toolbar {
    ToolbarItemGroup(placement: .topBarTrailing) {
        Button("Up") { }
        Button("Down") { }

        Spacer(.fixed) // NEW: Separates button groups

        Button("Settings") { }
    }
}
```

### Prominent Toolbar Buttons
```swift
Button("Add Trip") {
    addTrip()
}
.buttonStyle(.borderedProminent)
.tint(.blue) // Tinting in glass toolbars
```

### Glass Effect for Custom Views
```swift
CustomPhotoGrid()
    .glassBackgroundEffect() // Reflects surrounding content
```

### Search Tab Role
```swift
TabView {
    SearchView()
        .tabItem { Label("Search", systemImage: "magnifyingglass") }
        .tabRole(.search) // Separates from tabs, morphs into search
}
```

### Tab Bar Minimization
```swift
TabView { ... }
    .tabBarMinimizationBehavior(.onScrollDown) // Recedes on scroll
```

## Audit Checklist

### Remove These (Interfere with Glass)
```swift
// Remove custom backgrounds on navigation
NavigationView { }
    .background(Color.blue.opacity(0.5)) // Remove

// Remove custom blur effects
.background(
    VisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
) // Remove — let system handle

// Remove hard-coded dimensions
Slider(value: $volume)
    .frame(width: 250, height: 44) // Remove — new metrics
```

### Update These
```swift
// Section headers: Use title-style capitalization
Section(header: Text("User Settings")) { } // Not "user settings"

// Forms: Use grouped style
Form { ... }
    .formStyle(.grouped) // Platform-optimized metrics
```

## Safe Area Considerations

```swift
// When glass extends edge-to-edge with .ignoresSafeArea()
// Use .safeAreaPadding() for content (not .padding())

ZStack {
    RoundedRectangle(cornerRadius: 12)
        .fill(.thinMaterial)
        .ignoresSafeArea()

    VStack {
        content
    }
    .safeAreaPadding(.horizontal, 20) // Respects notch/home indicator
}
```

## Testing Required

1. **Light/dark modes** — Glass adapts independently
2. **Reduce Transparency** — Glass becomes frostier
3. **Increase Contrast** — Elements become black/white
4. **Reduce Motion** — Elastic properties disabled
5. **Dynamic Type** — Larger text sizes
6. **Content scrolling** — Verify scroll edge effects

## Platform-Specific Changes

### iPad
- Tab bar can adapt to sidebar
- Resizable windows (UIRequiresFullscreen deprecated)
- Menu bar via swipe down

### macOS
- Synchronized window resize animations
- Window controls adapt automatically
- Glassy sidebars reflect content

### watchOS
- Minimal changes, automatic adoption
- Use standard toolbar APIs and button styles

### tvOS
- Focus-based glass appearance
- Apple TV 4K 2nd gen+ required for full effects
