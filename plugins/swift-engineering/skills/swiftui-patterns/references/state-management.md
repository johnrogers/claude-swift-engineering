# State Management (iOS 17+)

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
