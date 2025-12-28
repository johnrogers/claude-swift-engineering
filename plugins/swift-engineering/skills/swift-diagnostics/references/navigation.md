# Navigation Diagnostics

Systematic debugging for NavigationStack issues. 85% of navigation problems stem from path state management, view identity, or destination placement.

## Diagnostic Decision Table

| Observation | Diagnosis | Next Step |
|-------------|-----------|-----------|
| onChange never fires on tap | NavigationLink not in NavigationStack | Check view hierarchy |
| onChange fires but view doesn't push | navigationDestination not found | Check destination placement |
| Pushes then immediately pops | View identity issue or path reset | Check @State location |
| Path changes unexpectedly | External code modifying path | Add logging to find source |
| Deep link doesn't navigate | Timing issue or wrong thread | Check MainActor isolation |
| State lost on tab switch | NavigationStack shared across tabs | Use separate stacks per tab |

## Mandatory First Checks

Run these BEFORE changing code:

```swift
// 1. Add NavigationPath logging
NavigationStack(path: $path) {
    RootView()
        .onChange(of: path.count) { oldCount, newCount in
            print("Path changed: \(oldCount) -> \(newCount)")
        }
}

// 2. Verify navigationDestination is evaluated
.navigationDestination(for: Recipe.self) { recipe in
    let _ = print("Destination for: \(recipe.name)")
    RecipeDetail(recipe: recipe)
}

// 3. Test minimal case in isolation
NavigationStack {
    NavigationLink("Test", value: "test")
        .navigationDestination(for: String.self) { str in
            Text("Pushed: \(str)")
        }
}
```

## Decision Tree

```
Navigation problem?
|-- Link tap does nothing?
|   |-- onChange fires? -> Check navigationDestination placement
|   |-- onChange silent? -> Link outside NavigationStack
|
|-- Unexpected pop back?
|   |-- Immediate after push? -> Path recreated (check @State location)
|   |-- Random timing? -> External code modifying path
|
|-- Deep link fails?
|   |-- URL received? -> Check MainActor for path.append
|   |-- URL not received? -> Check URL scheme in Info.plist
|
|-- State lost on tab switch?
    |-- Same path for all tabs? -> Each tab needs own NavigationStack
```

## Common Patterns

### Pattern 1: Link Outside NavigationStack

```swift
// WRONG - Link outside stack
VStack {
    NavigationLink("Go", value: "test")  // Won't work
    NavigationStack {
        Text("Root")
    }
}

// CORRECT - Link inside stack
NavigationStack {
    VStack {
        NavigationLink("Go", value: "test")
        Text("Root")
    }
    .navigationDestination(for: String.self) { Text($0) }
}
```

### Pattern 2: Destination in Lazy Container

```swift
// WRONG - Destination may not be loaded
LazyVStack {
    ForEach(items) { item in
        NavigationLink(item.name, value: item)
            .navigationDestination(for: Item.self) { /* ... */ }
    }
}

// CORRECT - Destination outside lazy container
LazyVStack {
    ForEach(items) { item in
        NavigationLink(item.name, value: item)
    }
}
.navigationDestination(for: Item.self) { item in
    ItemDetail(item: item)
}
```

### Pattern 3: Path Recreated Every Render

```swift
// WRONG - Path reset on every body evaluation
struct ContentView: View {
    var body: some View {
        let path = NavigationPath()  // Recreated!
        NavigationStack(path: .constant(path)) { /* ... */ }
    }
}

// CORRECT - @State persists across renders
struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) { /* ... */ }
    }
}
```

### Pattern 4: Path Modified Off MainActor

```swift
// WRONG - May fail silently
func loadAndNavigate() async {
    let recipe = await fetchRecipe()
    path.append(recipe)  // Not on MainActor
}

// CORRECT - Explicit MainActor
@MainActor
func loadAndNavigate() async {
    let recipe = await fetchRecipe()
    path.append(recipe)
}
```

### Pattern 5: Deep Link Timing

```swift
// WRONG - NavigationStack may not exist yet
.onOpenURL { url in
    handleDeepLink(url)  // Too early on cold start
}

// CORRECT - Queue until ready
@State private var pendingDeepLink: URL?
@State private var isReady = false

var body: some View {
    NavigationStack(path: $path) {
        RootView()
            .onAppear {
                isReady = true
                if let url = pendingDeepLink {
                    handleDeepLink(url)
                    pendingDeepLink = nil
                }
            }
    }
    .onOpenURL { url in
        if isReady {
            handleDeepLink(url)
        } else {
            pendingDeepLink = url
        }
    }
}
```

### Pattern 6: Shared NavigationStack Across Tabs

```swift
// WRONG - All tabs share navigation state
NavigationStack(path: $path) {
    TabView {
        Tab("Home") { HomeView() }
        Tab("Settings") { SettingsView() }
    }
}

// CORRECT - Each tab has own stack
TabView {
    Tab("Home", systemImage: "house") {
        NavigationStack {
            HomeView()
        }
    }
    Tab("Settings", systemImage: "gear") {
        NavigationStack {
            SettingsView()
        }
    }
}
```

## Type Mismatch Debugging

```swift
// Check: Value type must exactly match destination type
NavigationLink(recipe.name, value: recipe)  // Recipe type

// This won't work if destination is for Recipe.ID
.navigationDestination(for: Recipe.ID.self) { id in  // Wrong!
    RecipeDetail(id: id)
}

// Types must match
.navigationDestination(for: Recipe.self) { recipe in  // Correct
    RecipeDetail(recipe: recipe)
}
```

## Verification Checklist

After applying fix:
- [ ] onChange(of: path) fires when expected
- [ ] Destination print statement executes
- [ ] Navigation persists (doesn't pop back)
- [ ] Works on cold start (deep links)
- [ ] State preserved across tab switches
