---
name: composable-architecture
description: Use when building features with TCA (The Composable Architecture), structuring reducers, managing state, handling effects, navigation, or testing TCA features. Covers @Reducer, Store, Effect, TestStore, reducer composition, and TCA patterns.
---

# The Composable Architecture (TCA)

TCA provides architecture for building complex, testable features through composable reducers, centralized state management, and side effect handling. The core principle: predictable state evolution with clear dependencies and testable effects.

## Reference Loading Guide

**ALWAYS load reference files if there is even a small chance the content may be required.** It's better to have the context than to miss a pattern or make a mistake.

| Reference | Load When |
|-----------|-----------|
| **[Reducer Structure](references/reducer-structure.md)** | Creating new reducers, setting up `@Reducer`, `State`, `Action`, or `@ViewAction` |
| **[Views - Binding](references/views-binding.md)** | Using `@Bindable`, two-way bindings, `store.send()`, or `.onAppear`/`.task` |
| **[Views - Composition](references/views-composition.md)** | Using `ForEach` with stores, scoping to child features, or optional children |
| **[Navigation - Basics](references/navigation-basics.md)** | Setting up `NavigationStack`, path reducers, pushing/popping, or programmatic dismiss |
| **[Navigation - Advanced](references/navigation-advanced.md)** | Deep linking, recursive navigation, or combining NavigationStack with sheets |
| **[Shared State](references/shared-state.md)** | Using `@Shared`, `.appStorage`, `.withLock`, or sharing state between features |
| **[Dependencies](references/dependencies.md)** | Creating `@DependencyClient`, using `@Dependency`, or setting up test dependencies |
| **[Effects](references/effects.md)** | Using `.run`, `.send`, `.merge`, timers, effect cancellation, or async work |
| **[Presentation](references/presentation.md)** | Using `@Presents`, `AlertState`, sheets, popovers, or the Destination pattern |
| **[Testing - Fundamentals](references/testing-fundamentals.md)** | Setting up test suites, `makeStore` helpers, or understanding Equatable requirements |
| **[Testing - Patterns](references/testing-patterns.md)** | Testing actions, state changes, dependencies, errors, or presentations |
| **[Testing - Advanced](references/testing-advanced.md)** | Using `TestClock`, keypath matching, `exhaustivity = .off`, or time-based tests |
| **[Testing - Utilities](references/testing-utilities.md)** | Test data factories, `LockIsolated`, `ConfirmationDialogState` testing, or `@Shared` testing |
| **[Performance](references/performance.md)** | Optimizing state updates, high-frequency actions, memory, or store scoping |

## Common Mistakes

1. **Over-modularizing features** — Breaking features into too many small reducers makes state management harder and adds composition overhead. Keep related state and actions together unless there's genuine reuse.

2. **Mismanaging effect lifetimes** — Forgetting to cancel effects when state changes leads to stale data, duplicate requests, or race conditions. Use `.concatenate` for sequential effects and `.cancel` when appropriate.

3. **Navigation state in wrong places** — Putting navigation state in child reducers instead of parent causes unnecessary view reloads and state inconsistencies. Navigation state belongs in the feature that owns the navigation structure.

4. **Testing without TestStore exhaustivity** — Skipping TestStore assertions for "simple" effects or "obvious" state changes means you miss bugs. Use exhaustivity checking religiously; it catches regressions early.

5. **Mixing async/await with Effects incorrectly** — Converting async/await to `.run` effects without proper cancellation or error handling loses isolation guarantees. Wrap async operations carefully in `.run` with `yield` statements.
