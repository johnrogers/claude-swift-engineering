# Task Cancellation

Cooperative cancellation patterns in Swift 6.2 structured concurrency.

## Cooperative Model

Swift tasks use **cooperative cancellation**:
- Cancellation is requested, not forced
- Tasks must check for cancellation and respond
- No automatic interruption

## checkCancellation vs isCancelled

### Task.checkCancellation()
Throws `CancellationError` if cancelled. Use in throwing contexts.

```swift
func processItems(_ items: [Item]) async throws {
    for item in items {
        try Task.checkCancellation()
        await process(item)
    }
}
```

### Task.isCancelled
Returns `Bool`. Use for graceful cleanup in non-throwing contexts.

```swift
func processItems(_ items: [Item]) async {
    for item in items {
        if Task.isCancelled {
            print("Cancelled, stopping early")
            return
        }
        await process(item)
    }
}
```

## withTaskCancellationHandler

Runs cleanup when task is cancelled.

```swift
func downloadFile(url: URL) async throws -> Data {
    let download = URLSession.shared.dataTask(with: url)

    return try await withTaskCancellationHandler {
        try await download.value
    } onCancel: {
        download.cancel()
    }
}
```

## Cancellation Patterns

### Long-Running Loop
```swift
func monitorEvents() async throws {
    while !Task.isCancelled {
        let event = try await fetchNextEvent()
        try Task.checkCancellation()
        await handle(event)
    }
}
```

### TaskGroup with Cancellation
```swift
func fetchWithTimeout(ids: [String]) async throws -> [User] {
    try await withThrowingTaskGroup(of: User.self) { group in
        // Add tasks
        for id in ids {
            group.addTask {
                try await fetchUser(id: id)
            }
        }

        // Cancel all if one fails
        var users: [User] = []
        do {
            for try await user in group {
                users.append(user)
            }
        } catch {
            group.cancelAll()
            throw error
        }
        return users
    }
}
```

### Timeout Pattern
```swift
func withTimeout<T>(
    seconds: TimeInterval,
    operation: @escaping @Sendable () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try await operation()
        }

        group.addTask {
            try await Task.sleep(for: .seconds(seconds))
            throw TimeoutError()
        }

        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}
```

## Best Practices

1. **Check frequently** in loops and long operations
2. **Propagate cancellation** to child tasks
3. **Clean up resources** in cancellation handlers
4. **Don't ignore** cancellation - respond appropriately
5. **Use checkCancellation()** in throwing code for cleaner errors
