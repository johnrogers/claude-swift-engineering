# Navigation Patterns

Patterns for navigation in TCA using `NavigationStack`, `StackState`, and path reducers.

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

## Handling Child Actions in Navigation

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

## Multiple Navigation Patterns

### NavigationStack + Sheet

```swift
@Reducer
struct Feature {
    @Reducer
    enum Path {
        case detail(Detail)
        case settings(Settings)
    }

    @Reducer
    enum Destination {
        case alert(AlertState<Alert>)
        case sheet(Sheet)
    }

    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        @Presents var destination: Destination.State?
    }

    enum Action {
        case path(StackActionOf<Path>)
        case destination(PresentationAction<Destination.Action>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            // Handle actions
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$destination, action: \.destination)
    }
}
```

View:

```swift
struct FeatureView: View {
    @Bindable var store: StoreOf<Feature>

    var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            RootView()
        } destination: { store in
            switch store.case {
            case let .detail(store):
                DetailView(store: store)
            case let .settings(store):
                SettingsView(store: store)
            }
        }
        .sheet(
            item: $store.scope(state: \.destination?.sheet, action: \.destination.sheet)
        ) { store in
            SheetView(store: store)
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    }
}
```

## Deep Linking

### Setting Initial Path

```swift
// Set path on initialization or deep link
@ObservableState
struct State: Equatable {
    var path = StackState<Path.State>()

    init(deepLink: DeepLink? = nil) {
        if let deepLink {
            self.path = deepLink.navigationPath
        }
    }
}
```

### Navigating from External Event

```swift
case .deepLinkReceived(let deepLink):
    state.path.removeAll()
    switch deepLink {
    case .detail(let id):
        state.path.append(.detail(Detail.State(id: id)))
    case .settings:
        state.path.append(.settings(Settings.State()))
    }
    return .none
```

## NavigationStack State Inspection

### Checking Current Screen

```swift
// Check if specific screen is in stack
let isDetailPresented = state.path.contains { $0.is(\.detail) }

// Get specific screen state
if case let .detail(detailState) = state.path.last {
    // Access detail state
}

// Count screens
let screenCount = state.path.count
```

## Recursive Navigation

For self-referencing navigation (like nested folders):

```swift
@Reducer
struct Nested {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID
        var name: String = ""
        var rows: IdentifiedArrayOf<State> = []
    }

    enum Action {
        case addRowButtonTapped
        indirect case rows(IdentifiedActionOf<Nested>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .addRowButtonTapped:
                state.rows.append(State(id: UUID()))
                return .none

            case .rows:
                return .none
            }
        }
        .forEach(\.rows, action: \.rows) {
            Self()  // Recursive reference
        }
    }
}
```

View:

```swift
struct NestedView: View {
    let store: StoreOf<Nested>

    var body: some View {
        Form {
            TextField("Name", text: $store.name)

            Button("Add Row") {
                store.send(.addRowButtonTapped)
            }

            ForEach(
                store.scope(state: \.rows, action: \.rows)
            ) { childStore in
                NavigationLink(state: childStore) {
                    Text(childStore.name)
                }
            }
        }
    }
}
```

## Best Practices

1. **Use `@Reducer enum Path`** - For type-safe navigation destinations
2. **Use `StackState`** - For managing navigation stack state
3. **Use `@Presents`** - For sheets, alerts, and popovers alongside navigation
4. **Use `.forEach(\.path, action: \.path)`** - For path reducer composition
5. **Use `@Dependency(\.dismiss)`** - For child features to dismiss themselves
6. **Handle delegate actions** - Pop stack or navigate based on child completion
7. **Extension conformances** - Add `Equatable` via extension for enum reducers
8. **Deep linking** - Set initial path or manipulate path on external events
