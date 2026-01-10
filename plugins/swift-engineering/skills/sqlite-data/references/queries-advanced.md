# Query Advanced Patterns

FetchKeyRequest, dynamic queries, direct database access, and recursive CTEs.

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

## Static Fetch Helpers (v1.4+)

Convenient static methods for common fetches:

```swift
// Fetch all records
let items = try Item.fetchAll(db)

// Fetch with query
let active = try Item.where { !$0.isArchived }.fetchAll(db)

// Find by primary key
let item = try Item.find(db, key: id)

// Fetch count
let total = try Item.fetchCount(db)
```

## Recursive CTEs

Query hierarchical data like trees or org charts:

```swift
@Table
nonisolated struct Category: Identifiable {
    let id: UUID
    var name = ""
    var parentID: UUID?  // Self-referential
}

// Get all descendants of a category
let descendants = try With {
    // Base case: start with root
    Category.where { $0.id.eq(rootCategoryId) }
} recursiveUnion: { cte in
    // Recursive case: join children to CTE
    Category.all
        .join(cte) { $0.parentID.eq($1.id) }
        .select { $0 }
} query: { cte in
    cte.order(by: \.name)
}
.fetchAll(db)
```

### Walking Up the Tree (Ancestors)

```swift
let ancestors = try With {
    Category.where { $0.id.eq(childCategoryId) }
} recursiveUnion: { cte in
    Category.all
        .join(cte) { $0.id.eq($1.parentID) }
        .select { $0 }
} query: { cte in
    cte.all
}
.fetchAll(db)
```

### Threaded Comments with Depth

```swift
let thread = try With {
    Comment
        .where { $0.parentID.is(nil) && $0.postID.eq(postId) }
        .select { ($0, 0) }  // depth = 0 for root
} recursiveUnion: { cte in
    Comment.all
        .join(cte) { $0.parentID.eq($1.id) }
        .select { ($0, $1.depth + 1) }
} query: { cte in
    cte.order { ($0.depth, $0.createdAt) }
}
.fetchAll(db)
```

## Best Practices

1. **Use `@FetchAll`/`@FetchOne`** for simple queries - avoid `FetchKeyRequest` overhead
2. **Use `FetchKeyRequest`** only when you need multiple fetches or data transformation
3. **Use dynamic loading** with `$property.load()` for search/filter scenarios
4. **Prefer reactive queries** (`@FetchAll`) over imperative reads when possible
5. **Use recursive CTEs** for hierarchical data instead of multiple queries
