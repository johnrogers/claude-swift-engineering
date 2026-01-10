# Advanced Query Features

Database triggers, custom functions, and full-text search with FTS5.

## Database Triggers

### Temporary Triggers

Temporary triggers are created in memory and don't persist to disk:

```swift
try database.write { db in
  try RemindersList.createTemporaryTrigger(
    after: .insert { new in
      RemindersList
        .find(new.id)
        .update {
          $0.position = RemindersList.select { ($0.position.max() ?? -1) + 1 }
        }
    }
  ).execute(db)
}
```

### Auto-Increment Position

```swift
try Reminder.createTemporaryTrigger(
  after: .insert { new in
    Reminder
      .find(new.id)
      .update {
        $0.position = Reminder.select { ($0.position.max() ?? -1) + 1 }
      }
  }
).execute(db)
```

### Conditional Triggers

Execute trigger only when condition is met:

```swift
try RemindersList.createTemporaryTrigger(
  after: .delete { _ in
    Values($createDefaultRemindersList())
  } when: { _ in
    !RemindersList.exists()
  }
).execute(db)
```

### FTS5 Sync Trigger

Keep FTS5 table in sync with main table:

```swift
try Reminder.createTemporaryTrigger(
  after: .insert { new in
    ReminderText.insert {
      ReminderText.Columns(
        rowid: new.rowid,
        title: new.title,
        notes: new.notes.replace("\n", " "),
        tags: ""
      )
    }
  }
).execute(db)

try Reminder.createTemporaryTrigger(
  after: .update { new in
    ReminderText.find(new.rowid).update {
      $0.title = new.title
      $0.notes = new.notes.replace("\n", " ")
    }
  }
).execute(db)

try Reminder.createTemporaryTrigger(
  after: .delete { old in
    ReminderText.find(old.rowid).delete()
  }
).execute(db)
```

## Database Functions

### Define Custom Function

Use `@DatabaseFunction` to create Swift functions callable from SQL:

```swift
@DatabaseFunction
nonisolated func createDefaultRemindersList() {
  Task {
    @Dependency(\.defaultDatabase) var database
    try await database.write { db in
      try RemindersList.insert {
        RemindersList.Draft(
          title: RemindersList.defaultTitle,
          color: RemindersList.defaultColor
        )
      }.execute(db)
    }
  }
}
```

### Register Function

```swift
configuration.prepareDatabase { db in
  db.add(function: $createDefaultRemindersList)
  db.add(function: $handleReminderStatusUpdate)
}
```

### Use in Triggers

```swift
try RemindersList.createTemporaryTrigger(
  after: .delete { _ in
    Values($createDefaultRemindersList())
  } when: { _ in
    !RemindersList.exists()
  }
).execute(db)
```

### Async Database Function

```swift
@DatabaseFunction
nonisolated func handleReminderStatusUpdate() {
  reminderStatusMutex.withLock {
    $0?.cancel()
    $0 = Task {
      @Dependency(\.defaultDatabase) var database
      try await Task.sleep(for: .seconds(0.4))
      try await database.write { db in
        try Reminder
          .where { $0.status.eq(.completing) }
          .update { $0.status = #bind(.completed) }
          .execute(db)
      }
    }
  }
}
```

## Full-Text Search (FTS5)

### Define FTS5 Table

```swift
@Table
struct ReminderText: FTS5 {
  let rowid: Int
  let title: String
  let notes: String
  let tags: String
}
```

### Create FTS5 Virtual Table

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

### Search with FTS5

```swift
func baseQuery(searchText: String, searchTokens: [Token]) -> some Query {
  ReminderText
    .where {
      if !searchText.isEmpty || !searchTokens.isEmpty {
        $0.match(buildFTS5Query(searchText: searchText, tokens: searchTokens))
      }
    }
    .join(Reminder.all) { $0.rowid.eq($1.rowid) }
}
```

### FTS5 Highlight

Highlight matching text:

```swift
ReminderText.select {
  SearchRow.Columns(
    title: $0.title.highlight("**", "**"),
    tags: $0.tags.highlight("**", "**")
  )
}
```

### FTS5 Snippet

Extract relevant snippets with context:

```swift
ReminderText.select {
  SearchRow.Columns(
    notes: $0.notes.snippet("**", "**", "...", 64).replace("\n", " ")
  )
}
```

**Parameters:**
- First arg: Start marker for matches
- Second arg: End marker for matches
- Third arg: Ellipsis for truncated text
- Fourth arg: Maximum tokens (not characters)

### FTS5 Tokenizers

Common tokenizers:

```sql
-- Trigram (for autocomplete, partial matching)
tokenize = 'trigram'

-- Porter stemming (for word variants)
tokenize = 'porter'

-- Unicode61 (default, case-insensitive)
tokenize = 'unicode61'
```

### Complex FTS5 Queries

```swift
func buildFTS5Query(searchText: String, tokens: [Token]) -> String {
  var components: [String] = []

  if !searchText.isEmpty {
    components.append(searchText)
  }

  for token in tokens {
    switch token.kind {
    case .tag:
      components.append("\(token.rawValue)*")
    case .near:
      components.append("NEAR(\(token.rawValue), 10)")
    }
  }

  return components.joined(separator: " ")
}
```

## Best Practices

1. **Use temporary triggers** for app-specific logic (don't persist to schema)
2. **Sync FTS5 with triggers** to keep search index up-to-date
3. **Use FTS5 for search** instead of LIKE queries
4. **Use `.highlight()` and `.snippet()`** for better search UX
5. **Use trigram tokenizer** for autocomplete-style search
