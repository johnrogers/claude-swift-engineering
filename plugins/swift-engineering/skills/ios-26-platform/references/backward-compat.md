# Backward Compatibility

**iOS 17/18 + iOS 26**

## UIDesignRequiresCompatibility Key

### Opt Out of Liquid Glass (Temporarily)
```xml
<!-- Info.plist -->
<key>UIDesignRequiresCompatibility</key>
<true/>
```

**Effect**:
- App built with iOS 26 SDK
- Appearance matches iOS 18 and earlier
- Liquid Glass effects disabled
- Previous blur/material styles used

### Migration Strategy
1. Ship with `UIDesignRequiresCompatibility` enabled
2. Audit interface changes in separate build
3. Update interface incrementally
4. Remove key when ready for Liquid Glass

## @available Patterns

### Basic Check
```swift
if #available(iOS 26, *) {
    content
        .glassEffect()
} else {
    content
        .background(.ultraThinMaterial)
}
```

### View Modifier Pattern
```swift
extension View {
    @ViewBuilder
    func adaptiveGlass() -> some View {
        if #available(iOS 26, *) {
            self.glassEffect()
        } else {
            self.background(.regularMaterial)
        }
    }
}

// Usage
Button("Action") { }
    .adaptiveGlass()
```

### Toolbar Spacer Fallback
```swift
extension View {
    @ViewBuilder
    func adaptiveToolbar() -> some View {
        if #available(iOS 26, *) {
            self.toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Up") { }
                    Button("Down") { }
                    Spacer(.fixed) // iOS 26 feature
                    Button("Settings") { }
                }
            }
        } else {
            self.toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Up") { }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Down") { }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Settings") { }
                }
            }
        }
    }
}
```

## WebView Fallback

```swift
struct ArticleView: View {
    let url: URL

    var body: some View {
        if #available(iOS 26, *) {
            WebView(url: url)
        } else {
            WebViewRepresentable(url: url) // UIViewRepresentable wrapper
        }
    }
}

// iOS 17/18 fallback
struct WebViewRepresentable: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }
}
```

## @Animatable Fallback

```swift
#if swift(>=6.0)
@Animatable
struct ModernShape: Shape {
    var progress: Double

    @AnimatableIgnored
    var style: ShapeStyle
}
#else
struct LegacyShape: Shape {
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
}
#endif
```

## Search Tab Role Fallback

```swift
TabView {
    if #available(iOS 26, *) {
        SearchView()
            .tabItem { Label("Search", systemImage: "magnifyingglass") }
            .tabRole(.search)
    } else {
        SearchView()
            .tabItem { Label("Search", systemImage: "magnifyingglass") }
    }
}
```

## AttributedString TextEditor

```swift
struct CommentEditor: View {
    @State private var richText = AttributedString("Comment")
    @State private var plainText = "Comment"

    var body: some View {
        if #available(iOS 26, *) {
            TextEditor(text: $richText) // Rich text support
        } else {
            TextEditor(text: $plainText) // Plain text only
        }
    }
}
```

## Migration from Previous Materials

### From UIBlurEffect
```swift
// Before (UIKit)
let blurEffect = UIBlurEffect(style: .systemMaterial)
let blurView = UIVisualEffectView(effect: blurEffect)

// After (SwiftUI with fallback)
extension View {
    @ViewBuilder
    func adaptiveMaterial() -> some View {
        if #available(iOS 26, *) {
            self.glassEffect()
        } else {
            self.background(.regularMaterial)
        }
    }
}
```

### From Custom Materials
Keep custom materials when:
- Backward compatibility with iOS < 26 required
- Specific artistic effect not achievable with glass
- Non-standard UI paradigm

## Testing Checklist

### iOS 26 Tests
- [ ] Liquid Glass appearance correct
- [ ] Scroll edge effects working
- [ ] Toolbar grouping renders properly
- [ ] Search placement is platform-appropriate
- [ ] Accessibility settings respected

### iOS 17/18 Tests
- [ ] Fallback materials render correctly
- [ ] No runtime crashes from @available checks
- [ ] Functionality preserved without glass
- [ ] Layout doesn't break

## Deprecated APIs

### iPadOS 26
```xml
<!-- Remove entirely — deprecated in iPadOS 26 -->
<key>UIRequiresFullscreen</key>
```
Apps must support resizable windows on iPad.

### SwiftUI Updates
```swift
// Old (deprecated)
.onChange(of: value, perform: { newValue in })

// New (iOS 17+)
.onChange(of: value) { oldValue, newValue in }
```

## Performance Considerations

When supporting multiple iOS versions:
- Use `@available` checks at view level, not inside body
- Prefer conditional view modifiers over entire view branches
- Test performance on oldest supported version
- Profile with Instruments on both old and new iOS
