# NavigationStack Patterns (iOS 16+)

**Use for:** Type-safe programmatic navigation

**Problem:** Need programmatic navigation with deep linking support.

**Solution:**
```swift
// Navigation coordinator
@Observable
@MainActor
final class NavigationCoordinator {
    var path = NavigationPath()

    func navigateTo(_ article: Article) {
        path.append(article)
    }

    func navigateToAuthor(_ author: Author) {
        path.append(author)
    }

    func navigateToRoot() {
        path.removeLast(path.count)
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
}

// App navigation
struct AppNavigationView: View {
    @State private var coordinator = NavigationCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ArticleListView()
                .navigationDestination(for: Article.self) { article in
                    ArticleDetailView(article: article)
                }
                .navigationDestination(for: Author.self) { author in
                    AuthorProfileView(author: author)
                }
                .environment(coordinator)
        }
    }
}

// Usage in views
struct ArticleListView: View {
    @Environment(NavigationCoordinator.self) private var coordinator

    var body: some View {
        List(articles) { article in
            Button {
                coordinator.navigateTo(article)
            } label: {
                ArticleRow(article: article)
            }
        }
    }
}
```

**Benefits:**
- Type-safe navigation
- Programmatic control
- Deep linking ready
- Centralized navigation logic
