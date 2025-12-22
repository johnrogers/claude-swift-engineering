# Task Groups & Structured Concurrency

Patterns for parallel execution with TaskGroup and async-let in Swift 6.2.

## TaskGroup — Structured Concurrency

### ✅ Modern Pattern
```swift
func fetchAllUsers(ids: [String]) async throws -> [User] {
    try await withThrowingTaskGroup(of: User.self) { group in
        for id in ids {
            group.addTask {
                try await fetchUser(id: id)
            }
        }

        var users: [User] = []
        for try await user in group {
            users.append(user)
        }
        return users
    }
}
```

### ❌ Deprecated Pattern
```swift
// NEVER use DispatchGroup
let group = DispatchGroup()
var users: [User] = []

for id in ids {
    group.enter()
    fetchUserOldStyle(id: id) { user in
        users.append(user)
        group.leave()
    }
}
```

## async-let — Fixed Parallel Tasks

Use when you know the exact number of parallel operations at compile time.

```swift
func loadDashboard() async throws -> Dashboard {
    async let user = fetchUser()
    async let posts = fetchPosts()
    async let stats = fetchStats()

    return try await Dashboard(
        user: user,
        posts: posts,
        stats: stats
    )
}
```

## TaskGroup Patterns

### Collecting Results in Order
```swift
func fetchInOrder(ids: [String]) async throws -> [User] {
    try await withThrowingTaskGroup(of: (Int, User).self) { group in
        for (index, id) in ids.enumerated() {
            group.addTask {
                (index, try await fetchUser(id: id))
            }
        }

        var results = [(Int, User)]()
        for try await result in group {
            results.append(result)
        }

        return results.sorted { $0.0 < $1.0 }.map(\.1)
    }
}
```

### Limited Parallelism
```swift
func processBatch(_ items: [Item]) async throws {
    try await withThrowingTaskGroup(of: Void.self) { group in
        var iterator = items.makeIterator()

        // Start initial batch of 5
        for _ in 0..<5 {
            if let item = iterator.next() {
                group.addTask { try await process(item) }
            }
        }

        // As tasks complete, start new ones
        while let item = iterator.next() {
            try await group.next()
            group.addTask { try await process(item) }
        }

        try await group.waitForAll()
    }
}
```

### Early Exit on Error
```swift
func fetchUntilError(ids: [String]) async throws -> [User] {
    try await withThrowingTaskGroup(of: User.self) { group in
        for id in ids {
            group.addTask { try await fetchUser(id: id) }
        }

        var users: [User] = []
        // First error throws and cancels remaining tasks
        for try await user in group {
            users.append(user)
        }
        return users
    }
}
```
