---
name: grdb
description: Use when writing raw SQL with GRDB, complex joins across 4+ tables, window functions, ValueObservation for reactive queries, or dropping down from SQLiteData for performance. Direct SQLite access for iOS/macOS with type-safe queries and migrations.
---

# GRDB

Direct SQLite access using [GRDB.swift](https://github.com/groue/GRDB.swift) - type-safe Swift wrapper with full SQLite power when you need it.

## Quick Reference

| Reference | Load When |
|-----------|-----------|
| **[Getting Started](references/getting-started.md)** | Setting up DatabaseQueue or DatabasePool |
| **[Queries](references/queries.md)** | Writing raw SQL, Record types, type-safe queries |
| **[Value Observation](references/value-observation.md)** | Reactive queries, SwiftUI integration |
| **[Migrations](references/migrations.md)** | DatabaseMigrator, schema evolution |
| **[Performance](references/performance.md)** | EXPLAIN QUERY PLAN, indexing, profiling |

## When to Use GRDB vs SQLiteData

| Scenario | Use |
|----------|-----|
| Type-safe @Table models | SQLiteData |
| CloudKit sync needed | SQLiteData |
| Complex joins (4+ tables) | GRDB |
| Window functions (ROW_NUMBER, RANK) | GRDB |
| Performance-critical raw SQL | GRDB |
| Reactive queries (ValueObservation) | GRDB |

## Core Workflow

1. Choose DatabaseQueue (single connection) or DatabasePool (concurrent reads)
2. Define migrations with DatabaseMigrator
3. Create Record types (Codable, FetchableRecord, PersistableRecord)
4. Write queries with raw SQL or QueryInterface
5. Use ValueObservation for reactive updates

## Requirements

- iOS 13+, macOS 10.15+
- Swift 5.7+
- GRDB.swift 6.0+

## Common Mistakes

1. **Performance assumptions without EXPLAIN PLAN** — Assuming your query is fast or slow without checking `EXPLAIN QUERY PLAN` is guessing. Always profile queries with EXPLAIN before optimizing.

2. **Missing indexes on WHERE clauses** — Queries filtering on non-indexed columns scan the entire table. Index any column used in WHERE, JOIN, or ORDER BY clauses for large tables.

3. **Improper migration ordering** — Running migrations out of order or skipping intermediate versions breaks schema consistency. Always apply migrations sequentially; never jump versions.

4. **Record conformance shortcuts** — Not conforming Record types to `PersistableRecord` or `FetchableRecord` correctly leads to silent data loss or deserialization failures. Always implement all required protocols correctly.

5. **ValueObservation without proper cleanup** — Forgetting to cancel ValueObservation when views disappear causes memory leaks and stale data subscriptions. Store the cancellable and clean up in deinit.
