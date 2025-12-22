# Modern View Modifiers (iOS 17+)

## onChange(of:initial:_:) — New Signature

### ✅ Modern Pattern
```swift
struct SearchView: View {
    @State private var searchText = ""

    var body: some View {
        TextField("Search", text: $searchText)
            .onChange(of: searchText) { oldValue, newValue in
                performSearch(query: newValue)
            }
            // Run on appear with initial: true
            .onChange(of: searchText, initial: true) { oldValue, newValue in
                validateInput(newValue)
            }
    }
}
```

### ❌ Deprecated Pattern
```swift
// DEPRECATED: onChange(of:perform:)
.onChange(of: searchText) { newValue in
    performSearch(query: newValue)
}
```

## task(priority:_:) — Async Work

### ✅ Modern Pattern
```swift
struct UserListView: View {
    @State private var users: [User] = []
    @State private var isLoading = false

    var body: some View {
        List(users) { user in
            UserRow(user: user)
        }
        .task {
            await loadUsers()
        }
        .task(id: selectedFilter) {
            // Cancelled and restarted when selectedFilter changes
            await loadUsers(filter: selectedFilter)
        }
    }

    func loadUsers() async {
        isLoading = true
        users = try? await fetchUsers()
        isLoading = false
    }
}
```

### ❌ Deprecated Pattern
```swift
// NEVER use .onAppear with Task
.onAppear {
    Task {
        await loadUsers()
    }
}
```
