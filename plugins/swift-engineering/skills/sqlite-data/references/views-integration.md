# View Integration Patterns

UIKit integration, dynamic queries, and TCA patterns.

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

## TCA Integration

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

1. **Use `observe {}`** in UIKit for reactive updates
2. **Use dynamic loading** with `$property.load()` for search/filter scenarios
3. **Use `@Fetch`/`@FetchOne` in TCA State** - avoid imperative fetch functions
4. **Avoid imperative patterns** - let the property wrappers handle refetching
5. **Use `.task(id:)`** for search queries that change based on user input
