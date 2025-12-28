# SwiftUI Architecture

## Architecture Decision Tree

```
- Small/medium app, Apple's patterns? -> @Observable + State-as-Bridge
- Familiar with MVVM from UIKit? -> MVVM with @Observable ViewModels
- Rigorous testability, large team? -> TCA (Composable Architecture)
- Complex navigation, deep linking? -> Add Coordinator Pattern
```

## Property Wrapper Decision

```
- View owns the model? -> @State
- App-wide model? -> @Environment
- Need bindings to parent's model? -> @Bindable
- Just reading? -> Plain property (no wrapper)
```

## State-as-Bridge Pattern (WWDC 2025)

Async creates suspension points that break animations:

```swift
// WRONG
Task { isLoading = true; await work(); isLoading = false }

// CORRECT - synchronous state changes for animation
withAnimation { isLoading = true }
Task {
    await work()
    withAnimation { isLoading = false }
}
```

## MVVM Structure

```swift
// Model - domain logic
struct Pet: Identifiable {
    let id: UUID; var name: String
    mutating func giveAward() { hasAward = true }
}

// ViewModel - presentation logic
@Observable
class PetListViewModel {
    private let petStore: PetStore
    var searchText = ""

    var filteredPets: [Pet] {
        petStore.myPets.filter { searchText.isEmpty || $0.name.contains(searchText) }
    }
}

// View - UI only
struct PetListView: View {
    @Bindable var viewModel: PetListViewModel

    var body: some View {
        List(viewModel.filteredPets) { PetRow(pet: $0) }
            .searchable(text: $viewModel.searchText)
    }
}
```

## TCA Trade-offs

| Scenario | Choice |
|----------|--------|
| < 10 screens | Apple patterns |
| Testability critical | TCA |
| Large team | TCA for consistency |
| Rapid prototyping | Apple patterns |

## Anti-Patterns

**Logic in view body:**
```swift
// WRONG - formatter created every render
var body: some View {
    let formatter = NumberFormatter()
    Text(formatter.string(from: price)!)
}

// CORRECT - cache in model
class ViewModel {
    private let formatter = NumberFormatter()
    func format(_ price: Decimal) -> String { ... }
}
```

**Wrong property wrapper:**
```swift
// WRONG - @State copies, loses parent changes
struct DetailView: View { @State var item: Item }

// CORRECT
struct DetailView: View { let item: Item }  // or @Bindable
```

**God ViewModel:**
```swift
// WRONG
class AppViewModel { var user; var settings; var posts; ... }

// CORRECT - separate concerns
class UserViewModel { }
class SettingsViewModel { }
```

## Code Review Checklist

- [ ] View bodies contain ONLY UI code
- [ ] No formatters in view body
- [ ] Business logic testable without SwiftUI
- [ ] State changes for animations are synchronous
