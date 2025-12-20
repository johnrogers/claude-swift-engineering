# Effects

Patterns for handling side effects in TCA reducers.

## Basic Effects

### .run for Async Work

```swift
case .loadData:
    state.isLoading = true
    return .run { send in
        let data = try await apiClient.fetchData()
        await send(.didLoadData(.success(data)))
    }

case .didLoadData(.success(let data)):
    state.isLoading = false
    state.data = data
    return .none
```

### .send for Synchronous Action Dispatch

```swift
case .view(.onTapSave):
    return .send(.saveData)
```

## Effect Error Handling

Use the `catch:` parameter for structured error handling:

```swift
case .loadItem(let id):
    return .run { send in
        let item = try await apiClient.fetchItem(id)
        await send(.itemLoaded(item))
    } catch: { error, send in
        await send(.loadFailed(error))
    }
```

For non-critical errors where you want to log but not surface to user:

```swift
case .syncData:
    return .run { send in
        try await syncClient.sync()
        await send(.syncCompleted)
    } catch: { error, _ in
        reportIssue(error)
    }
```

## Effect Composition

### .concatenate for Sequential Effects

```swift
case .onAppear:
    return .concatenate(
        .send(.loadData),
        .send(.trackAnalytics)
    )
```

### .merge for Concurrent Effects

```swift
case .onSave:
    return .merge(
        .send(.delegate(.didSave)),
        .run { _ in await dismiss() }
    )
```

## Cancellation

### .cancellable for Long-Running Effects

```swift
case .startStreaming:
    return .run { send in
        for try await data in client.stream() {
            await send(.didReceiveData(data))
        }
    }
    .cancellable(id: "data-stream", cancelInFlight: true)

case .stopStreaming:
    return .cancel(id: "data-stream")
```

## View Lifecycle Effects

For effects that should run for the view's lifetime, use `.runTasks` with `.finish()`:

```swift
// In Reducer
@CasePathable
enum View {
    case runTasks
    case onAppear
}

case .view(.runTasks):
    return .run { send in
        for await status in statusClient.stream() {
            await send(.statusChanged(status))
        }
    }
    // No .cancellable() needed - .task handles auto-cancellation

case .view(.onAppear):
    return .run { send in
        let data = try await loadInitialData()
        await send(.dataLoaded(data))
    }
```

```swift
// In View
var body: some View {
    List { /* ... */ }
        .task {
            await send(.runTasks).finish()  // Keeps alive until view disappears
        }
        .onAppear {
            send(.onAppear)  // Immediate one-time work
        }
}
```

**When to Use `.runTasks`:**
- Streaming effects (status monitors, real-time updates)
- Effects that should run for entire view lifetime
- Replaces `.onAppear` + `.onDisappear` + `.cancellable()` patterns

## Timer Effects

### Basic Timer with Clock Dependency

```swift
@Dependency(\.continuousClock) var clock
private enum CancelID { case timer }

case .toggleTimerButtonTapped:
    state.isTimerActive.toggle()
    return .run { [isTimerActive = state.isTimerActive] send in
        guard isTimerActive else { return }
        for await _ in self.clock.timer(interval: .seconds(1)) {
            await send(.timerTick)
        }
    }
    .cancellable(id: CancelID.timer, cancelInFlight: true)

case .timerTick:
    state.secondsElapsed += 1
    return .none
```

### Animated Timer Updates

```swift
case .toggleTimerButtonTapped:
    state.isTimerActive.toggle()
    return .run { [isTimerActive = state.isTimerActive] send in
        guard isTimerActive else { return }
        for await _ in self.clock.timer(interval: .seconds(1)) {
            await send(.timerTick, animation: .default)
        }
    }
    .cancellable(id: CancelID.timer, cancelInFlight: true)
```

### Timer with Duration and Completion

```swift
case .startCountdown:
    state.timeRemaining = 60
    return .run { send in
        for await _ in self.clock.timer(interval: .seconds(1)) {
            await send(.timerTick)
        }
    }
    .cancellable(id: CancelID.timer)

case .timerTick:
    state.timeRemaining -= 1
    if state.timeRemaining <= 0 {
        return .concatenate(
            .cancel(id: CancelID.timer),
            .send(.timerCompleted)
        )
    }
    return .none
```

## Capturing State in Effects

### Capturing for Async Work

```swift
case .numberFactButtonTapped:
    state.isLoading = true
    return .run { [count = state.count] send in
        let fact = try await factClient.fetch(count)
        await send(.numberFactResponse(.success(fact)))
    }
```

### Capturing Multiple Values

```swift
case .searchTextChanged(let text):
    state.searchText = text
    return .run { [text, filter = state.filter, sortOrder = state.sortOrder] send in
        try await Task.sleep(for: .milliseconds(300))
        let results = try await searchClient.search(
            text: text,
            filter: filter,
            sortOrder: sortOrder
        )
        await send(.searchResults(results))
    }
    .cancellable(id: CancelID.search, cancelInFlight: true)
```

### Capturing for Conditionals

```swift
case .loadData:
    return .run { [isOfflineMode = state.isOfflineMode] send in
        if isOfflineMode {
            let data = await cacheClient.loadFromCache()
            await send(.dataLoaded(data))
        } else {
            let data = try await apiClient.fetchData()
            await send(.dataLoaded(data))
        }
    }
```
