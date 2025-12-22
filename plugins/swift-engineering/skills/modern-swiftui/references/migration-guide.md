# Migration Checklist

When updating legacy SwiftUI code to iOS 17+:

- [ ] Replace `ObservableObject` with `@Observable`
- [ ] Remove all `@Published` (regular properties auto-publish)
- [ ] Replace `@StateObject` with `@State`
- [ ] Replace `@ObservedObject` with `@Bindable`
- [ ] Replace `environmentObject(_:)` with `environment(_:)`
- [ ] Replace `@EnvironmentObject` with `@Environment(Type.self)`
- [ ] Update `onChange(of:perform:)` to `onChange(of:initial:_:)`
- [ ] Replace `.onAppear { Task {} }` with `.task`

## Before & After Example

### Before (iOS 16)
```swift
class UserProfileModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
}

struct ProfileView: View {
    @StateObject private var model = UserProfileModel()

    var body: some View {
        TextField("Name", text: $model.name)
            .onAppear {
                Task {
                    await model.load()
                }
            }
    }
}
```

### After (iOS 17+)
```swift
@Observable
class UserProfileModel {
    var name: String = ""
    var email: String = ""
}

struct ProfileView: View {
    @State private var model = UserProfileModel()

    var body: some View {
        TextField("Name", text: $model.name)
            .task {
                await model.load()
            }
    }
}
```
