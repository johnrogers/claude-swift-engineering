# Navigation Basics

NavigationStack patterns with path reducers and programmatic navigation.

## NavigationStack with Path Reducer

### Basic Pattern

```swift
@Reducer
struct NavigationDemo {
    @Reducer
    enum Path {
        case screenA(ScreenA)
        case screenB(ScreenB)
        case screenC(ScreenC)
    }

    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
    }

    enum Action {
        case path(StackActionOf<Path>)
        case popToRoot
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .popToRoot:
                state.path.removeAll()
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
```

### View with store.case Pattern

```swift
struct NavigationDemoView: View {
    @Bindable var store: StoreOf<NavigationDemo>

    var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            RootView()
        } destination: { store in
            switch store.case {
            case let .screenA(store):
                ScreenAView(store: store)

            case let .screenB(store):
                ScreenBView(store: store)

            case let .screenC(store):
                ScreenCView(store: store)
            }
        }
    }
}
```

## Navigation Actions

### Pushing to Stack

```swift
case .view(.didTapNavigateToDetail):
    state.path.append(.detail(Detail.State()))
    return .none

case .view(.didTapNavigateToSettings):
    state.path.append(.settings(Settings.State(id: state.selectedId)))
    return .none
```

### Popping from Stack

```swift
// Pop one screen
case .view(.didTapBack):
    state.path.removeLast()
    return .none

// Pop to root
case .view(.didTapPopToRoot):
    state.path.removeAll()
    return .none

// Pop to specific index
case .view(.didTapPopToFirst):
    state.path.removeAll(after: 0)
    return .none
```

### Programmatic Dismiss

Use `@Dependency(\.dismiss)` for child features to dismiss themselves:

```swift
@Reducer
struct DetailFeature {
    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.didTapClose):
                return .run { _ in
                    await self.dismiss()
                }

            case .view(.didSave):
                return .concatenate(
                    .send(.delegate(.didSave)),
                    .run { _ in await self.dismiss() }
                )
            }
        }
    }
}
```

## Handling Child Actions

### Responding to Delegate Actions

```swift
case .path(.element(id: _, action: .detail(.delegate(.didSave)))):
    // Detail screen saved, pop it
    state.path.removeLast()
    return .send(.refreshData)

case .path(.element(id: _, action: .settings(.delegate(.didLogout)))):
    // Settings logged out, pop to root
    state.path.removeAll()
    return .send(.delegate(.userDidLogout))
```

### Inspecting Navigation Stack

```swift
case .view(.didTapSave):
    // Check if we're in a specific screen
    guard state.path.last(where: { $0.is(\.detail) }) != nil else {
        return .none
    }
    return .send(.path(.element(id: state.path.ids.last!, action: .detail(.save))))
```

## Enum Reducer Conformances

**CRITICAL**: When using `@Reducer enum Path`, add protocol conformances via extension:

```swift
@Reducer
struct NavigationDemo {
    @Reducer
    enum Path {
        case screenA(ScreenA)
        case screenB(ScreenB)
    }
}

// Extension must be at file scope
extension NavigationDemo.Path: Equatable {}
```

## Best Practices

1. **Use `@Reducer enum Path`** - For type-safe navigation destinations
2. **Use `StackState`** - For managing navigation stack state
3. **Use `.forEach(\.path, action: \.path)`** - For path reducer composition
4. **Use `@Dependency(\.dismiss)`** - For child features to dismiss themselves
5. **Handle delegate actions** - Pop stack or navigate based on child completion
6. **Extension conformances** - Add `Equatable` via extension for enum reducers
