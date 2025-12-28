# GRDB Performance

## Query Profiling

### Enable Tracing

```swift
var config = Configuration()
config.trace = { print($0) }
let dbQueue = try DatabaseQueue(path: dbPath, configuration: config)
```

### EXPLAIN QUERY PLAN

```swift
try dbQueue.read { db in
    let plan = try String.fetchOne(db, sql: """
        EXPLAIN QUERY PLAN SELECT * FROM tracks WHERE artist = ?
        """, arguments: ["Artist"])
    print(plan)
}
```

Key terms:
- **SCAN** - Full table scan (slow)
- **SEARCH** - Uses index (fast)

## Index Strategies

```swift
// Single column
try db.create(index: "idx_artist", on: "tracks", columns: ["artist"])

// Compound (multi-column queries)
try db.create(index: "idx_genre_artist", on: "tracks", columns: ["genre", "artist"])
```

### When to Index

| Scenario | Example |
|----------|---------|
| WHERE clause | `WHERE artist = ?` |
| JOIN columns | `ON tracks.albumId = albums.id` |
| ORDER BY | `ORDER BY createdAt DESC` |
| Foreign keys | `artistId`, `albumId` |

### Anti-Patterns

- Don't index booleans or low-cardinality columns
- Don't over-index small tables (<1000 rows)

## Batch Operations

### Wrong: Many Transactions

```swift
for track in tracks {
    try dbQueue.write { db in try track.insert(db) }  // Slow!
}
```

### Right: Single Transaction

```swift
try dbQueue.write { db in
    for track in tracks { try track.insert(db) }
}
```

### Prepared Statements

```swift
try dbQueue.write { db in
    let stmt = try db.makeStatement(sql: "INSERT INTO tracks VALUES (?, ?, ?)")
    for track in tracks {
        try stmt.execute(arguments: [track.id, track.title, track.artist])
    }
}
```

## Avoiding N+1 Queries

### Wrong

```swift
let tracks = try Track.fetchAll(db)
for track in tracks {
    let album = try Album.fetchOne(db, key: track.albumId)  // N queries!
}
```

### Right: Use JOIN

```swift
let sql = "SELECT tracks.*, albums.title as albumTitle FROM tracks JOIN albums ON ..."
let results = try TrackWithAlbum.fetchAll(db, sql: sql)
```

## Main Thread Safety

### Wrong

```swift
let tracks = try dbQueue.read { db in try Track.fetchAll(db) }  // Blocks UI
```

### Right: Async

```swift
Task {
    let tracks = try await dbQueue.read { db in try Track.fetchAll(db) }
}
```

## Large Datasets

```swift
// Stream instead of loading all
let cursor = try Track.fetchCursor(db)
while let track = try cursor.next() {
    process(track)
}
```

## Profiling Checklist

1. Enable `config.trace`
2. Run `EXPLAIN QUERY PLAN` on slow queries
3. Look for SCAN (add indexes)
4. Wrap batch writes in transactions
5. Check for N+1 patterns
6. Use background threads for heavy reads
