# Testing Fundamentals

Core requirements and setup patterns for testing TCA features with TestStore and SwiftTesting.

## Equatable Conformance Requirement

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

## Basic Test Suite

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

## Test Naming Conventions

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

## Test Store Setup

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

## Mock Dependencies

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
