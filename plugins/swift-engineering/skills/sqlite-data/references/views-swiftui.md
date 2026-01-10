# SwiftUI View Integration

Patterns for integrating database queries with SwiftUI views and @Observable models.

## SwiftUI Views

### Direct in View

Use `@FetchAll` and `@FetchOne` directly in SwiftUI views:

```swift
struct CountersListView: View {
  @FetchAll var counters: [Counter]
  @FetchOne(Counter.count()) var countersCount = 0

  var body: some View {
    List {
      Text("Total: \(countersCount)")
      ForEach(counters) { counter in
        Text("\(counter.count)")
      }
    }
  }
}
```

### With Query and Animation

```swift
struct SwiftUIDemo: View {
  @FetchAll(Fact.order { $0.id.desc() }, animation: .default)
  private var facts

  @FetchOne(Fact.count(), animation: .default)
  var factsCount = 0

  var body: some View {
    List {
      Section {
        Text("Facts: \(factsCount)")
          .font(.largeTitle)
          .contentTransition(.numericText(value: Double(factsCount)))
      }
      Section {
        ForEach(facts) { fact in
          Text(fact.body)
        }
      }
    }
  }
}
```

### With Complex Queries

```swift
@FetchAll(
  RemindersList
    .group(by: \.id)
    .order(by: \.position)
    .leftJoin(Reminder.all) { $0.id.eq($1.remindersListID) && !$1.isCompleted }
    .select {
      ListSummary.Columns(
        list: $0,
        incompleteCount: $1.id.count()
      )
    },
  animation: .default
)
var remindersLists
```

## @Observable Models

Use `@ObservationIgnored` to prevent observation of the fetch wrapper itself:

```swift
@Observable
@MainActor
class Model {
  @ObservationIgnored
  @FetchAll(Fact.order { $0.id.desc() }, animation: .default)
  var facts

  @ObservationIgnored
  @FetchOne(Fact.count(), animation: .default)
  var factsCount = 0

  @ObservationIgnored
  @Dependency(\.defaultDatabase) private var database

  func deleteFact(indices: IndexSet) {
    withErrorReporting {
      try database.write { db in
        let ids = indices.map { facts[$0].id }
        try Fact.where { $0.id.in(ids) }.delete().execute(db)
      }
    }
  }
}
```

### In SwiftUI View

```swift
struct ObservableModelDemo: View {
  @State private var model = Model()

  var body: some View {
    List {
      Text("Facts: \(model.factsCount)")
      ForEach(model.facts) { fact in
        Text(fact.body)
      }
      .onDelete { indices in
        model.deleteFact(indices: indices)
      }
    }
  }
}
```

## Animations

### Default Animation

```swift
@FetchAll(Counter.all, animation: .default)
var counters
```

### Custom Animation

```swift
@FetchAll(
  Reminder.where { !$0.isCompleted },
  animation: .spring(response: 0.3, dampingFraction: 0.7)
)
var incompleteTasks
```

### Numeric Transitions

Use `.contentTransition()` for smooth number updates:

```swift
Text("Count: \(factsCount)")
  .contentTransition(.numericText(value: Double(factsCount)))
```

## Best Practices

1. **Use `@ObservationIgnored`** on `@FetchAll`/`@FetchOne` in `@Observable` classes
2. **Always specify `animation:`** parameter for smooth UI updates
3. **Use `.contentTransition()`** for numeric value animations
4. **Wrap deletes in `withErrorReporting`** for consistent error handling
5. **Mark `@Observable` models as `@MainActor`** when used with SwiftUI
