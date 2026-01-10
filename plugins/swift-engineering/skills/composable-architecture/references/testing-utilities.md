# Testing Utilities

Test data patterns, organization, confirmation dialogs, dependency mocking, and @Shared state testing.

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

### Test Data Constants (Preferred)

Use enum-based ID constants for reproducible tests instead of creating new UUIDs:

```swift
// ✅ Good: Consistent test data constants
enum TestData {
    static let itemId1 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let itemId2 = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
}

@Test("sets item as favorite")
func testSetFavorite() async {
    let setFavoriteCalled = LockIsolated<UUID?>(nil)
    // Use constant - reproducible
    await store.send(.view(.onSetFavoriteTapped(TestData.itemId1)))
    #expect(setFavoriteCalled.value == TestData.itemId1)
}

// ❌ Avoid: Creating new UUIDs each test run
let itemId = UUID()  // Different every run, harder to debug
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

## LockIsolated Patterns

Use `LockIsolated` for thread-safe value capture in tests.

### setValue() vs withLock

```swift
// ✅ Preferred: Clean setter
let capturedId = LockIsolated<UUID?>(nil)
$0.itemClient.setFavorite = { id in
    capturedId.setValue(id)
}
#expect(capturedId.value == expectedId)

// Also valid: withLock for complex mutations
let callHistory = LockIsolated<[String]>([])
callHistory.withLock { $0.append("called") }
```

### Boolean Tracking

```swift
let wasCalled = LockIsolated(false)
$0.client.someMethod = {
    wasCalled.setValue(true)
}
#expect(wasCalled.value == true)
```

## Testing @Shared State Changes

### Using store.assert { } After Effects

When testing effects that modify `@Shared` state, use `store.assert { }` to verify state after effects complete:

```swift
@Test("confirm action enables feature via Shared")
func testConfirmEnablesFeature() async {
    var state = Feature.State()
    state.confirmationAlert = FeatureHelper.confirmationAlertState()

    let store = TestStore(initialState: state) {
        Feature()
    } withDependencies: {
        $0.itemClient.setFavorite = { _ in }
    }

    // Action triggers effect that modifies @Shared
    await store.send(.confirmationAlert(.presented(.confirm(itemId: nil)))) {
        $0.confirmationAlert = nil
    }

    // Verify @Shared state after effect completes
    store.assert {
        $0.$featureEnabled.withLock { $0 = true }
    }
}
```

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
13. Use `LockIsolated.setValue()` for cleaner value capture
14. Use `store.assert { }` to verify @Shared state after effects
15. Use test data constants (e.g., `BundleTestData.bundleId1`) instead of `UUID()`
