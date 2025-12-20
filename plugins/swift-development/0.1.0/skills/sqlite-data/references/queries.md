# Queries

Patterns for fetching data from the database using `@FetchAll`, `@FetchOne`, and `@Fetch`.

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

## @Fetch with FetchKeyRequest

For complex queries that need multiple database operations in a single transaction:

```swift
@Fetch(Facts(), animation: .default)
private var facts = Facts.Value()

private struct Facts: FetchKeyRequest {
  var query = ""

  struct Value {
    var facts: [Fact] = []
    var searchCount = 0
    var totalCount = 0
  }

  func fetch(_ db: Database) throws -> Value {
    let search = Fact
      .where { $0.body.contains(query) }
      .order { $0.id.desc() }

    return try Value(
      facts: search.fetchAll(db),
      searchCount: search.fetchCount(db),
      totalCount: Fact.fetchCount(db)
    )
  }
}
```

## Dynamic Query Loading

Update queries dynamically using the projected value:

```swift
@Fetch(SearchRequest(text: ""), animation: .default)
var searchResults = SearchResults()

// In view:
.task(id: searchText) {
  try await $searchResults.load(
    SearchRequest(text: searchText),
    animation: .default
  )
}
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

## Reading from Database Directly

For non-reactive queries in imperative code:

```swift
@Dependency(\.defaultDatabase) var database

// Read transaction
let counters = try database.read { db in
  try Counter.order(by: \.id).fetchAll(db)
}

// Fetch single record
let counter = try database.read { db in
  try Counter.find(id).fetchOne(db)
}
```
