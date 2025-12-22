---
name: modern-swiftui
description: Use when working with iOS 17+ SwiftUI code using @Observable, @Bindable, or modern view modifiers. Covers migration from ObservableObject, @StateObject, @EnvironmentObject, and deprecated patterns.
---

# Modern SwiftUI (iOS 17+)

## Quick Reference

| Need | Use (iOS 17+) | NOT |
|------|---------------|-----|
| Observable model | `@Observable` | `ObservableObject` |
| Published property | Just a regular property | `@Published` |
| Own state | `@State` | `@StateObject` |
| Passed model (binding) | `@Bindable` | `@ObservedObject` |
| Environment injection | `environment(_:)` | `environmentObject(_:)` |
| Environment access | `@Environment(Type.self)` | `@EnvironmentObject` |
| Value change | `onChange(of:initial:_:)` | `onChange(of:perform:)` |
| Async on appear | `task(priority:_:)` | `onAppear { Task {} }` |

## Core Workflow

When building iOS 17+ SwiftUI views:
1. Use `@Observable` for model classes — no @Published needed
2. Use `@State` for view-owned models, `@Bindable` for passed models
3. Use `.task { }` for async work on appear — auto-cancels on disappear
4. Use `@Environment(Type.self)` instead of `@EnvironmentObject`
5. Update `onChange(of:)` to include both old and new value parameters

## References

Load these based on what you need:
- **[@Observable](references/observable.md)** — Load when creating new observable model classes
- **[State Management](references/state-management.md)** — Load when deciding between @State, @Bindable, @Environment
- **[Environment](references/environment.md)** — Load when injecting dependencies into view hierarchy
- **[View Modifiers](references/view-modifiers.md)** — Load when using onChange, task, or other iOS 17+ modifiers
- **[Migration Guide](references/migration-guide.md)** — Load when updating existing iOS 16 code to iOS 17+
