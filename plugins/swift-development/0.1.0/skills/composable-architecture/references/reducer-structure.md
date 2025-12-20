# Reducer Structure, Actions, and State

Detailed patterns for structuring TCA reducers, organizing actions, and defining state.

## Reducer Structure

### Basic Reducer Template

```swift
@Reducer
public struct FeatureNameReducer {

    @ObservableState
    public struct State: Equatable {
        // State properties
        public init() {}
    }

    public enum Action: ViewAction {
        // Actions organized by boundary
        case view(View)
        case delegate(Delegate)
        case interface(Interface)
        // Internal actions
    }

    public init() {}

    @Dependency(\.dependencyName) var dependencyName

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .onAppear:
                    return .send(.loadData)
                case .didTapSave:
                    return .send(.saveData)
                }

            case .delegate:
                return .none

            case .interface:
                return .none
            }
        }
        .ifLet(\.childState, action: \.childAction) {
            ChildReducer()
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
```

### @Reducer Enum Conformances

**CRITICAL**: `@Reducer` enum definitions must use extensions for protocol conformances like `Equatable` or `Sendable`. Never add conformances directly to the `@Reducer` declaration.

```swift
// ❌ INCORRECT - Do not add conformances directly
@Reducer enum Destination: Equatable {
    case settings(SettingsFeature)
}

// ✅ CORRECT - Use extension for conformances
@Reducer enum Destination {
    case settings(SettingsFeature)
}

extension Destination: Equatable {}
```

**Pattern**: Always define the extension at file scope, directly after the parent reducer's closing brace:

```swift
@Reducer
struct ParentFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
    }

    enum Action {
        case destination(PresentationAction<Destination.Action>)
    }

    @Reducer enum Destination {
        case settings(SettingsFeature)
        case detail(DetailFeature)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            // ...
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

// Extension must be at file scope, after the reducer definition
extension ParentFeature.Destination: Equatable {}
```

**Why this is required**: The `@Reducer` macro generates code that conflicts with conformances added directly to the enum declaration. Extensions allow the macro-generated code to work correctly while still providing the necessary protocol conformances.

## Action Organization

Always organize actions by their intended use:

```swift
public enum Action: ViewAction {
    // MARK: - View Actions
    enum View {
        case onAppear
        case didTapSave
        case didTapCancel
        case didSelectItem(Int)
        case didChangeText(String)
    }
    case view(View)

    // MARK: - Delegate Actions
    enum Delegate: Equatable {
        case userDidCompleteFlow
        case onDataLoaded(Data)
        case onError(Error)
    }
    case delegate(Delegate)

    // MARK: - Interface Actions
    enum Interface: Equatable {
        case refresh
        case reload
        case updateData(Data)
    }
    case interface(Interface)

    // MARK: - Internal Actions
    case loadData
    case didLoadData(Result<Data, Error>)
    case saveData
    case didSaveData(Result<Void, Error>)
    case setAlertState(AlertState<Action.Alert>)
    case setDestination(Destination.State?)

    // MARK: - Presentation Actions
    case destination(PresentationAction<Destination.Action>)
    case alert(PresentationAction<Action.Alert>)
}
```

## Result Types in Actions

Use `Result` types for async operation responses to handle both success and failure cases:

```swift
enum Action {
    case numberFactButtonTapped
    case numberFactResponse(Result<String, any Error>)
    case loadUserButtonTapped
    case userResponse(Result<User, any Error>)
}
```

Handle in reducer:

```swift
case .numberFactButtonTapped:
    state.isLoading = true
    return .run { [count = state.count] send in
        await send(.numberFactResponse(Result {
            try await factClient.fetch(count)
        }))
    }

case .numberFactResponse(.success(let fact)):
    state.isLoading = false
    state.fact = fact
    return .none

case .numberFactResponse(.failure(let error)):
    state.isLoading = false
    state.alert = AlertState {
        TextState("Error loading fact: \(error.localizedDescription)")
    }
    return .none
```

### Result with catch:

Alternatively, use the `catch:` parameter in effects:

```swift
case .loadItem(let id):
    return .run { send in
        let item = try await apiClient.fetchItem(id)
        await send(.itemLoaded(item))
    } catch: { error, send in
        await send(.loadFailed(error))
    }
```

## State Management

### Observable State

```swift
@ObservableState
public struct State: Equatable {
    // Basic properties
    var isLoading: Bool = false
    var data: [Item] = []
    var selectedItem: Item?

    // Shared state
    @Shared var userPreferences: UserPreferences

    // Presentation state
    @Presents var destination: Destination.State?
    @Presents var alert: AlertState<Action.Alert>?

    // Computed properties
    var isEmpty: Bool {
        data.isEmpty
    }

    var canSave: Bool {
        !data.isEmpty && !isLoading
    }
}
```

### Complex State with CasePathable

```swift
@ObservableState
public struct State: Equatable {
    @CasePathable
    @dynamicMemberLookup
    enum LoadingState: Equatable {
        case idle
        case loading
        case loaded(Data)
        case error(Error)
    }

    var loadingState: LoadingState = .idle
    var otherProperties: String = ""
}
```
