# View Binding Patterns

Basic store-driven views and @Bindable patterns for two-way bindings.

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
3. **Actions for user events** - Send `.view` actions for user interactions
4. **`.task` for lifetime effects** - Use for streaming effects that should auto-cancel
5. **`.onAppear` for one-time work** - Use for initial data loading
