# Advanced Optimization & Aggregation

Performance optimization, custom aggregates, JSON aggregation, and self-joins.

## Performance Optimization

### Indexes on Foreign Keys

```swift
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
```

### Query Profiling

Enable in DEBUG builds:

```swift
#if DEBUG
  configuration.prepareDatabase { db in
    db.trace(options: .profile) {
      logger.debug("\($0.expandedDescription)")
    }
  }
#endif
```

### Batch Operations

Perform multiple operations in single transaction:

```swift
try database.write { db in
  // All succeed or all fail together
  try Counter.insert { Counter.Draft() }.execute(db)
  try Counter.find(otherID).delete().execute(db)
  try Counter.find(thirdID).update { $0.count = 0 }.execute(db)
}
```

## Custom Aggregate Functions

Define complex aggregation logic in Swift with `@DatabaseFunction`:

```swift
@DatabaseFunction
func mode(priority priorities: some Sequence<Reminder.Priority?>) -> Reminder.Priority? {
    var occurrences: [Reminder.Priority: Int] = [:]
    for priority in priorities {
        guard let priority else { continue }
        occurrences[priority, default: 0] += 1
    }
    return occurrences.max { $0.value < $1.value }?.key
}

// Register in configuration
configuration.prepareDatabase { db in
    db.add(function: $mode)
}

// Use in queries
let results = try RemindersList
    .group(by: \.id)
    .leftJoin(Reminder.all) { $0.id.eq($1.remindersListID) }
    .select { ($0.title, $mode(priority: $1.priority)) }
    .fetchAll(db)
```

## JSON Aggregation

Build JSON arrays directly in queries:

```swift
// Aggregate rows into JSON array
let storesWithItems = try Store
    .group(by: \.id)
    .leftJoin(Item.all) { $0.id.eq($1.storeID) }
    .select {
        (
            $0.name,
            $1.title.jsonGroupArray()  // ["item1", "item2", ...]
        )
    }
    .fetchAll(db)

// With filtering
let activeItemsJson = try Store
    .group(by: \.id)
    .leftJoin(Item.all) { $0.id.eq($1.storeID) }
    .select {
        $1.title.jsonGroupArray(filter: $1.isActive)
    }
    .fetchAll(db)
```

## String Aggregation

Concatenate values from multiple rows:

```swift
let itemsWithTags = try Item
    .group(by: \.id)
    .leftJoin(ItemTag.all) { $0.id.eq($1.itemID) }
    .leftJoin(Tag.all) { $1.tagID.eq($2.id) }
    .select {
        (
            $0.title,
            $2.name.groupConcat(separator: ", ")
        )
    }
    .fetchAll(db)
// ("iPhone", "electronics, mobile, apple")
```

## Self-Joins with TableAlias

Query the same table twice (e.g., employee/manager):

```swift
struct ManagerAlias: TableAlias {
    typealias Table = Employee
}

let employeesWithManagers = try Employee
    .leftJoin(Employee.all.as(ManagerAlias.self)) { $0.managerID.eq($1.id) }
    .select {
        (
            employeeName: $0.name,
            managerName: $1.name
        )
    }
    .fetchAll(db)

// Find employees who manage others
let managers = try Employee
    .join(Employee.all.as(ManagerAlias.self)) { $0.id.eq($1.managerID) }
    .select { $0 }
    .distinct()
    .fetchAll(db)
```

## Best Practices

1. **Add foreign key indexes** for better join performance
2. **Profile queries in DEBUG** to identify slow operations
3. **Batch operations** in single transaction for consistency
4. **Use custom aggregates** for mode, median, or complex statistics
5. **Use TableAlias** for self-referential joins (org charts, trees)
