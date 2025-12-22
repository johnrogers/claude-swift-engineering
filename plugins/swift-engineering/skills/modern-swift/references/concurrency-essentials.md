# Concurrency Essentials

Core patterns for async/await, @MainActor, actors, and Sendable in Swift 6.2.

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
