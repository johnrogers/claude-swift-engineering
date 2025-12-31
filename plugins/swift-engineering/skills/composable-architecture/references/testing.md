# Testing Patterns and Best Practices

Comprehensive patterns for testing TCA features with TestStore and SwiftTesting.

## Table of Contents
1. [Test Structure](#test-structure)
2. [Test Store Patterns](#test-store-patterns)
3. [Action Testing](#action-testing)
4. [State Verification](#state-verification)
5. [Dependency Testing](#dependency-testing)
6. [Error Testing](#error-testing)
7. [Presentation Testing](#presentation-testing)
8. [Async Testing](#async-testing)
9. [Test Data Patterns](#test-data-patterns)
10. [Test Organization](#test-organization)
11. [Advanced Patterns](#advanced-patterns)

## Test Structure

### Equatable Conformance Requirement

**CRITICAL**: To test TCA reducers with `TestStore`, the reducer's `State` **must** conform to `Equatable`. This is a hard requirement for TCA testing.

**Key Rules**:
1. All `State` structs in reducers you want to test must conform to `Equatable`
2. **Every property type** within that `State` must also conform to `Equatable`
3. This includes nested child feature states
4. This includes types wrapped by `@Presents` (e.g., `@Presents var destination: Destination.State?` requires `Destination.State` to be `Equatable`)
5. The conformance cascades down - if any nested type cannot be made `Equatable`, the parent `State` cannot be tested with `TestStore`

**Example**:
```swift
// ❌ Cannot test - State doesn't conform to Equatable
@ObservableState
struct State {
    var items: [Item] = []
    @Presents var destination: Destination.State?
}

// ✅ Can test - State and all nested types conform to Equatable
@ObservableState
struct State: Equatable {
    var items: [Item] = []  // Item must be Equatable
    @Presents var destination: Destination.State?  // Destination.State must be Equatable
}

// Destination.State must be Equatable
@Reducer enum Destination {
    case settings(SettingsFeature)  // SettingsFeature.State must be Equatable
}
extension Destination.State: Equatable {}

// And any child features used by Destination
@ObservableState
struct SettingsFeature.State: Equatable {
    // All properties must be Equatable
}
```

**When you can't make State Equatable**:
- If any nested type cannot conform to `Equatable`, you cannot use `TestStore` for that reducer
- Consider refactoring to extract testable logic into child reducers with `Equatable` states
- Or test the non-`Equatable` types separately without `TestStore`

### Basic Test Suite

```swift
@Suite("Feature Name")
@MainActor
struct FeatureNameTests {
    typealias Reducer = FeatureNameReducer

    // Test data and helpers
    private let testData = TestData()

    private func makeStore(
        initialState: Reducer.State = .init(),
        dependencies: (inout DependencyValues) -> Void = { _ in }
    ) -> TestStoreOf<Reducer> {
        TestStore(initialState: initialState) {
            Reducer()
        } withDependencies: {
            $0.apiClient = .test()
            $0.analytics = .test()
            $0.continuousClock = ImmediateClock()
            $0.notificationFeedbackGenerator = .test()
            $0.dismiss = DismissEffect { }
            dependencies(&$0)
        }
    }
}
```

### Test Naming Conventions

```swift
// ✅ Descriptive test names that explain the scenario
@Test("onAppear loads data successfully")
func testOnAppearSuccess() async { }

@Test("handles network error gracefully")
func testNetworkError() async { }

@Test("validates form before submission")
func testFormValidation() async { }

// For complex scenarios, use underscores
@Test("user_can_add_multiple_items_and_save")
func testUserCanAddMultipleItemsAndSave() async { }
```

## Test Store Patterns

### Basic Setup

```swift
private func makeStore(
    initialState: Reducer.State = .init(),
    dependencies: (inout DependencyValues) -> Void = { _ in }
) -> TestStoreOf<Reducer> {
    TestStore(initialState: initialState) {
        Reducer()
    } withDependencies: {
        // Default test dependencies
        $0.apiClient = .test()
        $0.analytics = .test()
        $0.continuousClock = ImmediateClock()
        $0.notificationFeedbackGenerator = .test()
        $0.dismiss = DismissEffect { }

        // Custom dependencies
        dependencies(&$0)
    }
}
```

### Custom State Setup

```swift
private func makeStore(
    shiftId: Int = 1,
    allowsMultipleSegments: Bool = true
) -> TestStoreOf<EditShiftReducer> {
    let dependencies = ShiftOperationsDependencies(
        allowsMultipleWorkSegments: allowsMultipleSegments,
        allowsConsentOverride: true
    )

    let state = withDependencies {
        $0.shiftOperationsDependencies = dependencies
    } operation: {
        EditShiftReducer.State(shiftId: shiftId)
    }

    return TestStore(initialState: state) {
        EditShiftReducer()
    } withDependencies: {
        $0.shiftClient = .test()
        $0.shiftOperationsDependencies = dependencies
    }
}
```

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

### Mock Dependencies

```swift
extension APIClient {
    static func test(
        fetchData: @escaping () async throws -> [Item] = { [] },
        saveData: @escaping (Item) async throws -> Void = { _ in }
    ) -> Self {
        Self(
            fetchData: fetchData,
            saveData: saveData
        )
    }
}

extension Analytics {
    static func test(
        track: @escaping (Event) -> Void = { _ in }
    ) -> Self {
        Self(track: track)
    }
}
```

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

## Test Data Patterns

### Test Data Factories

```swift
extension Item {
    static func test(
        id: Int = 1,
        name: String = "Test Item",
        isEnabled: Bool = true
    ) -> Self {
        Self(
            id: id,
            name: name,
            isEnabled: isEnabled
        )
    }
}
```

### Test Data Arrays

```swift
extension Array where Element == Item {
    static func test(count: Int = 3) -> [Item] {
        (1...count).map { Item.test(id: $0, name: "Item \($0)") }
    }
}
```

## Test Organization

### Test Grouping with MARK

```swift
@Suite("Feature Name")
@MainActor
struct FeatureNameTests {

    // MARK: - Setup
    private func makeStore() -> TestStoreOf<Reducer> { ... }

    // MARK: - Initialization Tests
    @Test("initializes with correct default state")
    func testInitialization() async { ... }

    // MARK: - User Interaction Tests
    @Test("responds to user taps")
    func testUserInteraction() async { ... }

    // MARK: - Data Loading Tests
    @Test("loads data on appear")
    func testDataLoading() async { ... }

    // MARK: - Error Handling Tests
    @Test("handles network errors")
    func testErrorHandling() async { ... }

    // MARK: - Navigation Tests
    @Test("navigates to detail screen")
    func testNavigation() async { ... }
}
```

### Test Documentation

```swift
/// Tests the initialization of the EditShift feature.
/// Verifies that:
/// - Shift is loaded correctly
/// - State is set up with correct initial values
/// - Properties are properly initialized
@Test("onAppear loads shift successfully")
func testOnAppearLoadsShift() async { ... }
```

## Advanced Patterns

### Given-When-Then Pattern

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

### State Machine Testing

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

### Edge Case Testing

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

### Time-Based Testing

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

### Test Exhaustivity Control

TestStore has an `exhaustivity` property that controls whether all state changes and received actions must be explicitly asserted. By default, exhaustivity is `.on`, meaning you must assert every state change. Set it to `.off` for complex flows where you only care about specific outcomes.

#### When to Use `.off`

Use `store.exhaustivity = .off` when:

1. **Complex async flows** - When testing flows with many intermediate state changes that aren't relevant to the test
2. **Third-party state** - When using `@FetchOne`, `@Fetch`, or other property wrappers that manage their own state
3. **Focus on outcomes** - When you only care about the final result, not every intermediate step
4. **Integration-style tests** - When testing end-to-end flows without micromanaging every state mutation

#### Pattern

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

#### With State Verification

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

#### Best Practices

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

#### Example: Testing with @FetchOne

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

## ConfirmationDialogState Testing

When testing features that use `ConfirmationDialogState`, follow these patterns:

### Basic Pattern

```swift
@Test("confirmation dialog action deletes with preserve")
func testConfirmationDialogAction() async {
    var state = Feature.State()
    state.confirmDeleteBundleId = testBundleId
    state.confirmationDialog = .deleteBundle(name: "Test", itemCount: 2)

    let deleteCalled = LockIsolated<(UUID, Bool)?>(nil)

    let store = TestStore(initialState: state) {
        Feature()
    } withDependencies: {
        $0.bundleClient.delete = { id, preserveItems in
            deleteCalled.setValue((id, preserveItems))
        }
    }

    // Send the presented action and expect BOTH state changes
    await store.send(.confirmationDialog(.presented(.moveItemsToInbox))) {
        $0.confirmDeleteBundleId = nil
        $0.confirmationDialog = nil  // Dialog clears on action
    }

    // CRITICAL: Exhaust effects from .run blocks
    await store.finish()

    #expect(deleteCalled.value?.0 == testBundleId)
    #expect(deleteCalled.value?.1 == true)
}
```

### Key Points

1. **Clear both state properties**: When a dialog action fires, set both `confirmationDialog = nil` and any tracking ID to `nil`
2. **Use `await store.finish()`**: Effects from `.run { }` blocks must be exhausted after sending actions
3. **Dialog dismiss**: For `.dismiss` action, only `confirmationDialog` clears (not tracking IDs)

```swift
await store.send(.confirmationDialog(.dismiss)) {
    $0.confirmationDialog = nil
    // Note: confirmDeleteBundleId stays set (becomes stale but harmless)
}
```

## Dependency Mocking Completeness

When modifying reducers to call new dependencies, **always update corresponding test mocks**:

### Common Pitfall

```swift
// Reducer calls TWO dependencies:
case .view(.saveTapped):
    return .run { send in
        try await bundleClient.update(id, name, color)
        try await bundleClient.updateTemporary(id, isTemporary)  // NEW!
        await send(.delegate(.saved))
    }

// ❌ Test only mocks ONE - will fail with unimplemented dependency
let store = TestStore(...) {
    $0.bundleClient.update = { ... }
    // Missing: $0.bundleClient.updateTemporary
}

// ✅ Mock ALL dependencies called by the action
let store = TestStore(...) {
    $0.bundleClient.update = { ... }
    $0.bundleClient.updateTemporary = { _, _ in }  // Added!
}
```

### Rule

When you add a dependency call to a reducer, grep for existing tests and add the mock.

## Summary

**Key Principles**:
1. Use SwiftTesting `@Suite` and `@Test` for test organization
2. Create reusable `makeStore` helpers with default test dependencies
3. Use `ImmediateClock` for time-based tests
4. Test state transitions explicitly with closure assertions
5. Mock dependencies with `.test()` factory methods
6. Test both success and error paths
7. Verify navigation and presentation state changes
8. Use test data factories for consistent test data
9. Organize tests with MARK comments
10. Document complex tests with comments
11. Use `await store.finish()` to exhaust effects from `.run` blocks
12. When adding new dependency calls, update ALL test mocks
