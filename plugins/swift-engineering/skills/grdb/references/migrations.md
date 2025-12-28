# GRDB Migrations

## DatabaseMigrator Basics

```swift
import GRDB

var migrator = DatabaseMigrator()

migrator.registerMigration("v1_initial") { db in
    try db.create(table: "tracks") { t in
        t.column("id", .text).primaryKey()
        t.column("title", .text).notNull()
        t.column("artist", .text).notNull()
        t.column("duration", .real).notNull()
    }
}

migrator.registerMigration("v2_add_genre") { db in
    try db.alter(table: "tracks") { t in
        t.add(column: "genre", .text)
    }
}

migrator.registerMigration("v3_add_indexes") { db in
    try db.create(index: "idx_tracks_genre", on: "tracks", columns: ["genre"])
}

try migrator.migrate(dbQueue)
```

## Migration Guarantees

- Each migration runs exactly ONCE
- Migrations run in registration order
- Safe to call `migrate()` multiple times
- Runs in transaction (all or nothing)

No need for `IF NOT EXISTS` - GRDB handles versioning.

## Column Types

| Swift Type | SQLite Type |
|-----------|-------------|
| String | .text |
| Int | .integer |
| Double | .real |
| Data | .blob |
| Date | .datetime |
| Bool | .boolean |

## Creating Tables

```swift
migrator.registerMigration("create_albums") { db in
    try db.create(table: "albums") { t in
        t.column("id", .text).primaryKey()
        t.column("title", .text).notNull()
        t.column("artistId", .text)
            .references("artists", onDelete: .cascade)
        t.column("createdAt", .datetime).defaults(to: Date())
    }
}
```

## Creating Indexes

```swift
// Simple index
try db.create(index: "idx_artist", on: "tracks", columns: ["artist"])

// Compound index
try db.create(index: "idx_genre_duration", on: "tracks", columns: ["genre", "duration"])

// Unique index
try db.create(index: "idx_external_id", on: "tracks", columns: ["externalId"], unique: true)
```

## Data Migrations

```swift
migrator.registerMigration("normalize_artists") { db in
    try db.create(table: "artists") { t in
        t.column("id", .text).primaryKey()
        t.column("name", .text).notNull()
    }

    try db.execute(sql: """
        INSERT INTO artists (id, name)
        SELECT DISTINCT lower(replace(artist, ' ', '_')), artist FROM tracks
        """)

    try db.alter(table: "tracks") { t in
        t.add(column: "artistId", .text).references("artists")
    }

    try db.execute(sql: """
        UPDATE tracks SET artistId = (
            SELECT id FROM artists WHERE artists.name = tracks.artist
        )
        """)
}
```

## Foreign Key Cascade Options

| Option | Behavior |
|--------|----------|
| `.cascade` | Delete children when parent deleted |
| `.setNull` | Set FK to NULL |
| `.restrict` | Prevent deletion if children exist |

## Development Mode

```swift
#if DEBUG
migrator.eraseDatabaseOnSchemaChange = true  // Wipes DB on schema change
#endif
```

## Best Practices

1. Never modify existing migrations - add new ones
2. Test with production data
3. One logical change per migration
4. Use descriptive names: `v5_add_preferences` not `migration_5`
