# Testing Advanced Patterns

Advanced testing techniques including time control, keypath matching, exhaustivity, and complex scenarios.

## Given-When-Then Pattern

```swift
@Test("user can save form with valid data")
func testSaveFormWithValidData() async {
    // GIVEN: Valid form data
    let validData = FormData.test()
    let store = makeStore()

    // WHEN: User submits form
    await store.send(.view(.didChangeData(validData)))
    await store.send(.view(.didTapSave))

    // THEN: Form is saved successfully
    await store.receive(.didSaveData(.success(()))) {
        $0.isSaved = true
    }
}
```

## State Machine Testing

```swift
@Test("transitions through loading states correctly")
func testLoadingStateTransitions() async {
    let store = makeStore()

    // Initial state
    #expect(store.state.loadingState == .idle)

    // Start loading
    await store.send(.view(.onAppear)) {
        $0.loadingState = .loading
    }

    // Load success
    await store.receive(.didLoadData(.success([]))) {
        $0.loadingState = .loaded([])
    }
}
```

## Edge Case Testing

```swift
@Test("handles empty data gracefully")
func testEmptyData() async {
    let store = makeStore {
        $0.apiClient.fetchData = { [] }
    }

    await store.send(.view(.onAppear))
    await store.receive(.didLoadData(.success([]))) {
        $0.data = []
        $0.isEmpty = true
        $0.showEmptyState = true
    }
}
```

## Time-Based Testing

### Debouncing

```swift
@Test("debounces user input correctly")
func testDebouncedInput() async {
    let store = makeStore {
        $0.continuousClock = ImmediateClock()
    }

    // Send rapid input
    await store.send(.view(.didChangeText("a")))
    await store.send(.view(.didChangeText("ab")))
    await store.send(.view(.didChangeText("abc")))

    // Should only receive debounced action
    await store.receive(.searchDebounced("abc"))
}
```

### TestClock for Controlled Time

Use `TestClock` when you need precise control over time advancement:

```swift
@Test("timer advances correctly")
func testTimer() async {
    let clock = TestClock()

    let store = TestStore(initialState: Timer.State()) {
        Timer()
    } withDependencies: {
        $0.continuousClock = clock
    }

    // Start timer
    await store.send(.toggleTimerButtonTapped) {
        $0.isTimerActive = true
    }

    // Advance time by 1 second
    await clock.advance(by: .seconds(1))
    await store.receive(\.timerTick) {
        $0.secondsElapsed = 1
    }

    // Advance time by multiple seconds
    await clock.advance(by: .seconds(3))
    await store.receive(\.timerTick) {
        $0.secondsElapsed = 2
    }
    await store.receive(\.timerTick) {
        $0.secondsElapsed = 3
    }
    await store.receive(\.timerTick) {
        $0.secondsElapsed = 4
    }
}
```

### TestClock vs ImmediateClock

- **ImmediateClock**: All time-based operations complete immediately
    - Use for: Debouncing, delays, simple timeouts
    - Fast tests with no actual time passing

- **TestClock**: Manual control over time advancement
    - Use for: Timers, intervals, precise time-based behavior
    - Test exact timing sequences

```swift
// ImmediateClock example - delays complete instantly
@Test("loads data after delay")
func testDelayedLoad() async {
    let store = makeStore {
        $0.continuousClock = ImmediateClock()
    }

    await store.send(.loadData)
    await store.receive(\.dataLoaded)  // Immediate, no waiting
}

// TestClock example - control time advancement
@Test("polls every 5 seconds")
func testPolling() async {
    let clock = TestClock()
    let store = makeStore {
        $0.continuousClock = clock
    }

    await store.send(.startPolling)

    await clock.advance(by: .seconds(5))
    await store.receive(\.pollResponse)

    await clock.advance(by: .seconds(5))
    await store.receive(\.pollResponse)
}
```

## KeyPath-Based Action Receiving

Use keypath syntax for more concise action matching:

```swift
// Instead of this:
await store.receive(.numberFactResponse(.success("Test fact"))) {
    $0.fact = "Test fact"
}

// Use this:
await store.receive(\.numberFactResponse.success) {
    $0.fact = "Test fact"
}
```

### Complex KeyPaths

```swift
// Nested actions
await store.receive(\.destination.presented.detail.delegate.didComplete)

// ForEach actions
await store.receive(\.todos[id: todoID].toggleCompleted)

// Path actions
await store.receive(\.path[id: screenID].screenA.didSave)
```

### Partial Matching

```swift
// Match any success response
await store.receive(\.numberFactResponse.success) {
    $0.fact = "Test fact"
}

// Match any failure response
await store.receive(\.numberFactResponse.failure) {
    $0.alert = AlertState { TextState("Error") }
}

// Match delegate action
await store.receive(\.delegate) {
    // State changes
}
```

## Test Exhaustivity Control

TestStore has an `exhaustivity` property that controls whether all state changes and received actions must be explicitly asserted. By default, exhaustivity is `.on`, meaning you must assert every state change. Set it to `.off` for complex flows where you only care about specific outcomes.

### When to Use `.off`

Use `store.exhaustivity = .off` when:

1. **Complex async flows** - When testing flows with many intermediate state changes that aren't relevant to the test
2. **Third-party state** - When using `@FetchOne`, `@Fetch`, or other property wrappers that manage their own state
3. **Focus on outcomes** - When you only care about the final result, not every intermediate step
4. **Integration-style tests** - When testing end-to-end flows without micromanaging every state mutation

### Pattern

```swift
@Test("available status triggers sync when identity exists")
func availableStatusWithIdentity() async {
    let testIdentity = StoredAppleIdentity(appleUserId: "test-user-id")

    let store = makeStore {
        $0.appleIdentityStore.load = { testIdentity }
    }

    // Turn off exhaustivity - we only care about specific actions being sent
    store.exhaustivity = .off

    await store.send(.iCloudAccountStatusChanged(.available))

    // Assert only the actions we care about
    await store.receive(\.fetchUnclaimedShareItems)
    await store.receive(\.ensureSharedItemSubscription)

    // Other state changes and actions can happen without failing the test
}
```

### With State Verification

You can still verify specific state even with exhaustivity off:

```swift
@Test("edit mode populates from existing item")
func editModePopulatesFromExisting() async {
    let existingItem = makeTestExistingItem()
    let store = makeStore(initialState: .editing(existingItem))

    store.exhaustivity = .off

    #expect(store.state.mode == .edit(existingItem: existingItem))
    #expect(store.state.itemTypeEditor != nil)

    // Can check specific state properties without asserting every change
    if case .link(let linkState) = store.state.itemTypeEditor {
        #expect(linkState.urlInput == "https://example.com")
        #expect(linkState.preview?.title == "Example")
    }
}
```

### Best Practices

**DO**:
- Use exhaustivity off for integration tests focusing on end results
- Still assert the critical state changes and actions you care about
- Use it when dealing with @Fetch/@FetchOne that have internal state management
- Document why exhaustivity is off in complex tests

**DON'T**:
- Use it as a crutch to avoid thinking about state changes
- Turn it off for simple unit tests where all state is relevant
- Forget to assert the important outcomes just because exhaustivity is off
- Use it to hide bugs or unexpected state changes

### Example: Testing with @FetchOne

```swift
@Test("onAppear sets default list when no selection")
func onAppearSetsDefaultList() async {
    let inboxListID = UUID()
    let store = makeStore {
        $0.defaultDatabase.read = { db in
            return StashItemList(id: inboxListID, name: "Inbox", ...)
        }
    }

    // @FetchOne property wrapper manages its own state internally
    store.exhaustivity = .off

    await store.send(.view(.onAppear))
    await store.receive(.setSelectedListID(inboxListID))

    // We don't need to assert $selectedList changes because @FetchOne handles it
}
```
