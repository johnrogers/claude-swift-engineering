# GRDB Queries

## Raw SQL Queries

```swift
// Fetch all rows
let rows = try dbQueue.read { db in
    try Row.fetchAll(db, sql: "SELECT * FROM tracks WHERE genre = ?", arguments: ["Rock"])
}

// Access row values
for row in rows {
    let title: String = row["title"]
    let duration: Double = row["duration"]
}

// Fetch single value
let count = try dbQueue.read { db in
    try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM tracks")
}

// Write data
try dbQueue.write { db in
    try db.execute(sql: "INSERT INTO tracks (id, title) VALUES (?, ?)",
                   arguments: ["1", "Song"])
}
```

## Record Types

### Codable + PersistableRecord

```swift
struct Track: Codable, PersistableRecord {
    var id: String
    var title: String
    var artist: String

    static let databaseTableName = "tracks"
}

// Insert/Update/Delete
try dbQueue.write { db in
    try track.insert(db)
    try track.update(db)
    try track.delete(db)
}
```

### FetchableRecord (Custom Query Results)

```swift
struct TrackInfo: FetchableRecord {
    var title: String
    var albumTitle: String

    init(row: Row) {
        title = row["title"]
        albumTitle = row["album_title"]
    }
}

let results = try dbQueue.read { db in
    try TrackInfo.fetchAll(db, sql: """
        SELECT tracks.title, albums.title as album_title
        FROM tracks JOIN albums ON tracks.albumId = albums.id
        """)
}
```

## Type-Safe Query Interface

```swift
let tracks = try dbQueue.read { db in
    try Track
        .filter(Column("genre") == "Rock")
        .filter(Column("duration") > 180)
        .order(Column("title").asc)
        .limit(10)
        .fetchAll(db)
}
```

## Complex Joins (4+ Tables)

```swift
let sql = """
    SELECT
        tracks.title as track_title,
        albums.title as album_title,
        artists.name as artist_name,
        COUNT(plays.id) as play_count
    FROM tracks
    JOIN albums ON tracks.albumId = albums.id
    JOIN artists ON albums.artistId = artists.id
    LEFT JOIN plays ON plays.trackId = tracks.id
    WHERE artists.genre = ?
    GROUP BY tracks.id
    HAVING play_count > 10
    ORDER BY play_count DESC
    """

struct TrackStats: FetchableRecord {
    var trackTitle, albumTitle, artistName: String
    var playCount: Int

    init(row: Row) {
        trackTitle = row["track_title"]
        albumTitle = row["album_title"]
        artistName = row["artist_name"]
        playCount = row["play_count"]
    }
}

let stats = try dbQueue.read { db in
    try TrackStats.fetchAll(db, sql: sql, arguments: ["Rock"])
}
```

## Window Functions

```swift
let sql = """
    SELECT title, artist,
        ROW_NUMBER() OVER (PARTITION BY artist ORDER BY duration DESC) as rank,
        LAG(title) OVER (ORDER BY created_at) as previous_track
    FROM tracks
    """

struct RankedTrack: FetchableRecord {
    var title, artist: String
    var rank: Int
    var previousTrack: String?

    init(row: Row) {
        title = row["title"]
        artist = row["artist"]
        rank = row["rank"]
        previousTrack = row["previous_track"]
    }
}
```

## Transactions

```swift
try dbQueue.write { db in
    // Automatic transaction - all or nothing
    for track in tracks {
        try track.insert(db)
    }
}

// Nested with savepoints
try dbQueue.write { db in
    try db.inSavepoint {
        try riskyOperation(db)
        return .commit  // or .rollback
    }
}
```
