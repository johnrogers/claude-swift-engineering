# Presentation State

Patterns for managing presentation state in TCA (navigation destinations, alerts, sheets).

## Destination Management

```swift
@Reducer(state: .equatable)
public enum Destination {
    case detail(DetailReducer)
    case settings(SettingsReducer)
    case alert(AlertReducer)
}

// In main reducer
case .view(.didTapDetail):
    state.destination = .detail(DetailReducer.State())
    return .none

case .destination(.presented(.detail(.delegate(.didComplete)))):
    state.destination = nil
    return .send(.delegate(.userDidCompleteFlow))
```

## Alert Management

```swift
public enum Alert: Equatable {
    case confirmDelete
    case retryAction
    case showError(Error)
}

case .view(.didTapDelete):
    state.alert = .confirmDelete
    return .none

case .alert(.presented(.confirmDelete)):
    return .send(.deleteItem)
```

## Multiple Presentation Destinations

### Sheet, Popover, and Navigation Drill-Down

```swift
@Reducer
struct MultipleDestinations {
    @Reducer
    enum Destination {
        case drillDown(Counter)
        case popover(Counter)
        case sheet(Counter)
    }

    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
    }

    enum Action {
        case destination(PresentationAction<Destination.Action>)
        case showDrillDown
        case showPopover
        case showSheet
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .showDrillDown:
                state.destination = .drillDown(Counter.State())
                return .none

            case .showPopover:
                state.destination = .popover(Counter.State())
                return .none

            case .showSheet:
                state.destination = .sheet(Counter.State())
                return .none

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
```

### View with Multiple Presentation Modifiers

```swift
struct MultipleDestinationsView: View {
    @Bindable var store: StoreOf<MultipleDestinations>

    var body: some View {
        Form {
            Button("Show drill-down") {
                store.send(.showDrillDown)
            }

            Button("Show popover") {
                store.send(.showPopover)
            }

            Button("Show sheet") {
                store.send(.showSheet)
            }
        }
        .navigationDestination(
            item: $store.scope(
                state: \.destination?.drillDown,
                action: \.destination.drillDown
            )
        ) { store in
            CounterView(store: store)
        }
        .popover(
            item: $store.scope(
                state: \.destination?.popover,
                action: \.destination.popover
            )
        ) { store in
            CounterView(store: store)
        }
        .sheet(
            item: $store.scope(
                state: \.destination?.sheet,
                action: \.destination.sheet
            )
        ) { store in
            CounterView(store: store)
        }
    }
}
```

## Combining Alerts with Other Destinations

```swift
@Reducer
struct Feature {
    @Reducer
    enum Destination {
        case alert(AlertState<Alert>)
        case detail(Detail)
        case settings(Settings)
    }

    @CasePathable
    enum Alert {
        case confirmDelete
        case confirmLogout
    }

    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
    }

    enum Action {
        case destination(PresentationAction<Destination.Action>)
        case showAlert(Alert)
        case showDetail
        case showSettings
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .showAlert(let alert):
                state.destination = .alert(alertState(for: alert))
                return .none

            case .showDetail:
                state.destination = .detail(Detail.State())
                return .none

            case .showSettings:
                state.destination = .settings(Settings.State())
                return .none

            case .destination(.presented(.alert(.confirmDelete))):
                state.destination = nil
                return .send(.deleteItem)

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    func alertState(for alert: Alert) -> AlertState<Alert> {
        switch alert {
        case .confirmDelete:
            return AlertState {
                TextState("Delete Item")
            } actions: {
                ButtonState(role: .destructive, action: .confirmDelete) {
                    TextState("Delete")
                }
                ButtonState(role: .cancel) {
                    TextState("Cancel")
                }
            }

        case .confirmLogout:
            return AlertState {
                TextState("Log Out")
            } actions: {
                ButtonState(role: .destructive, action: .confirmLogout) {
                    TextState("Log Out")
                }
            }
        }
    }
}
```

View:

```swift
struct FeatureView: View {
    @Bindable var store: StoreOf<Feature>

    var body: some View {
        VStack {
            // Content
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
        .sheet(
            item: $store.scope(state: \.destination?.detail, action: \.destination.detail)
        ) { store in
            DetailView(store: store)
        }
        .sheet(
            item: $store.scope(state: \.destination?.settings, action: \.destination.settings)
        ) { store in
            SettingsView(store: store)
        }
    }
}
```
