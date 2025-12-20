# View Patterns

SwiftUI view patterns for displaying and interacting with TCA stores.

## Basic Store-Driven View

```swift
struct CounterView: View {
    let store: StoreOf<Counter>

    var body: some View {
        HStack {
            Button {
                store.send(.decrementButtonTapped)
            } label: {
                Image(systemName: "minus")
            }

            Text("\(store.count)")
                .monospacedDigit()

            Button {
                store.send(.incrementButtonTapped)
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}
```

## @Bindable for Two-Way Bindings

Use `@Bindable` to enable SwiftUI controls to bind directly to store state:

```swift
struct BindingFormView: View {
    @Bindable var store: StoreOf<BindingForm>

    var body: some View {
        Form {
            TextField("Type here", text: $store.text)

            Toggle("Disable other controls", isOn: $store.toggleIsOn)

            Stepper(
                "Max slider value: \(store.stepCount)",
                value: $store.stepCount,
                in: 0...100
            )

            Slider(value: $store.sliderValue, in: 0...Double(store.stepCount))
        }
    }
}
```

### @Bindable with Actions

For actions that need custom logic on value changes:

```swift
struct SettingsView: View {
    @Bindable var store: StoreOf<Settings>

    var body: some View {
        Toggle(
            "Notifications",
            isOn: $store.notificationsEnabled.sending(\.toggleNotifications)
        )

        Stepper(
            "\(store.count)",
            value: $store.count.sending(\.stepperChanged)
        )
    }
}
```

Corresponding reducer:

```swift
enum Action: BindableAction {
    case binding(BindingAction<State>)
    case toggleNotifications
    case stepperChanged

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .toggleNotifications:
                // Custom logic when toggle changes
                return .send(.requestNotificationPermission)

            case .stepperChanged:
                // Custom logic when stepper changes
                return .send(.trackCountChange)

            case .binding:
                return .none
            }
        }
    }
}
```

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

## Observing State Changes

### Direct State Access

```swift
struct StatusView: View {
    let store: StoreOf<Status>

    var body: some View {
        VStack {
            if store.isLoading {
                ProgressView()
            } else if let error = store.error {
                ErrorView(error: error)
            } else {
                ContentView(data: store.data)
            }
        }
    }
}
```

### State-Driven Animations

```swift
struct AnimatedCounterView: View {
    let store: StoreOf<Counter>

    var body: some View {
        Text("\(store.count)")
            .font(.largeTitle)
            .animation(.spring(), value: store.count)
    }
}
```

## View Actions

### onAppear Pattern

```swift
struct FeatureView: View {
    let store: StoreOf<Feature>

    var body: some View {
        VStack {
            // Content
        }
        .onAppear {
            store.send(.view(.onAppear))
        }
    }
}
```

### task Pattern for View Lifetime

```swift
struct FeatureView: View {
    let store: StoreOf<Feature>

    var body: some View {
        VStack {
            // Content
        }
        .task {
            await store.send(.view(.runTasks)).finish()
        }
        .onAppear {
            store.send(.view(.onAppear))
        }
    }
}
```

The `.task` modifier automatically cancels the effect when the view disappears, making it ideal for streaming effects that should run for the view's lifetime.

## Best Practices

1. **Use `let store`** - Store should be immutable in view
2. **Use `@Bindable`** - For two-way bindings with SwiftUI controls
3. **Scope stores** - Use `store.scope(state:action:)` for child features
4. **Computed properties** - Filter/transform collections in state, not view
5. **Actions for user events** - Send `.view` actions for user interactions
6. **`.task` for lifetime effects** - Use for streaming effects that should auto-cancel
7. **`.onAppear` for one-time work** - Use for initial data loading
