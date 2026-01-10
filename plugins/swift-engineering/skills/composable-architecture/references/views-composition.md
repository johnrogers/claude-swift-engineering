# View Composition Patterns

ForEach scoping, child features, and optional child views.

## ForEach with Scoped Stores

### IdentifiedArray Pattern

```swift
struct TodosView: View {
    let store: StoreOf<Todos>

    var body: some View {
        List {
            ForEach(
                store.scope(state: \.todos, action: \.todos)
            ) { store in
                TodoRowView(store: store)
            }
        }
    }
}
```

Corresponding reducer:

```swift
@Reducer
struct Todos {
    @ObservableState
    struct State: Equatable {
        var todos: IdentifiedArrayOf<Todo.State> = []
    }

    enum Action {
        case todos(IdentifiedActionOf<Todo>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            // Parent-level logic
            return .none
        }
        .forEach(\.todos, action: \.todos) {
            Todo()
        }
    }
}
```

### Filtered Collections

```swift
struct TodosView: View {
    let store: StoreOf<Todos>

    var body: some View {
        List {
            ForEach(
                store.scope(state: \.filteredTodos, action: \.todos)
            ) { store in
                TodoRowView(store: store)
            }
        }
    }
}
```

Corresponding state with computed property:

```swift
@ObservableState
struct State: Equatable {
    var todos: IdentifiedArrayOf<Todo.State> = []
    var filter: Filter = .all

    var filteredTodos: IdentifiedArrayOf<Todo.State> {
        switch filter {
        case .all:
            return todos
        case .active:
            return todos.filter { !$0.isComplete }
        case .completed:
            return todos.filter { $0.isComplete }
        }
    }
}
```

## Child Feature Scope

### Single Child Feature

```swift
struct TwoCountersView: View {
    let store: StoreOf<TwoCounters>

    var body: some View {
        VStack {
            CounterView(
                store: store.scope(state: \.counter1, action: \.counter1)
            )

            CounterView(
                store: store.scope(state: \.counter2, action: \.counter2)
            )
        }
    }
}
```

Corresponding reducer:

```swift
@Reducer
struct TwoCounters {
    @ObservableState
    struct State: Equatable {
        var counter1 = Counter.State()
        var counter2 = Counter.State()
    }

    enum Action {
        case counter1(Counter.Action)
        case counter2(Counter.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.counter1, action: \.counter1) {
            Counter()
        }
        Scope(state: \.counter2, action: \.counter2) {
            Counter()
        }
    }
}
```

## Optional Child Features

### Using ifLet

```swift
struct OptionalCounterView: View {
    let store: StoreOf<OptionalCounter>

    var body: some View {
        VStack {
            if let store = store.scope(state: \.counter, action: \.counter) {
                CounterView(store: store)
            } else {
                Text("Counter not loaded")
            }

            Button("Toggle Counter") {
                store.send(.toggleCounterButtonTapped)
            }
        }
    }
}
```

Corresponding reducer:

```swift
@Reducer
struct OptionalCounter {
    @ObservableState
    struct State: Equatable {
        var counter: Counter.State?
    }

    enum Action {
        case counter(Counter.Action)
        case toggleCounterButtonTapped
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .toggleCounterButtonTapped:
                state.counter = state.counter == nil ? Counter.State() : nil
                return .none

            case .counter:
                return .none
            }
        }
        .ifLet(\.counter, action: \.counter) {
            Counter()
        }
    }
}
```

## Best Practices

1. **Scope stores** - Use `store.scope(state:action:)` for child features
2. **Computed properties** - Filter/transform collections in state, not view
3. **IdentifiedArrayOf** - Use for collections of child features
4. **`.forEach`** - Compose reducers for collections
5. **`.ifLet`** - Compose reducers for optional child features
6. **Scope in view** - Create scoped stores in the view body for proper observation
