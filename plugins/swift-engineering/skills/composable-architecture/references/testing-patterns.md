# Testing Patterns

Core patterns for testing actions, state changes, dependencies, errors, and presentations in TCA.

## Action Testing

### Basic Action Testing

```swift
@Test("onAppear triggers data loading")
func testOnAppear() async {
    let store = makeStore()

    await store.send(.view(.onAppear))
    await store.receive(.loadData) {
        $0.isLoading = true
    }
}
```

### Success Flow Testing

```swift
@Test("successful data loading flow")
func testSuccessfulDataLoading() async {
    let testData = [Item(id: 1, name: "Test")]
    let store = makeStore {
        $0.apiClient.fetchData = { testData }
    }

    await store.send(.view(.onAppear))
    await store.receive(.loadData) {
        $0.isLoading = true
    }
    await store.receive(.didLoadData(.success(testData))) {
        $0.isLoading = false
        $0.data = testData
    }
}
```

### Delegate Action Testing

```swift
@Test("notifies parent on completion")
func testDelegateNotification() async {
    let store = makeStore()

    await store.send(.view(.didTapSave))
    await store.receive(.delegate(.userDidCompleteFlow))
}
```

### Receive Without State Change

**IMPORTANT**: When receiving an action that doesn't change state, omit the closure entirely:

```swift
// ✅ No state change expected - omit closure
await store.receive(\.delegate.bundleSelected)
await store.receive(\.delegate.cancelled)

// ❌ WRONG - causes "Expected state to change, but no change occurred"
await store.receive(\.delegate.bundleSelected) { _ in }
await store.receive(\.delegate.cancelled) { _ in }
```

The closure in `receive` tells TestStore you expect state mutations. Using `{ _ in }` or `{ $0 }` when no change occurs will fail the test.

## State Verification

### Basic State Verification

```swift
await store.send(.view(.didTapSave)) {
    $0.isLoading = true
    $0.canSave = false
}
```

### Complex State Verification

```swift
await store.receive(.didLoadData(.success(testData))) {
    $0.isLoading = false
    $0.data = testData
    $0.isEmpty = false
    $0.canSave = true
}
```

### Computed Property Testing

```swift
@Test("computed properties work correctly")
func testComputedProperties() async {
    var state = Reducer.State()

    // Test empty state
    #expect(state.isEmpty == true)
    #expect(state.canSave == false)

    // Test with data
    state.data = [Item(id: 1, name: "Test")]
    #expect(state.isEmpty == false)
    #expect(state.canSave == true)
}
```

## Dependency Testing

### Dependency Verification

```swift
@Test("tracks analytics events")
func testAnalyticsTracking() async {
    var trackedEvents: [AnalyticsEvent] = []
    let store = makeStore {
        $0.analytics = .test { event in
            trackedEvents.append(event)
        }
    }

    await store.send(.view(.onAppear))

    #expect(trackedEvents.count == 1)
    #expect(trackedEvents.first == .screenViewed)
}
```

### Multiple Dependencies Testing

```swift
@Test("coordinates multiple dependencies")
func testMultipleDependencies() async {
    var analyticsEvents: [AnalyticsEvent] = []
    var apiCalls: [String] = []

    let store = makeStore {
        $0.analytics = .test { event in
            analyticsEvents.append(event)
        }
        $0.apiClient = .test { endpoint in
            apiCalls.append(endpoint)
            return TestData()
        }
    }

    await store.send(.view(.onAppear))

    #expect(apiCalls.contains("fetchData"))
    #expect(analyticsEvents.contains(.screenViewed))
}
```

## Error Testing

### Error State Verification

```swift
@Test("shows error alert on failure")
func testErrorAlert() async {
    let error = NetworkError.timeout
    let store = makeStore {
        $0.apiClient.fetchData = { throw error }
    }

    await store.send(.view(.onAppear))
    await store.receive(.didLoadData(.failure(error))) {
        $0.alert = .error(error)
    }

    #expect(store.state.alert != nil)
}
```

### Error Recovery Testing

```swift
@Test("can retry after error")
func testErrorRetry() async {
    var callCount = 0
    let store = makeStore {
        $0.apiClient.fetchData = {
            callCount += 1
            if callCount == 1 {
                throw NetworkError.timeout
            }
            return [Item(id: 1, name: "Test")]
        }
    }

    // First attempt fails
    await store.send(.view(.onAppear))
    await store.receive(.didLoadData(.failure(NetworkError.timeout)))

    // Retry succeeds
    await store.send(.alert(.presented(.retry)))
    await store.receive(.didLoadData(.success([Item(id: 1, name: "Test")])))

    #expect(callCount == 2)
}
```

## Presentation Testing

### Destination Testing

```swift
@Test("navigates to detail screen")
func testNavigationToDetail() async {
    let store = makeStore()

    await store.send(.view(.didTapDetail)) {
        $0.destination = .detail(DetailReducer.State())
    }
}

@Test("handles detail completion")
func testDetailCompletion() async {
    let store = makeStore()

    // Navigate to detail
    await store.send(.view(.didTapDetail))

    // Complete detail flow
    await store.send(.destination(.presented(.detail(.delegate(.didComplete))))) {
        $0.destination = nil
    }
    await store.receive(.delegate(.userDidCompleteFlow))
}
```

### Alert Testing

```swift
@Test("shows confirmation alert")
func testConfirmationAlert() async {
    let store = makeStore()

    await store.send(.view(.didTapDelete)) {
        $0.alert = .confirmDelete
    }

    await store.send(.alert(.presented(.confirmDelete))) {
        $0.alert = nil
    }
    await store.receive(.deleteItem)
}
```

## Async Testing

### Async Effect Testing

```swift
@Test("handles async operations")
func testAsyncOperations() async {
    let expectation = Expectation(description: "Async operation completes")
    let store = makeStore {
        $0.apiClient.fetchData = {
            try await Task.sleep(nanoseconds: 1_000_000)
            expectation.fulfill()
            return [Item(id: 1, name: "Test")]
        }
    }

    await store.send(.view(.onAppear))
    await store.receive(.didLoadData(.success([Item(id: 1, name: "Test")])))

    await expectation.await()
}
```

### Effect Cancellation Testing

```swift
@Test("cancels effects on dismiss")
func testEffectCancellation() async {
    var isCancelled = false
    let store = makeStore {
        $0.apiClient.fetchData = {
            try await Task.sleep(nanoseconds: 1_000_000)
            if Task.isCancelled {
                isCancelled = true
                throw CancellationError()
            }
            return []
        }
    }

    await store.send(.view(.onAppear))
    await store.send(.view(.onDisappear))

    try await Task.sleep(nanoseconds: 2_000_000)
    #expect(isCancelled == true)
}
```
