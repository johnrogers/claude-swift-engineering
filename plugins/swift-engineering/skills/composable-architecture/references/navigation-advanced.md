# Navigation Advanced Patterns

Multiple navigation patterns, deep linking, and recursive navigation.

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

1. **Use `@Presents`** - For sheets, alerts, and popovers alongside navigation
2. **Deep linking** - Set initial path or manipulate path on external events
3. **State inspection** - Use `.contains` and pattern matching to check navigation state
4. **Recursive patterns** - Use `indirect case` and `Self()` for tree structures
5. **Combine patterns** - NavigationStack + sheet/alert destinations work well together
