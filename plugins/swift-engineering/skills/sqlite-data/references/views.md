# View Integration

Patterns for integrating database queries with SwiftUI views, @Observable models, and UIKit.

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

## UIKit Integration

Use `observe {}` block to react to database changes:

```swift
final class UIKitCaseStudyViewController: UICollectionViewController {
  private var dataSource: UICollectionViewDiffableDataSource<Section, Fact>!

  @FetchAll(Fact.order { $0.id.desc() }, animation: .default)
  private var facts

  @Dependency(\.defaultDatabase) var database

  override func viewDidLoad() {
    super.viewDidLoad()

    // Setup data source
    dataSource = UICollectionViewDiffableDataSource<Section, Fact>(
      collectionView: collectionView
    ) { collectionView, indexPath, item in
      // Cell configuration
    }

    // Observe database changes
    observe { [weak self] in
      guard let self else { return }
      var snapshot = NSDiffableDataSourceSnapshot<Section, Fact>()
      snapshot.appendSections([.facts])
      snapshot.appendItems(facts, toSection: .facts)
      dataSource.apply(snapshot)
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

## Dynamic Query Loading

Update queries dynamically using the projected value:

```swift
struct DynamicQueryDemo: View {
  @Fetch(Facts(), animation: .default)
  private var facts = Facts.Value()

  @State var query = ""

  var body: some View {
    List {
      ForEach(facts.facts) { fact in
        Text(fact.body)
      }
    }
    .searchable(text: $query)
    .task(id: query) {
      await withErrorReporting {
        try await $facts.load(Facts(query: query), animation: .default)
      }
    }
  }

  private struct Facts: FetchKeyRequest {
    var query = ""
    struct Value {
      var facts: [Fact] = []
    }
    func fetch(_ db: Database) throws -> Value {
      try Value(
        facts: Fact.where { $0.body.contains(query) }.fetchAll(db)
      )
    }
  }
}
```

## Manual Refresh

Manually trigger a query refresh in @Observable models:

```swift
@Observable
class SearchModel {
  @ObservationIgnored
  @Fetch(SearchRequest(text: ""), animation: .default)
  var results = SearchResults()

  var searchText = "" {
    didSet {
      Task {
        try await $results.load(
          SearchRequest(text: searchText),
          animation: .default
        )
      }
    }
  }
}
```

## TCA (The Composable Architecture) Integration

Use `@Fetch`/`@FetchOne` directly in TCA `@ObservableState` for reactive queries:

```swift
@ObservableState
struct State: Equatable {
    @Fetch(ItemsRequest()) var items: [Item] = []
    @FetchOne(Bundle.where { $0.isActive }) var activeBundle: Bundle?
}
```

### FetchKeyRequest for Complex Queries

```swift
struct ItemsRequest: FetchKeyRequest {
    typealias Value = [Item]

    func fetch(_ db: Database) throws -> [Item] {
        try Item
            .where { $0.isArchived == false }
            .order { $0.createdAt.desc() }
            .join(ItemDetail.all) { $1.id.eq($0.id) }
            .select {
                Item.Columns(
                    id: $0.id,
                    title: $1.title,
                    createdAt: $0.createdAt
                )
            }
            .fetchAll(db)
    }
}
```

### Anti-Pattern: Imperative Fetch Functions

```swift
// WRONG - Creates unnecessary Effect/Action boilerplate
// Requires manual refetch after every mutation
private func fetchItems() -> Effect<Action> {
    .run { send in
        let items = try await database.read { db in ... }
        await send(.itemsLoaded(items))
    }
}

case .view(.onAppear):
    return fetchItems()  // Must call on appear

case .view(.onItemDeleted(let id)):
    return .run { send in
        try await database.deleteItem(id)
        // Must manually refetch after mutation!
        let items = try await database.read { ... }
        await send(.itemsLoaded(items))
    }
```

```swift
// RIGHT - Use @Fetch, mutations auto-refresh
@ObservableState
struct State: Equatable {
    @Fetch(ItemsRequest()) var items: [Item] = []
}

case .view(.onAppear):
    return .none  // Nothing needed - @Fetch observes automatically

case .view(.onItemDeleted(let id)):
    return .run { _ in
        try await database.deleteItem(id)
        // No refetch needed - @Fetch updates automatically
    }
```

## Best Practices

1. **Use `@ObservationIgnored`** on `@FetchAll`/`@FetchOne` in `@Observable` classes
2. **Always specify `animation:`** parameter for smooth UI updates
3. **Use `.contentTransition()`** for numeric value animations
4. **Wrap deletes in `withErrorReporting`** for consistent error handling
5. **Use `observe {}`** in UIKit for reactive updates
6. **Mark `@Observable` models as `@MainActor`** when used with SwiftUI
7. **Use `@Fetch`/`@FetchOne` in TCA State** - avoid imperative fetch functions
