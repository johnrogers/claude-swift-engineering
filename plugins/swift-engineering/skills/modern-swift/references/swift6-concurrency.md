# Swift 6 Concurrency (Swift 6.2+)

Advanced patterns: @concurrent, nonisolated(unsafe), actor isolation.

## Progressive Journey: Start Single-Threaded

> **Apple (WWDC 2025)**: "Start by running all code on the main thread."

```
Single-Threaded → Async/Await → @concurrent → Actors
     ↓               ↓              ↓           ↓
   Start here   Hide latency   Background   Move data
                (network)      CPU work     off main
```

**When to advance:** Profile first. Add complexity only when needed.

## @concurrent Attribute (Swift 6.2+)

Forces function to **always run on background thread pool**.

```swift
@concurrent
func decodeImage(_ data: Data) async -> Image {
    // Always runs on background — good for image processing, parsing
    return processImageData(data)
}

// Usage — automatically offloads
let image = await decodeImage(data)
```

**Requirements:** Swift 6.2, Xcode 16.2+, iOS 18.2+

### Breaking Main Actor Ties

```swift
@MainActor class ImageModel {
    var cache: [URL: Image] = [:]

    @concurrent
    func decode(_ data: Data, url: URL) async -> Image {
        if let img = cache[url] { return img }  // ❌ Error: main actor access!
        return processImageData(data)
    }
}
```

**Fix: Move access to caller** (preferred):
```swift
func fetchAndDisplay(url: URL) async throws {
    if let img = cache[url] { view.displayImage(img); return }  // ✅ On main actor
    let data = try await URLSession.shared.data(from: url).0
    let image = await decode(data)  // @concurrent — no cache access needed
    view.displayImage(image)
}
```

## nonisolated vs @concurrent

| Attribute | Runs On | Use Case |
|-----------|---------|----------|
| `nonisolated` | Caller's actor | Library APIs — caller decides |
| `@concurrent` | Background pool | Always-background work |

## nonisolated(unsafe) Escape Hatch

Use when you **know** access is safe but compiler cannot prove it.

```swift
class LegacyCache {
    nonisolated(unsafe) var sharedState: [String: Data] = [:]  // ⚠️ Prove safety first
}
```

**Consider first:** Make it an `actor`, add `@MainActor`, or use `@unchecked Sendable`.

### Static Comparators Pattern

For static sorting comparators, prefer `static let` with `@Sendable` closures over `nonisolated(unsafe) static var`:

```swift
// ❌ Before: Requires nonisolated(unsafe)
extension SortableItem {
    nonisolated(unsafe) static var dateAscending: (SortableItem, SortableItem) -> Bool = { lhs, rhs in
        lhs.date < rhs.date
    }
}

// ✅ After: Use static let with @Sendable
extension SortableItem {
    static let dateAscending: @Sendable (SortableItem, SortableItem) -> Bool = { lhs, rhs in
        lhs.date < rhs.date
    }

    static let priorityDescending: @Sendable (SortableItem, SortableItem) -> Bool = { lhs, rhs in
        lhs.priority > rhs.priority
    }
}

// Usage — works with standard library sorting
let sorted = items.sorted(by: SortableItem.dateAscending)
```

**Why this works:** `static let` closures are evaluated once and immutable. Adding `@Sendable` proves they capture no mutable state.

## Actor for Main Actor Contention

```swift
// ❌ Problem: Network manager on main actor causes thread hopping
@MainActor class ImageModel {
    let network = NetworkManager()  // Also @MainActor
    func fetch(url: URL) async throws {
        let conn = await network.open(for: url)  // ❌ Hops to main
    }
}
```

```swift
// ✅ Fix: Extract to separate actor
actor NetworkManager {
    private var connections: [URL: Connection] = [:]
    func open(for url: URL) -> Connection {
        connections[url] ?? Connection()
    }
}
```

| Use Case | Solution |
|----------|----------|
| UI code, view models | `@MainActor` class |
| Non-UI subsystem | `actor` |
| Shared cache/database | `actor` |

## Delegate Value Capture Pattern

When `nonisolated` delegate needs to update `@MainActor` state:

```swift
nonisolated func delegate(_ param: SomeType) {
    let value = param.value  // Step 1: Capture BEFORE Task
    Task { @MainActor in
        self.property = value  // Step 2: Safe on MainActor
    }
}
```

## Isolated Protocol Conformances (Swift 6.2+)

```swift
protocol Exportable { func export() }

// ✅ Conform with explicit isolation
extension PhotoProcessor: @MainActor Exportable {
    func export() { exportAsPNG() }  // Safe: both on MainActor
}
```

## Sendable Strategies

| Strategy | When |
|----------|------|
| Value types (struct/enum) | Preferred — always |
| `@MainActor` class | UI-related classes |
| Finish mutations before sending | Classes modified then passed |
| `@unchecked Sendable` | Last resort — immutable classes only |

```swift
// Finish mutations before sending
@concurrent func processImage() async {
    let image = loadImage()
    image.scale(by: 0.5)  // All mutations here
    await view.displayImage(image)  // ✅ Send AFTER done
}
```

## Quick Decision Tree

```
UI unresponsive?
├─ Network/file I/O? → async/await
├─ CPU work? → @concurrent
└─ Main actor contention? → Extract to actor

"Main actor-isolated accessed from nonisolated"
├─ In delegate? → Value capture pattern
├─ In async? → @MainActor or Task { @MainActor in }
└─ In @concurrent? → Move access to caller
```
