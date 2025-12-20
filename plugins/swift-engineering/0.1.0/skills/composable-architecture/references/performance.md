# Performance Considerations

Detailed patterns for optimizing TCA features.

## State Updates

### Computed Properties vs Stored Properties

```swift
// ✅ Good: Use computed properties for derived state
@ObservableState
public struct State: Equatable {
    var items: [Item] = []
    var selectedIds: Set<Int> = []

    // Computed property - recalculated only when dependencies change
    var selectedItems: [Item] {
        items.filter { selectedIds.contains($0.id) }
    }

    // Computed property for validation
    var canSave: Bool {
        !selectedItems.isEmpty && !isLoading
    }
}

// ❌ Avoid: Storing derived state that could be computed
@ObservableState
public struct State: Equatable {
    var items: [Item] = []
    var selectedIds: Set<Int> = []
    var selectedItems: [Item] = [] // This could become stale
}
```

### Efficient State Updates

```swift
// ✅ Good: Batch related state changes
case .view(.didSelectMultipleItems(let ids)):
    state.selectedIds.formUnion(ids)
    return .none

// ✅ Good: Use value types for better performance
@ObservableState
public struct State: Equatable {
    var items: IdentifiedArrayOf<Item.State> // Better than [Item]
    var filters: FilterState // Value type
}

// ❌ Avoid: Multiple separate state updates
case .view(.didSelectMultipleItems(let ids)):
    for id in ids {
        state.selectedIds.insert(id) // Multiple updates
    }
    return .none
```

## Effect Performance

### Debouncing and Cancellation

```swift
// ✅ Good: Debounce user input
case .view(.didChangeSearchText(let text)):
    state.searchText = text
    return .run { send in
        try await Task.sleep(for: .milliseconds(300))
        await send(.searchDebounced(text))
    }
    .cancellable(id: "search", cancelInFlight: true)

// ✅ Good: Cancel effects when appropriate
case .view(.onDisappear):
    return .cancel(id: "data-loading")

// ✅ Good: Use weak capture in closures
case .loadData:
    return .run { [weak self] send in
        guard let self = self else { return }
        let data = try await self.apiClient.fetchData()
        await send(.didLoadData(.success(data)))
    }
```

## Reducer Composition

```swift
// ✅ Good: Use .forEach for collections
public var body: some ReducerOf<Self> {
    Reduce { state, action in
        // Main logic
    }
    .forEach(\.items, action: \.items) {
        ItemReducer()
    }
}

// ✅ Good: Use .ifLet for optional child reducers
public var body: some ReducerOf<Self> {
    Reduce { state, action in
        // Main logic
    }
    .ifLet(\.childState, action: \.childAction) {
        ChildReducer()
    }
}
```

## Sharing Logic

```swift
// ❌ Avoid: Sharing logic through actions (inefficient)
case .buttonTapped:
    state.count += 1
    return .send(.sharedComputation)

case .toggleChanged:
    state.isEnabled.toggle()
    return .send(.sharedComputation)

case .sharedComputation:
    // Shared work and effects
    return .run { send in
        // Shared effect
    }

// ✅ Good: Share logic through methods
case .buttonTapped:
    state.count += 1
    return self.sharedComputation(state: &state)

case .toggleChanged:
    state.isEnabled.toggle()
    return self.sharedComputation(state: &state)

// Helper method in reducer
func sharedComputation(state: inout State) -> Effect<Action> {
    // Shared work and effects
    return .run { send in
        // Shared effect
    }
}
```

## CPU-Intensive Calculations

```swift
// ❌ Avoid: CPU-intensive work in reducer (blocks main thread)
case .buttonTapped:
    var result = 0
    for value in someLargeCollection {
        // Intense computation
        result += complexCalculation(value)
    }
    state.result = result
    return .none

// ✅ Good: Move CPU work to effects with cooperative yielding
case .buttonTapped:
    return .run { send in
        var result = 0
        for (index, value) in someLargeCollection.enumerated() {
            // Intense computation
            result += complexCalculation(value)

            // Yield every 1000 iterations to cooperate in thread pool
            if index.isMultiple(of: 1_000) {
                await Task.yield()
            }
        }
        await send(.computationResponse(result))
    }

case let .computationResponse(result):
    state.result = result
    return .none
```

## High-Frequency Actions

```swift
// ❌ Avoid: Sending actions for every small change
case .startButtonTapped:
    return .run { send in
        var count = 0
        let max = await self.eventsClient.count()

        for await event in self.eventsClient.events() {
            defer { count += 1 }
            // Sends 100,000+ actions for large datasets
            await send(.progress(Double(count) / Double(max)))
        }
    }

// ✅ Good: Throttle high-frequency actions
case .startButtonTapped:
    return .run { send in
        var count = 0
        let max = await self.eventsClient.count()
        let interval = max / 100 // Report at most 100 times

        for await event in self.eventsClient.events() {
            defer { count += 1 }
            if count.isMultiple(of: interval) {
                await send(.progress(Double(count) / Double(max)))
            }
        }
    }

// ❌ Avoid: Slider sending actions for every change
Slider(value: store.$opacity, in: 0...1)

// ✅ Good: Slider with local state and onEditingChanged
@State private var opacity: Double = 0.5

Slider(value: $opacity, in: 0...1) {
    store.send(.setOpacity(opacity))
}
```

## Store Scoping

```swift
// ✅ Good: Scope to stored child properties (performant)
ChildView(
    store: store.scope(state: \.child, action: \.child)
)

// ❌ Avoid: Scope to computed properties (performance issue)
extension ParentFeature.State {
    var computedChild: ChildFeature.State {
        ChildFeature.State(
            // Heavy computation here...
        )
    }
}

ChildView(
    store: store.scope(state: \.computedChild, action: \.child) // ❌ Bad
)

// ✅ Good: Move computation to child view
ChildView(
    store: store.scope(state: \.child, action: \.child)
)

// In ChildView, compute derived state locally
struct ChildView: View {
    let store: StoreOf<ChildReducer>

    var body: some View {
        let computedValue = heavyComputation(store.state)
        // Use computedValue in view
    }
}
```

## Memory Management

```swift
// ✅ Good: Use weak capture in effects
case .loadData:
    return .run { [weak self] send in
        guard let self = self else { return }
        let data = try await self.apiClient.fetchData()
        await send(.didLoadData(.success(data)))
    }

// ✅ Good: Clean up resources
case .view(.onDisappear):
    return .concatenate(
        .cancel(id: "data-loading"),
        .cancel(id: "search")
    )

// ✅ Good: Use proper cancellation IDs
case .loadData:
    return .run { send in
        for try await data in apiClient.dataStream() {
            await send(.didReceiveData(data))
        }
    }
    .cancellable(id: "data-stream")
```

## Async/Await Performance

```swift
// ✅ Good: Use structured concurrency
case .loadData:
    return .run { send in
        async let data = apiClient.fetchData()
        async let metadata = apiClient.fetchMetadata()

        let (dataResult, metadataResult) = await (data, metadata)
        await send(.didLoadData(.success((dataResult, metadataResult))))
    }

// ✅ Good: Handle cancellation properly
case .loadData:
    return .run { send in
        do {
            let data = try await apiClient.fetchData()
            if !Task.isCancelled {
                await send(.didLoadData(.success(data)))
            }
        } catch {
            if !Task.isCancelled {
                await send(.didLoadData(.failure(error)))
            }
        }
    }
    .cancellable(id: "data-loading")
```
