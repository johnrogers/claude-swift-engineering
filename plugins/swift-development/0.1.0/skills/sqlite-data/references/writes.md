# Database Writes

Patterns for inserting, updating, upserting, and deleting records.

## Insert Operations

### Single Insert

```swift
try database.write { db in
  try Counter.insert {
    Counter.Draft()
  }.execute(db)
}
```

### Insert with Values

```swift
try database.write { db in
  try Fact.insert {
    Fact.Draft(body: "An interesting fact")
  }.execute(db)
}
```

### Batch Insert

```swift
try database.write { db in
  try Attendee.insert {
    for attendee in attendees {
      Attendee.Draft(
        id: attendee.id,
        name: attendee.name,
        syncUpID: syncUpID
      )
    }
  }.execute(db)
}
```

### Insert with Return Value

```swift
try database.write { db in
  let reminderID = try Reminder.insert {
    Reminder.Draft(
      title: "Buy groceries",
      remindersListID: listID
    )
  }
  .returning(\.id)
  .fetchOne(db)!
}
```

## Update Operations

### Simple Update

```swift
try database.write { db in
  try Counter.find(counter.id).update {
    $0.count += 1
  }.execute(db)
}
```

### Update with Multiple Fields

```swift
try database.write { db in
  try Reminder.find(reminderID).update {
    $0.title = "Updated title"
    $0.dueDate = Date()
    $0.priority = .high
  }.execute(db)
}
```

### Batch Update with Filter

```swift
try database.write { db in
  try Reminder
    .where { $0.remindersListID.eq(listID) }
    .update {
      $0.position += 1
    }
    .execute(db)
}
```

### Update with Case Expression

For conditional updates, use `Case().when().else()`:

```swift
extension Updates<Reminder> {
  mutating func toggleStatus() {
    self.status = Case(self.status)
      .when(#bind(.incomplete), then: #bind(.completing))
      .else(#bind(.incomplete))
  }
}

// Usage:
try database.write { db in
  try Reminder.find(id).update {
    $0.toggleStatus()
  }.execute(db)
}
```

### Batch Position Update

```swift
try database.write { db in
  let ids = [
    (element: UUID(), offset: 0),
    (element: UUID(), offset: 1),
    (element: UUID(), offset: 2)
  ]
  let (first, rest) = (ids.first!, ids.dropFirst())

  try RemindersList.update {
    $0.position = rest.reduce(
      Case($0.id).when(first.element, then: first.offset)
    ) { cases, id in
      cases.when(id.element, then: id.offset)
    }
    .else($0.position)
  }.execute(db)
}
```

## Upsert Operations

Insert a record or update if it already exists:

```swift
try database.write { db in
  let syncUpID = try SyncUp.upsert { syncUp }
    .returning(\.id)
    .fetchOne(db)!
}
```

### Upsert with Optional Return

```swift
try database.write { db in
  let remindersListID = try RemindersList
    .upsert { remindersList }
    .returning(\.id)
    .fetchOne(db)

  guard let remindersListID else { return }

  // Continue with dependent operations
}
```

### Upsert Pattern for Updates

Common pattern: upsert main record, then replace child records:

```swift
try database.write { db in
  // Upsert parent
  let syncUpID = try SyncUp.upsert { syncUp }.returning(\.id).fetchOne(db)!

  // Delete existing children
  try Attendee.where { $0.syncUpID == syncUpID }.delete().execute(db)

  // Insert new children
  try Attendee.insert {
    for attendee in attendees {
      Attendee.Draft(
        id: attendee.id,
        name: attendee.name,
        syncUpID: syncUpID
      )
    }
  }.execute(db)
}
```

## Delete Operations

### Delete by ID

```swift
try database.write { db in
  try Counter.find(counterID).delete().execute(db)
}
```

### Delete Multiple Records

```swift
try database.write { db in
  for index in indexSet {
    try Counter.find(counters[index].id).delete().execute(db)
  }
}
```

### Delete with Filter

```swift
try database.write { db in
  try Tag
    .where { $0.title.in(tagTitles) }
    .delete()
    .execute(db)
}
```

### Delete by ID Array

```swift
try database.write { db in
  let ids = indices.map { facts[$0].id }
  try Fact
    .where { $0.id.in(ids) }
    .delete()
    .execute(db)
}
```

### Conditional Delete

```swift
try database.write { db in
  try Reminder
    .where { $0.status.eq(.completed) && $0.completedDate.lt(cutoffDate) }
    .delete()
    .execute(db)
}
```

## Error Handling

Wrap database writes with error reporting:

```swift
withErrorReporting {
  try database.write { db in
    // Write operations
  }
}
```

For async context:

```swift
await withErrorReporting {
  try await database.write { db in
    // Write operations
  }
}
```

## Transaction Guarantees

All operations within `database.write { }` execute in a single transaction:

```swift
try database.write { db in
  // These all succeed or all fail together
  try Counter.insert { Counter.Draft() }.execute(db)
  try Counter.find(otherID).delete().execute(db)
  try Counter.find(thirdID).update { $0.count = 0 }.execute(db)
}
```
