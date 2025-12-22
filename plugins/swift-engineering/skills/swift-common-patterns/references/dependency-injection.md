# Environment-Based Dependency Injection

**Use for:** App-wide services, design systems, configuration

**Problem:** Need to inject dependencies into SwiftUI views without global singletons.

**Solution:**
```swift
// Define environment keys
extension EnvironmentValues {
    @Entry var articleService: ArticleService = DefaultArticleService()
    @Entry var designSystem: DesignSystem = .default
}

// Inject at app level
@main
struct NewsApp: App {
    private let articleService = DefaultArticleService()
    private let designSystem = DesignSystem.production

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.articleService, articleService)
                .environment(\.designSystem, designSystem)
        }
    }
}

// Access in views
struct ArticleListView: View {
    @Environment(\.articleService) private var articleService
    @Environment(\.designSystem) private var designSystem

    @State private var articles: [Article] = []

    var body: some View {
        List(articles) { article in
            Text(article.title)
                .foregroundColor(designSystem.colorTokens.semanticForegroundBase.color)
        }
        .task {
            articles = try await articleService.fetchArticles()
        }
    }
}
```

**Benefits:**
- No global singletons
- Testable (inject mock services)
- Type-safe
- SwiftUI-native
