---
name: swiftui-common-patterns
description: Use when implementing SwiftUI patterns for iOS 17+: MVVM with @Observable, NavigationStack, lazy loading, performance optimization, UIKit interop, VoiceOver/accessibility, async operations, or view composition.
---

# SwiftUI Common Patterns (iOS 17+)

## Quick Reference

| Pattern | Use When |
|---------|----------|
| MVVM + @Observable | Reactive view models |
| NavigationStack | Programmatic navigation |
| LazyVStack/Equatable | Long lists, performance |
| UIViewRepresentable | Wrapping UIKit views |
| VoiceOver/Dynamic Type | Accessibility |
| .task/.refreshable | Async operations |
| @ViewBuilder/Modifiers | View composition |

## Core Workflow

When building SwiftUI views:
1. Use `@Observable` view models with `@State` ownership
2. Use `NavigationStack` with `NavigationPath` for programmatic navigation
3. Use `LazyVStack` inside `ScrollView` for lists with 50+ items
4. Apply `.accessibilityLabel()` and `.accessibilityHint()` to interactive elements
5. Use `.task { }` for data loading — it auto-cancels on disappear

## References

Load these based on what you need:
- **[MVVM with @Observable](references/mvvm-observable.md)** — Load when setting up view model architecture
- **[NavigationStack Patterns](references/navigation.md)** — Load when implementing programmatic or deep-link navigation
- **[Performance Optimization](references/performance.md)** — Load when list has 100+ items or view re-renders excessively
- **[UIKit Interoperability](references/uikit-interop.md)** — Load when wrapping UIKit components (WKWebView, PHPicker, etc.)
- **[Accessibility](references/accessibility.md)** — Load when adding VoiceOver, Dynamic Type, or accessibility actions
- **[Async Operations](references/async-patterns.md)** — Load when implementing loading states, refresh, or background tasks
- **[View Composition](references/composition.md)** — Load when building reusable view modifiers or complex conditional UI
