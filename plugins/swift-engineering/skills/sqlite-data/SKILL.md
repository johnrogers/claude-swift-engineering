---
name: sqlite-data
description: Use when working with SQLiteData library (@Table, @FetchAll, @FetchOne macros) for SQLite persistence, queries, writes, migrations, or CloudKit private database sync.
---

# SQLite Data

Patterns for using the SQLiteData library with Swift/SwiftUI.

## Quick Reference

| Reference | Load When |
|-----------|-----------|
| **[Table Models](references/models.md)** | Defining database tables with `@Table` macro, setting up primary keys, columns, or enums |
| **[Queries](references/queries.md)** | Using `@FetchAll`, `@FetchOne`, `@Fetch` property wrappers, or building queries with joins/filters |
| **[Writes](references/writes.md)** | Inserting, updating, upserting, or deleting records; managing transactions |
| **[Views](references/views.md)** | Integrating `@FetchAll`/`@FetchOne` with SwiftUI views, `@Observable` models, UIKit, or TCA `@ObservableState` |
| **[Migrations](references/migrations.md)** | Creating database migrations with DatabaseMigrator or `#sql()` macro |
| **[CloudKit Sync](references/cloudkit.md)** | Setting up CloudKit private database sync, sharing, or sync delegates |
| **[Dependencies](references/dependencies.md)** | Injecting database/sync engine via `@Dependency`, bootstrap patterns, or TCA integration |
| **[Testing](references/testing.md)** | Setting up test databases, seeding data, or writing assertions for SQLite code |
| **[Advanced](references/advanced.md)** | Implementing triggers, full-text search (FTS5), or custom database functions |
| **[Schema Composition](references/schema-composition.md)** | Using @Selection column groups, single-table inheritance, or database views |

## Core Workflow

When working with SQLiteData:
1. Define table models with `@Table` macro
2. Use `@FetchAll`/`@FetchOne` property wrappers in views or `@Observable` models
3. Access database via `@Dependency(\.defaultDatabase)`
4. Perform writes in `database.write { }` transactions
5. Set up migrations before first use
