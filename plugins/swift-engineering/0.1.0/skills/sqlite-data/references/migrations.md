# Database Migrations

Patterns for managing database schema with `DatabaseMigrator`.

## Migration Strategy

**IMPORTANT:** Before creating database migrations, clarify the app's development stage with the user.

### During Active Development (Pre-Release)

If the app has not been released to users yet:
- **Do NOT create new migration files** for schema changes
- Instead, **update existing migrations in place**
- Ask the user: "This app appears to be in development. Should I update the existing migration, or create a new one?"

### After Release (Production)

Once an app is released:
- **Always create new migration files** for schema changes
- Never modify existing migrations (users have data in the old schema)
- Migrations must be additive and backwards-compatible

### Clarifying Question

When schema changes are needed, ask:

> "Is this app already released to users, or still in development?
> - **In development** — I'll update the existing schema directly
> - **Released** — I'll create a new migration to preserve user data"

## Basic Migration Setup

```swift
var migrator = DatabaseMigrator()

#if DEBUG
  migrator.eraseDatabaseOnSchemaChange = true
#endif

migrator.registerMigration("Create initial tables") { db in
  try #sql(
    """
    CREATE TABLE "counters" (
      "id" TEXT PRIMARY KEY NOT NULL,
      "count" INTEGER NOT NULL DEFAULT 0
    ) STRICT
    """
  ).execute(db)
}

try migrator.migrate(database)
```

## Using #sql() Macro

The `#sql()` macro provides type-safe SQL with interpolation:

```swift
migrator.registerMigration("Create users table") { db in
  try #sql(
    """
    CREATE TABLE "users" (
      "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
      "name" TEXT NOT NULL,
      "createdAt" TEXT NOT NULL
    ) STRICT
    """
  ).execute(db)
}
```

### With Dynamic Values

```swift
migrator.registerMigration("Create remindersLists table") { db in
  let defaultListColor = Color.HexRepresentation(
    queryOutput: RemindersList.defaultColor
  ).hexValue

  try #sql(
    """
    CREATE TABLE "remindersLists" (
      "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
      "color" INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT \(raw: defaultListColor ?? 0),
      "title" TEXT NOT NULL ON CONFLICT REPLACE DEFAULT ''
    ) STRICT
    """
  ).execute(db)
}
```

## STRICT Tables

Use `STRICT` mode for type safety:

```swift
CREATE TABLE "items" (
  "id" TEXT PRIMARY KEY NOT NULL,
  "count" INTEGER NOT NULL,
  "name" TEXT NOT NULL
) STRICT
```

## Foreign Key Constraints

Define foreign keys with cascading deletes:

```swift
migrator.registerMigration("Create attendees table") { db in
  try #sql(
    """
    CREATE TABLE "attendees" (
      "id" TEXT PRIMARY KEY NOT NULL,
      "name" TEXT NOT NULL,
      "syncUpID" TEXT NOT NULL REFERENCES "syncUps"("id") ON DELETE CASCADE
    ) STRICT
    """
  ).execute(db)
}
```

## Multiple Migrations

Register multiple migrations in sequence:

```swift
migrator.registerMigration("Create initial tables") { db in
  // Create tables
}

migrator.registerMigration("Create foreign key indexes") { db in
  try #sql(
    """
    CREATE INDEX IF NOT EXISTS "idx_reminders_remindersListID"
    ON "reminders"("remindersListID")
    """
  ).execute(db)

  try #sql(
    """
    CREATE INDEX IF NOT EXISTS "idx_remindersTags_reminderID"
    ON "remindersTags"("reminderID")
    """
  ).execute(db)
}

try migrator.migrate(database)
```

## FTS5 Virtual Tables

Create full-text search tables:

```swift
migrator.registerMigration("Create FTS5 table") { db in
  try #sql(
    """
    CREATE VIRTUAL TABLE "reminderTexts" USING fts5(
      "title",
      "notes",
      "tags",
      tokenize = 'trigram'
    )
    """
  ).execute(db)
}
```

## Common Column Patterns

### UUID Primary Key

```swift
"id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid())
```

### Auto-increment Integer

```swift
"id" INTEGER PRIMARY KEY AUTOINCREMENT
```

### Timestamps

```swift
"createdAt" TEXT NOT NULL
"updatedAt" TEXT
```

### Booleans

```swift
"isFlagged" INTEGER NOT NULL ON CONFLICT REPLACE DEFAULT 0
```

### Enums

```swift
"status" INTEGER NOT NULL DEFAULT 0
"priority" INTEGER
```

### Foreign Keys with Cascade

```swift
"remindersListID" TEXT NOT NULL REFERENCES "remindersLists"("id") ON DELETE CASCADE
```

### Nullable Fields

```swift
"dueDate" TEXT
"notes" TEXT
"coverImage" BLOB
```

### Case-Insensitive Text

```swift
"title" TEXT COLLATE NOCASE PRIMARY KEY NOT NULL
```

## Database Configuration

Enable foreign keys and prepare the database:

```swift
var configuration = Configuration()
configuration.foreignKeysEnabled = true
configuration.prepareDatabase { db in
  try db.attachMetadatabase()  // For CloudKit sync
  db.add(function: $myCustomFunction)
}

let database = try SQLiteData.defaultDatabase(configuration: configuration)
```

## Debug Tracing

Enable query tracing in DEBUG builds:

```swift
configuration.prepareDatabase { db in
  #if DEBUG
    db.trace(options: .profile) {
      logger.debug("\($0.expandedDescription)")
    }
  #endif
}
```

## Erase on Schema Change

During development, automatically recreate the database when schema changes:

```swift
#if DEBUG
  migrator.eraseDatabaseOnSchemaChange = true
#endif
```

**Warning:** This deletes all data. Only use during active development.
