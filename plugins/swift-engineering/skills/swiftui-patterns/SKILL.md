---
name: swiftui-patterns
description: Use when implementing iOS 17+ SwiftUI patterns: @Observable/@Bindable, MVVM architecture, NavigationStack, lazy loading, UIKit interop, accessibility (VoiceOver/Dynamic Type), async operations (.task/.refreshable), or migrating from ObservableObject/@StateObject.
---

# SwiftUI Patterns (iOS 17+)

## Quick Reference

| Need | Use (iOS 17+) | NOT |
|------|---------------|-----|
| Observable model | `@Observable` | `ObservableObject` |
| Published property | Regular property | `@Published` |
| Own state | `@State` | `@StateObject` |
| Passed model (binding) | `@Bindable` | `@ObservedObject` |
| Environment injection | `environment(_:)` | `environmentObject(_:)` |
| Environment access | `@Environment(Type.self)` | `@EnvironmentObject` |
| Async on appear | `.task { }` | `.onAppear { Task {} }` |
| Value change | `onChange(of:initial:_:)` | `onChange(of:perform:)` |

## Core Workflow

1. Use `@Observable` for model classes (no @Published needed)
2. Use `@State` for view-owned models, `@Bindable` for passed models
3. Use `.task { }` for async work (auto-cancels on disappear)
4. Use `NavigationStack` with `NavigationPath` for programmatic navigation
5. Apply `.accessibilityLabel()` and `.accessibilityHint()` to interactive elements

## References

| Reference | Load When |
|-----------|-----------|
| [observable.md](references/observable.md) | Creating new @Observable model classes |
| [state-management.md](references/state-management.md) | Deciding between @State, @Bindable, @Environment |
| [environment.md](references/environment.md) | Injecting dependencies into view hierarchy |
| [view-modifiers.md](references/view-modifiers.md) | Using onChange, task, or iOS 17+ modifiers |
| [migration-guide.md](references/migration-guide.md) | Updating iOS 16 code to iOS 17+ |
| [mvvm-observable.md](references/mvvm-observable.md) | Setting up view model architecture |
| [navigation.md](references/navigation.md) | Programmatic or deep-link navigation |
| [performance.md](references/performance.md) | Lists with 100+ items or excessive re-renders |
| [uikit-interop.md](references/uikit-interop.md) | Wrapping UIKit components (WKWebView, PHPicker) |
| [accessibility.md](references/accessibility.md) | VoiceOver, Dynamic Type, accessibility actions |
| [async-patterns.md](references/async-patterns.md) | Loading states, refresh, background tasks |
| [composition.md](references/composition.md) | Reusable view modifiers or complex conditional UI |
