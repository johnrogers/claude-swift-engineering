# Shared State

Patterns for persistent and shared state in TCA using `@Shared`.

## @Shared with AppStorage

Use `@Shared(.appStorage)` for UserDefaults-backed persistent state:

```swift
@ObservableState
struct State: Equatable {
    @Shared(.appStorage("sortOrder")) var sortOrder: String = "date"
    @Shared(.appStorage("showCompleted")) var showCompleted: Bool = true
}
```

## Thread-Safe Mutations

Use `.withLock` for thread-safe mutations of @Shared state:

```swift
case .view(.onChangeSortOrder(let order)):
    state.$sortOrder.withLock { $0 = order }
    return .none

case .view(.onToggleCompleted):
    state.$showCompleted.withLock { $0.toggle() }
    return .none
```

## Animated Mutations

Wrap `.withLock` in `withAnimation` for animated changes:

```swift
case .view(.onChangeTheme(let theme)):
    withAnimation {
        state.$themeRawValue.withLock { $0 = theme.rawValue }
    }
    return .none
```

## Type-Safe Access with Computed Properties

Use computed properties for type-safe access to raw-value backed state:

```swift
@ObservableState
struct State: Equatable {
    @Shared(.appStorage("themeRawValue")) var themeRawValue: String = "system"

    var selectedTheme: Theme {
        Theme(rawValue: themeRawValue) ?? .system
    }
}
```

## Shared State Between Features

Use `@Shared` without a persistence strategy for in-memory shared state:

```swift
@ObservableState
struct State: Equatable {
    @Shared var userSession: UserSession
}
```

Pass the same `@Shared` reference to child features to share state:

```swift
case .view(.onShowSettings):
    state.destination = .settings(
        SettingsFeature.State(userSession: state.$userSession)
    )
    return .none
```

## FileStorageKey for Persistent Data

Use `FileStorageKey` to persist shared state to disk as JSON:

```swift
// Define the shared key
extension SharedKey where Self == FileStorageKey<IdentifiedArrayOf<SyncUp>>.Default {
    static var syncUps: Self {
        Self[
            .fileStorage(.documentsDirectory.appending(component: "sync-ups.json")),
            default: []
        ]
    }
}

// Use in state
@ObservableState
struct State: Equatable {
    @Shared(.syncUps) var syncUps
}

// Mutate with .withLock
case .view(.didAddSyncUp(let syncUp)):
    state.$syncUps.withLock { $0.append(syncUp) }
    return .none

case .view(.didDeleteSyncUp(let id)):
    state.$syncUps.withLock { $0.remove(id: id) }
    return .none
```

### Custom File Locations

```swift
extension SharedKey where Self == FileStorageKey<AppSettings>.Default {
    static var appSettings: Self {
        Self[
            .fileStorage(.applicationSupportDirectory.appending(component: "settings.json")),
            default: AppSettings()
        ]
    }
}
```

### Requirements

- The shared type must conform to `Codable`
- Mutations are automatically persisted to disk
- File storage is asynchronous and happens in the background

## InMemoryKey for Non-Persistent Sharing

Use `InMemoryKey` for state shared across features without persistence:

```swift
// Define the shared key
extension SharedKey where Self == InMemoryKey<Stats> {
    static var stats: Self {
        inMemory("stats")
    }
}

// Use in state
@ObservableState
struct State: Equatable {
    @Shared(.stats) var stats = Stats()
}

// Mutate with .withLock
case .view(.didIncrement):
    state.$stats.withLock { $0.increment() }
    return .none
```

### When to Use InMemoryKey

- Sharing state between parallel features (tabs, split views)
- Temporary state that doesn't need persistence
- Testing with isolated in-memory state
- Performance-critical state that shouldn't hit disk

## Combining Persistence Strategies

```swift
@ObservableState
struct State: Equatable {
    @Shared(.appStorage("theme")) var theme: String = "system"  // UserDefaults
    @Shared(.syncUps) var syncUps: IdentifiedArrayOf<SyncUp>   // File storage
    @Shared(.stats) var stats = Stats()                         // In-memory
}
```
