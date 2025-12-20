# Testing

Patterns for testing database code with swift-testing and swift-dependencies.

## Test Suite Setup

### Basic Test Suite

```swift
@Suite(
  .dependencies {
    try $0.bootstrapDatabase()
  }
)
struct MyTestSuite {}
```

### With Controlled Dependencies

```swift
@Suite(
  .dependency(\.continuousClock, ImmediateClock()),
  .dependency(\.date.now, Date(timeIntervalSince1970: 1_234_567_890)),
  .dependency(\.uuid, .incrementing),
  .dependencies {
    try $0.bootstrapDatabase()
    try await $0.defaultSyncEngine.sendChanges()
  },
  .snapshots(record: .failed)
)
struct BaseTestSuite {}
```

### Nested Test Suites

```swift
extension BaseTestSuite {
  @MainActor
  struct RemindersDetailsTests {
    @Dependency(\.defaultDatabase) var database

    @Test func basics() async throws {
      // Test implementation
    }
  }
}
```

## Reading from Database

### Fetch for Assertions

```swift
@Test func testCounter() async throws {
  @Dependency(\.defaultDatabase) var database

  // Act
  try database.write { db in
    try Counter.insert { Counter.Draft(count: 5) }.execute(db)
  }

  // Assert
  let counter = try database.read { db in
    try Counter.fetchOne(db)!
  }
  #expect(counter.count == 5)
}
```

### Fetch One Record

```swift
let remindersList = try await database.read { try RemindersList.fetchOne($0)! }
```

### Fetch All Records

```swift
let attendees = try database.read { db in
  try Attendee.where { $0.syncUpID.eq(syncUp.id) }.fetchAll(db)
}
```

## Seeding Test Data

### Define Seed Extension

```swift
extension Database {
  func seed() throws {
    try seed {
      SyncUp(id: UUID(1), seconds: 60, theme: .appOrange, title: "Design")
      SyncUp(id: UUID(2), seconds: 60 * 10, theme: .periwinkle, title: "Engineering")

      for name in ["Blob", "Blob Jr", "Blob Sr"] {
        Attendee.Draft(name: name, syncUpID: UUID(1))
      }
      for name in ["Blob", "Blob Jr"] {
        Attendee.Draft(name: name, syncUpID: UUID(2))
      }

      Meeting.Draft(
        date: Date().addingTimeInterval(-60 * 60 * 24 * 7),
        syncUpID: UUID(1),
        transcript: "Meeting notes..."
      )
    }
  }
}
```

### Use in Test Suite

```swift
@Suite(
  .dependencies {
    try $0.bootstrapDatabase()
    try $0.defaultDatabase.write { db in
      try db.seed()
    }
    $0.uuid = .incrementing
  }
)
struct SyncUpFormTests {}
```

## Testing with @Fetch

### Load and Assert

```swift
@Test func testRemindersDetail() async throws {
  @Dependency(\.defaultDatabase) var database

  let remindersList = try await database.read { try RemindersList.fetchOne($0)! }
  let model = RemindersDetailModel(detailType: .remindersList(remindersList))

  // Load the @Fetch query
  try await model.$reminderRows.load()

  // Assert on results
  #expect(model.reminderRows.count == 4)
}
```

## Snapshot Testing

### Inline Snapshots

```swift
@Test func testModel() async throws {
  let model = RemindersDetailModel(detailType: .remindersList(remindersList))
  try await model.$reminderRows.load()

  assertInlineSnapshot(of: model.reminderRows, as: .customDump) {
    #"""
    [
      [0]: RemindersDetailModel.Row(
        reminder: Reminder(
          id: UUID(00000000-0000-0000-0000-000000000004),
          title: "Haircut",
          dueDate: Date(2009-02-11T23:31:30.000Z),
          status: .incomplete
        )
      )
    ]
    """#
  }
}
```

### CustomDumpReflectable for Consistent Output

Handle types that don't dump consistently (like SwiftUI.Color):

```swift
extension RemindersList: @retroactive CustomDumpReflectable {
  public var customDumpMirror: Mirror {
    Mirror(
      self,
      children: [
        "id": id,
        "color": Color.HexRepresentation(queryOutput: color).hexValue ?? 0,
        "position": position,
        "title": title,
      ],
      displayStyle: .struct
    )
  }
}
```

## Testing Writes

### Test Insert

```swift
@Test func testInsert() async throws {
  @Dependency(\.defaultDatabase) var database

  try database.write { db in
    try Counter.insert { Counter.Draft(count: 42) }.execute(db)
  }

  let counters = try database.read { db in
    try Counter.fetchAll(db)
  }

  #expect(counters.count == 1)
  #expect(counters[0].count == 42)
}
```

### Test Update

```swift
@Test func testUpdate() async throws {
  @Dependency(\.defaultDatabase) var database

  let id = UUID()
  try database.write { db in
    try Counter.insert { Counter.Draft(id: id, count: 0) }.execute(db)
    try Counter.find(id).update { $0.count += 1 }.execute(db)
  }

  let counter = try database.read { db in
    try Counter.find(id).fetchOne(db)!
  }

  #expect(counter.count == 1)
}
```

### Test Delete

```swift
@Test func testDelete() async throws {
  @Dependency(\.defaultDatabase) var database

  let id = UUID()
  try database.write { db in
    try Counter.insert { Counter.Draft(id: id) }.execute(db)
    try Counter.find(id).delete().execute(db)
  }

  let counters = try database.read { db in
    try Counter.fetchAll(db)
  }

  #expect(counters.isEmpty)
}
```

## Controlled Dependencies

### UUID Incrementing

```swift
@Suite(.dependency(\.uuid, .incrementing))
struct MyTests {
  @Test func testUUIDs() {
    @Dependency(\.uuid) var uuid
    #expect(uuid() == UUID(0))
    #expect(uuid() == UUID(1))
    #expect(uuid() == UUID(2))
  }
}
```

### Fixed Date

```swift
@Suite(.dependency(\.date.now, Date(timeIntervalSince1970: 1_234_567_890)))
struct DateTests {
  @Test func testDateComparison() {
    @Dependency(\.date.now) var now
    // now is always Date(timeIntervalSince1970: 1_234_567_890)
  }
}
```

### Immediate Clock

```swift
@Suite(.dependency(\.continuousClock, ImmediateClock()))
struct TimerTests {
  @Test func testTimer() async {
    // All sleep operations complete immediately
  }
}
```

## Best Practices

1. **Use `@Suite(.dependencies {})`** to configure test dependencies
2. **Seed data in suite setup** for consistent test state
3. **Use `.incrementing` UUID** for predictable IDs in tests
4. **Use fixed `date.now`** for time-dependent tests
5. **Use `ImmediateClock`** to avoid waiting in tests
6. **Load `@Fetch` queries** with `$property.load()` before assertions
7. **Use `assertInlineSnapshot`** for comprehensive output validation
8. **Define `CustomDumpReflectable`** for types with inconsistent dumps
9. **Bootstrap database** in test suite setup
10. **Test in transactions** - each test gets fresh database state
