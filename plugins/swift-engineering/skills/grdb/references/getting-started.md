# Getting Started with GRDB

## Installation

Add GRDB to your Swift Package Manager dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/groue/GRDB.swift", from: "6.0.0")
]
```

## DatabaseQueue (Single Connection)

Use DatabaseQueue for most apps - simpler and sufficient for typical usage patterns.

```swift
import GRDB

// File-based database
let dbPath = NSSearchPathForDirectoriesInDomains(
    .documentDirectory, .userDomainMask, true
)[0]
let dbQueue = try DatabaseQueue(path: "\(dbPath)/app.sqlite")

// In-memory database (useful for tests)
let dbQueue = try DatabaseQueue()
```

### Basic Read/Write Pattern

```swift
// Reading data
let tracks = try dbQueue.read { db in
    try Track.fetchAll(db)
}

// Writing data
try dbQueue.write { db in
    try track.insert(db)
}
```

## DatabasePool (Connection Pool)

Use DatabasePool for apps with heavy concurrent access - allows concurrent reads while writing.

```swift
import GRDB

let dbPool = try DatabasePool(path: "\(dbPath)/app.sqlite")

// Concurrent reads
let result1 = try dbPool.read { db in try Track.fetchAll(db) }
let result2 = try dbPool.read { db in try Album.fetchAll(db) }

// Exclusive writes
try dbPool.write { db in
    try track.insert(db)
}
```

### When to Use Each

| Use Case | Choice |
|----------|--------|
| Most apps | DatabaseQueue |
| Heavy concurrent writes from multiple threads | DatabasePool |
| Unit tests | DatabaseQueue (in-memory) |
| Background sync with UI updates | DatabasePool |

## Database Configuration

```swift
var config = Configuration()

// Enable tracing for debugging
config.trace = { print($0) }

// Enable foreign key support
config.prepareDatabase { db in
    try db.execute(sql: "PRAGMA foreign_keys = ON")
}

let dbQueue = try DatabaseQueue(path: dbPath, configuration: config)
```

## Async/Await Support

```swift
// Async read
let tracks = try await dbQueue.read { db in
    try Track.fetchAll(db)
}

// Async write
try await dbQueue.write { db in
    try track.insert(db)
}
```

## App Lifecycle Pattern

```swift
final class DatabaseManager {
    static let shared = DatabaseManager()

    let dbQueue: DatabaseQueue

    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        )[0] + "/app.sqlite"

        do {
            var migrator = DatabaseMigrator()
            // Register migrations...

            dbQueue = try DatabaseQueue(path: path)
            try migrator.migrate(dbQueue)
        } catch {
            fatalError("Database setup failed: \(error)")
        }
    }
}
```

## Dropping Down from SQLiteData

When using SQLiteData but need GRDB for specific operations:

```swift
import SQLiteData
import GRDB

@Dependency(\.database) var database  // SQLiteData Database

// Access underlying GRDB DatabaseQueue
try await database.database.write { db in
    // Full GRDB power here
    try db.execute(sql: "CREATE INDEX idx_genre ON tracks(genre)")
}
```

Common scenarios for dropping down:
- Complex JOIN queries across 4+ tables
- Window functions (ROW_NUMBER, RANK, LAG/LEAD)
- Custom migrations with data transforms
- Bulk SQL operations
- ValueObservation setup
