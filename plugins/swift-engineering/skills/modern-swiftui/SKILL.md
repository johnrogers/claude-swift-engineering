---
description: Modern SwiftUI essentials (iOS 17+) — @Observable, @Bindable, modern view modifiers
---

# Modern SwiftUI Patterns (iOS 17+)

Critical SwiftUI patterns for iOS 17+ apps. **Always use these patterns** — avoid deprecated alternatives.

## @Observable — NOT ObservableObject

### ✅ Modern Pattern (iOS 17+)
```swift
import Observation

@Observable
class UserProfileModel {
    var name: String = ""
    var email: String = ""
    var isLoading: Bool = false

    func save() async {
        isLoading = true
        // Save logic
        isLoading = false
    }
}

// In SwiftUI view
struct ProfileView: View {
    let model: UserProfileModel

    var body: some View {
        TextField("Name", text: $model.name)
    }
}
```

### ❌ Deprecated Pattern
```swift
// NEVER use ObservableObject for new code
class UserProfileModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
}
```

## @State — NOT @StateObject

### ✅ Modern Pattern
```swift
struct ProfileView: View {
    @State private var model = UserProfileModel()

    var body: some View {
        TextField("Name", text: $model.name)
    }
}
```

### ❌ Deprecated Pattern
```swift
// NEVER use @StateObject with @Observable
@StateObject private var model = UserProfileModel()
```

## @Bindable — NOT @ObservedObject

### ✅ Modern Pattern
```swift
struct ProfileEditView: View {
    @Bindable var model: UserProfileModel

    var body: some View {
        Form {
            TextField("Name", text: $model.name)
            TextField("Email", text: $model.email)
        }
    }
}

// Usage
struct ProfileView: View {
    @State private var model = UserProfileModel()

    var body: some View {
        ProfileEditView(model: model)
    }
}
```

### ❌ Deprecated Pattern
```swift
// NEVER use @ObservedObject with @Observable
@ObservedObject var model: UserProfileModel
```

## environment(_:) — NOT environmentObject(_:)

### ✅ Modern Pattern
```swift
@Observable
class AppSettings {
    var isDarkMode: Bool = false
}

// Inject into environment
struct MyApp: App {
    @State private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(settings)
        }
    }
}

// Access in child view
struct SettingsView: View {
    @Environment(AppSettings.self) private var settings

    var body: some View {
        Toggle("Dark Mode", isOn: $settings.isDarkMode)
    }
}
```

### ❌ Deprecated Pattern
```swift
// NEVER use .environmentObject(_:) with @Observable
.environmentObject(settings)

// NEVER use @EnvironmentObject with @Observable
@EnvironmentObject var settings: AppSettings
```

## onChange(of:initial:_:) — New Signature

### ✅ Modern Pattern (iOS 17+)
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

## Quick Reference

| Need | Use (iOS 17+) | NOT |
|------|---------------|-----|
| Observable model | `@Observable` | `ObservableObject` |
| Published property | Just a regular property | `@Published` |
| Own state | `@State` | `@StateObject` |
| Passed model (binding) | `@Bindable` | `@ObservedObject` |
| Environment injection | `environment(_:)` | `environmentObject(_:)` |
| Environment access | `@Environment(Type.self)` | `@EnvironmentObject` |
| Value change | `onChange(of:initial:_:)` | `onChange(of:perform:)` |
| Async on appear | `task(priority:_:)` | `onAppear { Task {} }` |

## Common Patterns

### Navigation with Observable
```swift
@Observable
class NavigationModel {
    var path = NavigationPath()
    var selectedItem: Item?

    func navigateTo(_ item: Item) {
        selectedItem = item
    }
}

struct ContentView: View {
    @State private var navigation = NavigationModel()

    var body: some View {
        NavigationStack(path: $navigation.path) {
            ItemList()
                .environment(navigation)
        }
    }
}
```

### Form with Validation
```swift
@Observable
class FormModel {
    var email: String = ""
    var isValid: Bool { email.contains("@") }
}

struct FormView: View {
    @State private var model = FormModel()

    var body: some View {
        Form {
            TextField("Email", text: $model.email)
            Button("Submit") { }
                .disabled(!model.isValid)
        }
    }
}
```

### Loading State
```swift
struct DataView: View {
    @State private var data: [Item] = []
    @State private var isLoading = false
    @State private var error: Error?

    var body: some View {
        List(data) { item in
            Text(item.name)
        }
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .task {
            isLoading = true
            defer { isLoading = false }

            do {
                data = try await fetchData()
            } catch {
                self.error = error
            }
        }
    }
}
```

## Migration Checklist

When updating legacy SwiftUI code:

- [ ] Replace `ObservableObject` with `@Observable`
- [ ] Remove all `@Published` (regular properties auto-publish)
- [ ] Replace `@StateObject` with `@State`
- [ ] Replace `@ObservedObject` with `@Bindable`
- [ ] Replace `environmentObject(_:)` with `environment(_:)`
- [ ] Replace `@EnvironmentObject` with `@Environment(Type.self)`
- [ ] Update `onChange(of:perform:)` to `onChange(of:initial:_:)`
- [ ] Replace `.onAppear { Task {} }` with `.task`

## Why @Observable?

**Benefits:**
- **Less boilerplate** — no `@Published` needed
- **Better performance** — fine-grained observation (only tracks accessed properties)
- **Type-safe environment** — `@Environment(Type.self)` instead of `@EnvironmentObject`
- **Simpler bindings** — `@Bindable` instead of `@ObservedObject`

**Requirement:** iOS 17.0+ / macOS 14.0+
