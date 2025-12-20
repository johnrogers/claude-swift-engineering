# Table Models

Patterns for defining database tables using the `@Table` macro.

## Basic Table Definition

```swift
@Table
nonisolated struct SyncUp: Hashable, Identifiable {
  let id: UUID
  var title = ""
  var seconds: Int = 60 * 5
  var theme: Theme = .bubblegum
}
```

**Requirements:**
- Marked with `@Table` macro
- `nonisolated` for Sendable conformance
- `Identifiable` conformance (primary key defaults to `id` property)
- `Hashable` conformance

## Primary Keys

### Auto-Generated Primary Key

By default, a property named `id` is used as the primary key:

```swift
@Table
nonisolated struct Meeting: Hashable, Identifiable {
  let id: UUID  // Automatically becomes primary key
  var date: Date
  var notes: String
}
```

### Custom Primary Key

Use `@Column(primaryKey: true)` for custom primary keys:

```swift
@Table
nonisolated struct Tag: Hashable, Identifiable {
  @Column(primaryKey: true)
  var title: String
  var id: String { title }
}
```

### Composite Primary Key

For junction tables or tables with composite keys:

```swift
@Table
nonisolated struct RemindersListAsset: Hashable, Identifiable {
  @Column(primaryKey: true)
  let remindersListID: RemindersList.ID
  var coverImage: Data?
  var id: RemindersList.ID { remindersListID }
}
```

## Custom Column Types

Use `@Column(as:)` for custom type representations:

```swift
@Table
nonisolated struct RemindersList: Hashable, Identifiable {
  let id: UUID
  @Column(as: Color.HexRepresentation.self)
  var color: Color = Self.defaultColor
  var title = ""
}

extension Color {
  struct HexRepresentation: ColumnRepresentable {
    // Implementation for converting Color to/from hex string
  }
}
```

## Foreign Keys

Define foreign key relationships by referencing another table's ID type:

```swift
@Table
nonisolated struct Attendee: Hashable, Identifiable {
  let id: UUID
  var name = ""
  var syncUpID: SyncUp.ID  // Foreign key to SyncUp table
}
```

## Draft Types

The `@Table` macro auto-generates a `.Draft` type for insertions:

```swift
// Auto-generated:
extension SyncUp {
  struct Draft {
    var id: UUID = UUID()
    var title = ""
    var seconds: Int = 60 * 5
    var theme: Theme = .bubblegum
  }
}

// Usage:
SyncUp.insert {
  SyncUp.Draft(
    title: "Daily Standup",
    seconds: 900
  )
}.execute(db)
```

Make Draft types conform to Identifiable when needed:

```swift
extension SyncUp.Draft: Identifiable {}
```

## Nested Enums

Enums conforming to `QueryBindable` can be used as column types:

```swift
@Table
nonisolated struct Reminder: Hashable, Identifiable {
  let id: UUID
  var priority: Priority?
  var status: Status = .incomplete

  enum Priority: Int, QueryBindable {
    case low = 1
    case medium
    case high
  }

  enum Status: Int, QueryBindable {
    case completed = 1
    case completing = 2
    case incomplete = 0
  }
}
```

## Computed Properties

Add computed properties for convenience (not stored in database):

```swift
@Table
nonisolated struct Reminder: Hashable, Identifiable {
  let id: UUID
  var status: Status

  var isCompleted: Bool {
    status != .incomplete
  }

  enum Status: Int, QueryBindable {
    case incomplete = 0
    case completed = 1
    case completing = 2
  }
}
```

## TableColumns Extensions

Extend `TableColumns` for computed query expressions:

```swift
nonisolated extension Reminder.TableColumns {
  var isCompleted: some QueryExpression<Bool> {
    status.neq(Reminder.Status.incomplete)
  }

  var isPastDue: some QueryExpression<Bool> {
    @Dependency(\.date.now) var now
    return !isCompleted && #sql("coalesce(date(\(dueDate)) < date(\(now)), 0)")
  }

  var isToday: some QueryExpression<Bool> {
    @Dependency(\.date.now) var now
    return !isCompleted && #sql("coalesce(date(\(dueDate)) = date(\(now)), 0)")
  }
}

// Usage in queries:
Reminder.where { $0.isPastDue }.fetchAll(db)
```

## Static Query Helpers

Define static properties for common queries:

```swift
extension Reminder {
  static let incomplete = Self.where { !$0.isCompleted }

  static let withTags = group(by: \.id)
    .leftJoin(ReminderTag.all) { $0.id.eq($1.reminderID) }
    .leftJoin(Tag.all) { $1.tagID.eq($2.primaryKey) }
}

// Usage:
let incompleteTasks = try Reminder.incomplete.fetchAll(db)
```
