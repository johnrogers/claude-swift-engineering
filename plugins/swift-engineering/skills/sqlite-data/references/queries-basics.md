# Query Basics

Patterns for fetching data using `@FetchAll`, `@FetchOne`, and `@Selection`.

## When to Use Which

| Wrapper | Use For | Example |
|---------|---------|---------|
| `@FetchAll` | Inline queries returning **multiple records** | `@FetchAll(Item.order { $0.createdAt.desc() }) var items` |
| `@FetchOne` | Inline queries returning **single record or aggregate** | `@FetchOne(Item.where { $0.isActive }) var activeItem` |
| `@Fetch` | **FetchKeyRequest only** - when you need data transformation | `@Fetch(ComplexRequest()) var result` |

**Common mistake**: Using `@Fetch` for simple queries. It requires `FetchKeyRequest` conformance.

Only create a `FetchKeyRequest` struct when you need to:
- Transform data with `.map()` after fetching
- Perform multiple database operations in one transaction
- Return a custom result type that differs from the raw query

For simple ordering, filtering, or joins without transformation → use `@FetchAll` or `@FetchOne`.

## @FetchAll - Multiple Records

Fetch multiple records with automatic SwiftUI updates:

```swift
@Observable
class CountersListModel {
  @ObservationIgnored
  @FetchAll var counters: [Counter]
}
```

### With Query Ordering

```swift
@FetchAll(
  Counter.order(by: \.id),
  animation: .default
)
var counters
```

### With Filtering

```swift
@FetchAll(
  Reminder.where { !$0.isCompleted }
    .order(by: \.position)
)
var incompleteTasks
```

### With Joins

```swift
@FetchAll(
  RemindersList
    .group(by: \.id)
    .order(by: \.position)
    .leftJoin(Reminder.all) { $0.id.eq($1.remindersListID) && !$1.isCompleted }
    .leftJoin(SyncMetadata.all) { $0.syncMetadataID.eq($2.id) }
    .select {
      ReminderListState.Columns(
        remindersCount: $1.id.count(),
        remindersList: $0,
        share: $2.share
      )
    },
  animation: .default
)
var remindersLists
```

## @FetchOne - Single Value or Aggregate

Fetch a single record or aggregate value:

```swift
@FetchOne(Fact.count(), animation: .default)
var factsCount = 0
```

### Multiple Aggregates with @Selection

```swift
@FetchOne(
  Reminder.select {
    Stats.Columns(
      allCount: $0.count(filter: !$0.isCompleted),
      flaggedCount: $0.count(filter: $0.isFlagged && !$0.isCompleted),
      scheduledCount: $0.count(filter: $0.isScheduled),
      todayCount: $0.count(filter: $0.isToday)
    )
  }
)
var stats = Stats()

@Selection
struct Stats {
  var allCount = 0
  var flaggedCount = 0
  var scheduledCount = 0
  var todayCount = 0
}
```

## @Selection - Custom Result Types

Define custom result types for complex queries:

```swift
@Selection
struct ReminderListState: Identifiable, Hashable {
  var remindersList: RemindersList
  var remindersCount: Int
  @Column(as: CKShare?.self)
  var share: CKShare?

  var id: RemindersList.ID { remindersList.id }
}
```

Use with queries:

```swift
@FetchAll(
  RemindersList
    .leftJoin(Reminder.all) { $0.id.eq($1.remindersListID) }
    .select { list, reminder in
      ReminderListState.Columns(
        remindersList: list,
        remindersCount: reminder.id.count()
      )
    }
)
var remindersLists
```

## Query Building Blocks

### Filtering

```swift
// Simple equality
Reminder.where { $0.status.eq(.incomplete) }

// Negation
Reminder.where { !$0.isCompleted }

// Comparisons
Reminder.where { $0.priority.gt(.low) }

// In array
Tag.where { $0.title.in(["Work", "Personal"]) }

// Pattern matching
Fact.where { $0.body.contains(searchText) }

// Null checks
Reminder.where { $0.dueDate.isNot(nil) }
```

### Ordering

```swift
// Single column
Counter.order(by: \.id)

// Multiple columns with direction
Reminder
  .order { $0.dueDate.desc() }
  .order { $0.position }
```

### Grouping

```swift
RemindersList
  .group(by: \.id)
  .leftJoin(Reminder.all) { $0.id.eq($1.remindersListID) }
  .select { list, reminder in
    ListSummary.Columns(
      list: list,
      count: reminder.id.count()
    )
  }
```

### Joining

```swift
// Left join
Tag
  .leftJoin(ReminderTag.all) { $0.primaryKey.eq($1.tagID) }
  .leftJoin(Reminder.all) { $1.reminderID.eq($2.id) }

// With conditions
RemindersList
  .leftJoin(Reminder.all) {
    $0.id.eq($1.remindersListID) && !$1.isCompleted
  }
```

### Having

Filter grouped results:

```swift
Tag
  .withReminders
  .having { $2.count().gt(0) }  // Only tags with reminders
  .select { tag, _, _ in tag }
```

### Count

```swift
// Total count
let total = try Reminder.fetchCount(db)

// Filtered count
let incomplete = try Reminder.where { !$0.isCompleted }.fetchCount(db)

// Conditional count in select
Reminder.select {
  Stats.Columns(
    allCount: $0.count(filter: !$0.isCompleted),
    flaggedCount: $0.count(filter: $0.isFlagged)
  )
}
```
