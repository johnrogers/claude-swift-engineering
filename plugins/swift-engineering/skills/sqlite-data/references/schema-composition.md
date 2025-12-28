# Schema Composition

Patterns for reusable column groups, single-table inheritance, and database views.

## @Selection Column Groups

Group related columns into reusable types:

```swift
@Selection
struct Timestamps {
    let createdAt: Date
    let updatedAt: Date?
}

@Table
nonisolated struct RemindersList: Identifiable {
    let id: UUID
    var title = ""
    let timestamps: Timestamps  // Embedded column group
}
```

**SQL flattens all groups** - no nested structure in database:

```sql
CREATE TABLE "remindersLists" (
    "id" TEXT PRIMARY KEY NOT NULL DEFAULT (uuid()),
    "title" TEXT NOT NULL DEFAULT '',
    "createdAt" TEXT NOT NULL,
    "updatedAt" TEXT
) STRICT
```

### Querying Column Groups

```swift
// Access fields with dot syntax
RemindersList.where { $0.timestamps.createdAt <= cutoffDate }.fetchAll(db)

// Nest groups in @Selection results
@Selection
struct Row {
    let reminderTitle: String
    let timestamps: Timestamps
}

Reminder.join(RemindersList.all) { $0.remindersListID.eq($1.id) }
    .select { Row.Columns(reminderTitle: $0.title, timestamps: $0.timestamps) }
```

## Single-Table Inheritance

Model polymorphic data using `@CasePathable @Selection` enums:

```swift
import CasePaths

@Table
nonisolated struct Attachment: Identifiable {
    let id: UUID
    let kind: Kind

    @CasePathable @Selection
    enum Kind {
        case link(URL)
        case note(String)
        case image(URL)
    }
}
```

**SQL flattens all cases into nullable columns:**

```sql
CREATE TABLE "attachments" (
    "id" TEXT PRIMARY KEY NOT NULL DEFAULT (uuid()),
    "link" TEXT, "note" TEXT, "image" TEXT
) STRICT
```

### Querying Enum Tables

```swift
// Filter by case
let images = try Attachment.where { $0.kind.image.isNot(nil) }.fetchAll(db)

// Insert with specific case
try Attachment.insert { Attachment.Draft(kind: .note("Hello!")) }.execute(db)
// Inserts: (id, NULL, 'Hello!', NULL)

// Update changes which columns are populated
try Attachment.find(id).update {
    $0.kind = .link(URL(string: "https://example.com")!)
}.execute(db)
// Sets link, NULLs note and image
```

## Database Views

Create temporary views for complex queries using `@Table @Selection`:

```swift
@Table @Selection
private struct ReminderWithList {
    let reminderTitle: String
    let remindersListTitle: String
}

try database.write { db in
    try ReminderWithList.createTemporaryView(
        as: Reminder
            .join(RemindersList.all) { $0.remindersListID.eq($1.id) }
            .select {
                ReminderWithList.Columns(
                    reminderTitle: $0.title,
                    remindersListTitle: $1.title
                )
            }
    ).execute(db)
}

// Query like any table - join complexity hidden
let results = try ReminderWithList
    .order { ($0.remindersListTitle, $0.reminderTitle) }
    .fetchAll(db)
```

### Updatable Views

Enable inserts/updates with `INSTEAD OF` triggers:

```swift
try ReminderWithList.createTemporaryTrigger(
    insteadOf: .insert { new in
        Reminder.insert { ($0.title, $0.remindersListID) }
            values: { (new.reminderTitle, RemindersList.select(\.id)
                .where { $0.title.eq(new.remindersListTitle) }) }
    }
).execute(db)
```

## When to Use Each Pattern

| Pattern | Use Case |
|---------|----------|
| `@Selection` groups | Reuse timestamp/audit columns across tables |
| `@CasePathable` enum | Polymorphic types (attachments, content blocks) |
| `@Table @Selection` view | Hide join complexity, create reusable queries |
| Temporary view | Query varies by runtime |
| Permanent view | Query used across restarts, rarely changes |
