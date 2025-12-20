# Dependency Injection

Patterns for integrating sqlite-data with swift-dependencies for dependency injection.

## Accessing Dependencies

### @Dependency in Views

```swift
struct CountersListView: View {
  @FetchAll var counters: [Counter]
  @Dependency(\.defaultDatabase) var database

  var body: some View {
    List {
      ForEach(counters) { counter in
        CounterRow(counter: counter)
      }
    }
    .toolbar {
      Button("Add") {
        withErrorReporting {
          try database.write { db in
            try Counter.insert { Counter.Draft() }.execute(db)
          }
        }
      }
    }
  }
}
```

### @Dependency in @Observable Models

```swift
@Observable
@MainActor
class RemindersListsModel {
  @ObservationIgnored
  @FetchAll(RemindersList.all)
  var remindersLists

  @ObservationIgnored
  @Dependency(\.defaultDatabase) private var database

  @ObservationIgnored
  @Dependency(\.defaultSyncEngine) var syncEngine

  func addList() {
    withErrorReporting {
      try database.write { db in
        try RemindersList.insert { RemindersList.Draft() }.execute(db)
      }
    }
  }
}
```

### In TCA Reducers

```swift
@Reducer
struct CountersListFeature {
  struct State {
    // ...
  }
  enum Action {
    // ...
  }

  @Dependency(\.defaultDatabase) var database
  @Dependency(\.defaultSyncEngine) var syncEngine

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .addCounter:
        return .run { send in
          try await database.write { db in
            try Counter.insert { Counter.Draft() }.execute(db)
          }
        }
      }
    }
  }
}
```

## Bootstrap Database

### Extension on DependencyValues

```swift
extension DependencyValues {
  mutating func bootstrapDatabase(
    syncEngineDelegate: (any SyncEngineDelegate)? = nil
  ) throws {
    defaultDatabase = try appDatabase()
    defaultSyncEngine = try SyncEngine(
      for: defaultDatabase,
      tables: RemindersList.self,
      RemindersListAsset.self,
      Reminder.self,
      Tag.self,
      ReminderTag.self,
      delegate: syncEngineDelegate
    )
  }
}
```

### Call in App Init

```swift
@main
struct MyApp: App {
  @State var syncEngineDelegate = MySyncEngineDelegate()

  init() {
    try! prepareDependencies {
      try $0.bootstrapDatabase(syncEngineDelegate: syncEngineDelegate)
    }
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
```

## Preview Dependencies

### Override for Previews

```swift
#Preview {
  let _ = prepareDependencies {
    $0.defaultDatabase = .swiftUIDatabase
  }

  NavigationStack {
    CaseStudyView {
      SwiftUIDemo()
    }
  }
}
```

### Preview Database

```swift
extension DatabaseWriter where Self == DatabaseQueue {
  static var swiftUIDatabase: Self {
    let databaseQueue = try! DatabaseQueue()
    var migrator = DatabaseMigrator()
    migrator.registerMigration("Create 'facts' table") { db in
      try #sql(
        """
        CREATE TABLE "facts" (
          "id" INTEGER PRIMARY KEY AUTOINCREMENT,
          "body" TEXT NOT NULL
        ) STRICT
        """
      ).execute(db)
    }
    try! migrator.migrate(databaseQueue)
    return databaseQueue
  }
}
```

## withDependencies for Child Models

When creating child models that need access to dependencies:

```swift
@Observable
class ParentModel {
  @ObservationIgnored
  @Dependency(\.defaultDatabase) var database

  func createChildModel() -> ChildModel {
    withDependencies(from: self) {
      ChildModel()
    }
  }
}
```

### In TCA

```swift
@Reducer
struct ParentFeature {
  @Dependency(\.defaultDatabase) var database

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .addButtonTapped:
        state.destination = .form(
          withDependencies(from: self) {
            FormFeature.State()
          }
        )
        return .none
      }
    }
  }
}
```

## Accessing Other Dependencies

### Date Dependency

```swift
nonisolated extension Reminder.TableColumns {
  var isPastDue: some QueryExpression<Bool> {
    @Dependency(\.date.now) var now
    return !isCompleted && #sql("coalesce(date(\(dueDate)) < date(\(now)), 0)")
  }
}
```

### UUID Dependency

```swift
@Dependency(\.uuid) var uuid

func createNewItem() {
  let id = uuid()
  // Use id
}
```

### Context Dependency

```swift
@Dependency(\.context) var context

switch context {
case .live:
  // Production behavior
case .preview:
  // Preview behavior
case .test:
  // Test behavior
}
```

## Database Writer Protocol

The `defaultDatabase` dependency conforms to `DatabaseWriter`:

```swift
protocol DatabaseWriter {
  func read<T>(_ block: (Database) throws -> T) throws -> T
  func write<T>(_ block: (Database) throws -> T) throws -> T
}
```

### Read Transaction

```swift
@Dependency(\.defaultDatabase) var database

let counters = try database.read { db in
  try Counter.order(by: \.id).fetchAll(db)
}
```

### Write Transaction

```swift
@Dependency(\.defaultDatabase) var database

try database.write { db in
  try Counter.insert { Counter.Draft() }.execute(db)
}
```

### Async Write

```swift
try await database.write { db in
  try Fact.insert { Fact.Draft(body: fact) }.execute(db)
}
```

## Best Practices

1. **Use `@ObservationIgnored`** on `@Dependency` in `@Observable` classes
2. **Call `prepareDependencies`** in App init, not in previews when possible
3. **Use `withDependencies(from:)`** when creating child models
4. **Bootstrap database once** at app launch
5. **Override dependencies** in previews and tests
6. **Use `.defaultDatabase`** for all database access
7. **Mark database dependency as private** when only used internally
