---
name: swiftui-patterns
description: >-
  Use when implementing iOS 17+ SwiftUI patterns: @Observable/@Bindable, MVVM architecture, NavigationStack, lazy loading, UIKit interop, accessibility (VoiceOver/Dynamic Type), async operations (.task/.refreshable), or migrating from ObservableObject/@StateObject.
---

# SwiftUI Patterns (iOS 17+)

SwiftUI 17+ removes ObservableObject boilerplate with @Observable, simplifies environment injection with @Environment, and introduces task-based async patterns. The core principle: use Apple's modern APIs instead of reactive libraries.

## Overview

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

## Reference Loading Guide

**ALWAYS load reference files if there is even a small chance the content may be required.** It's better to have the context than to miss a pattern or make a mistake.

| Reference | Load When |
|-----------|-----------|
| **[Observable](references/observable.md)** | Creating new `@Observable` model classes |
| **[State Management](references/state-management.md)** | Deciding between `@State`, `@Bindable`, `@Environment` |
| **[Environment](references/environment.md)** | Injecting dependencies into view hierarchy |
| **[View Modifiers](references/view-modifiers.md)** | Using `onChange`, `task`, or iOS 17+ modifiers |
| **[Migration Guide](references/migration-guide.md)** | Updating iOS 16 code to iOS 17+ |
| **[MVVM Observable](references/mvvm-observable.md)** | Setting up view model architecture |
| **[Navigation](references/navigation.md)** | Programmatic or deep-link navigation |
| **[Performance](references/performance.md)** | Lists with 100+ items or excessive re-renders |
| **[UIKit Interop](references/uikit-interop.md)** | Wrapping UIKit components (WKWebView, PHPicker) |
| **[Accessibility](references/accessibility.md)** | VoiceOver, Dynamic Type, accessibility actions |
| **[Async Patterns](references/async-patterns.md)** | Loading states, refresh, background tasks |
| **[Composition](references/composition.md)** | Reusable view modifiers or complex conditional UI |

## Common Mistakes

1. **Over-using `@Bindable` for passed models** — Creating `@Bindable` for every property causes unnecessary view reloads. Use `@Bindable` only for mutable model properties that need two-way binding. Read-only computed properties should use regular properties.

2. **State placement errors** — Putting model state in the view instead of a dedicated `@Observable` model causes view logic to become tangled. Always separate model and view concerns.

3. **NavigationPath state corruption** — Mutating `NavigationPath` incorrectly can leave it in inconsistent state. Use `navigationDestination(for:destination:)` with proper state management to avoid path corruption.

4. **Missing `.task` cancellation** — `.task` handles cancellation on disappear automatically, but nested Tasks don't. Complex async flows need explicit cancellation tracking to avoid zombie tasks.

5. **Ignoring environment invalidation** — Changing environment values at parent doesn't invalidate child views automatically. Use `@Environment` consistently and understand when re-renders happen based on observation.

6. **UIKit interop memory leaks** — `UIViewRepresentable` and `UIViewControllerRepresentable` can leak if delegate cycles aren't broken. Weak references and explicit cleanup are required.
