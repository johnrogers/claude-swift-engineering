---
name: composable-architecture
description: Use when building features with TCA (The Composable Architecture), structuring reducers, managing state, handling effects, navigation, or testing TCA features. Covers @Reducer, Store, Effect, TestStore, reducer composition, and TCA patterns.
---

# The Composable Architecture (TCA)

TCA provides architecture for building complex, testable features through composable reducers, centralized state management, and side effect handling. The core principle: predictable state evolution with clear dependencies and testable effects.

## Overview

- **[Reducer Structure](references/reducer-structure.md)** - Templates, @Reducer, State, Actions, @ViewAction, conformances
- **[Views](references/views.md)** - StoreOf, @Bindable, ForEach, store.scope, view actions
- **[Navigation](references/navigation.md)** - NavigationStack, StackState, path reducers, dismiss
- **[Shared State](references/shared-state.md)** - @Shared, .appStorage, .withLock, FileStorageKey, InMemoryKey
- **[Dependencies](references/dependencies.md)** - @DependencyClient, @Dependency, DependencyKey, streaming
- **[Effects](references/effects.md)** - .run, .send, .merge, catch:, timers, cancellation
- **[Presentation](references/presentation.md)** - @Presents, Scope, AlertState, multiple destinations
- **[Testing](references/testing.md)** - TestStore, TestClock, exhaustivity, dependency mocking
- **[Performance](references/performance.md)** - Optimization, high-frequency updates, memory

## Common Mistakes

1. **Over-modularizing features** — Breaking features into too many small reducers makes state management harder and adds composition overhead. Keep related state and actions together unless there's genuine reuse.

2. **Mismanaging effect lifetimes** — Forgetting to cancel effects when state changes leads to stale data, duplicate requests, or race conditions. Use `.concatenate` for sequential effects and `.cancel` when appropriate.

3. **Navigation state in wrong places** — Putting navigation state in child reducers instead of parent causes unnecessary view reloads and state inconsistencies. Navigation state belongs in the feature that owns the navigation structure.

4. **Testing without TestStore exhaustivity** — Skipping TestStore assertions for "simple" effects or "obvious" state changes means you miss bugs. Use exhaustivity checking religiously; it catches regressions early.

5. **Mixing async/await with Effects incorrectly** — Converting async/await to `.run` effects without proper cancellation or error handling loses isolation guarantees. Wrap async operations carefully in `.run` with `yield` statements.
