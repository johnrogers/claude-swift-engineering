---
name: composable-architecture
description: Comprehensive guide for The Composable Architecture (TCA) patterns in Swift. Use when building features with TCA, structuring reducers, managing state, handling effects, navigation, or testing. Triggers: TCA, composable architecture, reducer, feature, state management, SwiftUI architecture.
---

# The Composable Architecture (TCA)

- **[Reducer Structure](references/reducer-structure.md)** - Templates, @Reducer, State, Actions, @ViewAction, conformances
- **[Views](references/views.md)** - StoreOf, @Bindable, ForEach, store.scope, view actions
- **[Navigation](references/navigation.md)** - NavigationStack, StackState, path reducers, dismiss
- **[Shared State](references/shared-state.md)** - @Shared, .appStorage, .withLock, FileStorageKey, InMemoryKey
- **[Dependencies](references/dependencies.md)** - @DependencyClient, @Dependency, DependencyKey, streaming
- **[Effects](references/effects.md)** - .run, .send, .merge, catch:, timers, cancellation
- **[Presentation](references/presentation.md)** - @Presents, Scope, AlertState, multiple destinations
- **[Testing](references/testing.md)** - TestStore, TestClock, exhaustivity, dependency mocking
- **[Performance](references/performance.md)** - Optimization, high-frequency updates, memory
