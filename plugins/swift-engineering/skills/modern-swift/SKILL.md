---
description: Swift 6.2 concurrency essentials — async/await, actors, @MainActor, Sendable
---

# Modern Swift Concurrency (Swift 6.2+)

Critical patterns for Swift 6.2 strict concurrency checking. **Always use these patterns** — avoid deprecated alternatives.

## Async/Await — NOT Completion Handlers

### ✅ Modern Pattern
```swift
func fetchUser(id: String) async throws -> User {
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(User.self, from: data)
}

// Calling async functions
Task {
    let user = try await fetchUser(id: "123")
}
```

### ❌ Deprecated Pattern
```swift
// NEVER use completion handlers
func fetchUser(id: String, completion: @escaping (Result<User, Error>) -> Void) {
    URLSession.shared.dataTask(with: url) { data, _, error in
        // ...
    }.resume()
}
```

## @MainActor — NOT DispatchQueue.main

### ✅ Modern Pattern
```swift
@MainActor
class ViewModel: ObservableObject {
    var items: [Item] = []

    func loadItems() async {
        // Already on main actor — UI updates are safe
        items = try await fetchItems()
    }
}

// Or for individual properties
class Service {
    @MainActor var uiState: UIState = .idle
}
```

### ❌ Deprecated Pattern
```swift
// NEVER use DispatchQueue.main.async
DispatchQueue.main.async {
    self.items = newItems
}
```

## Actor Isolation — NOT Locks

### ✅ Modern Pattern
```swift
actor DatabaseManager {
    private var cache: [String: Data] = [:]

    func getData(key: String) -> Data? {
        cache[key]
    }

    func setData(_ data: Data, key: String) {
        cache[key] = data
    }
}

// Usage
let data = await database.getData(key: "user")
```

### ❌ Deprecated Pattern
```swift
// NEVER use locks or serial queues
class DatabaseManager {
    private let queue = DispatchQueue(label: "db")
    private var cache: [String: Data] = [:]

    func getData(key: String) -> Data? {
        queue.sync { cache[key] }
    }
}
```

## Sendable — Thread-Safe Types

### ✅ Conforming to Sendable
```swift
// Value types are implicitly Sendable
struct User: Sendable {
    let id: String
    let name: String
}

// Actors are implicitly Sendable
actor UserCache { }

// Classes require @unchecked Sendable (use sparingly)
final class ImmutableConfig: @unchecked Sendable {
    let apiKey: String
    let baseURL: URL

    init(apiKey: String, baseURL: URL) {
        self.apiKey = apiKey
        self.baseURL = baseURL
    }
}
```

### ❌ Common Errors
```swift
// ERROR: Non-Sendable type crossing actor boundary
class MutableState { var count = 0 }

actor Counter {
    // ❌ MutableState is not Sendable
    func update(state: MutableState) { }
}
```

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

## Quick Reference

| Need | Use | NOT |
|------|-----|-----|
| Async operation | `async/await` | Completion handlers |
| Main thread work | `@MainActor` | `DispatchQueue.main` |
| Shared mutable state | `actor` | Locks, serial queues |
| Parallel tasks | `TaskGroup` | `DispatchGroup` |
| Thread safety | `Sendable` | `@unchecked` everywhere |

## Common Patterns

### Network Request
```swift
func loadData() async throws -> Data {
    try await URLSession.shared.data(from: url).0
}
```

### Background Work + UI Update
```swift
@MainActor
func refresh() async {
    let data = await Task.detached {
        // Heavy computation off main actor
        await processData()
    }.value

    // Back on main actor automatically
    self.items = data
}
```

### Cancellation
```swift
func longRunningTask() async throws {
    for item in items {
        try Task.checkCancellation()
        await process(item)
    }
}
```

## Swift 6.2 Strict Concurrency

When strict concurrency is enabled, the compiler enforces:
- No data races at compile time
- Sendable conformance for cross-actor types
- Proper isolation boundaries

**Always enable strict concurrency:**
```swift
// Package.swift
.target(
    name: "MyTarget",
    swiftSettings: [
        .enableUpcomingFeature("StrictConcurrency")
    ]
)
```
