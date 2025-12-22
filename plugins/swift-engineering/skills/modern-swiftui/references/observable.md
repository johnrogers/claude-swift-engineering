# @Observable — NOT ObservableObject

**iOS 17+ Pattern**

## ✅ Modern Pattern
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

## ❌ Deprecated Pattern
```swift
// NEVER use ObservableObject for new code
class UserProfileModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
}
```

## Why @Observable?

**Benefits:**
- **Less boilerplate** — no `@Published` needed
- **Better performance** — fine-grained observation (only tracks accessed properties)
- **Type-safe environment** — `@Environment(Type.self)` instead of `@EnvironmentObject`
- **Simpler bindings** — `@Bindable` instead of `@ObservedObject`

**Requirement:** iOS 17.0+ / macOS 14.0+
