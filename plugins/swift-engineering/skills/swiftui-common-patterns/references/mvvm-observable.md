# MVVM with @Observable (iOS 17+)

**Use for:** View models with reactive state

**Problem:** Need reactive view models without @Published boilerplate.

**Solution:**
```swift
import Observation

@Observable
@MainActor
final class ArticleListViewModel {
    var articles: [Article] = []
    var isLoading = false
    var errorMessage: String?

    private let articleService: ArticleService

    init(articleService: ArticleService) {
        self.articleService = articleService
    }

    func loadArticles() async {
        isLoading = true
        errorMessage = nil

        do {
            articles = try await articleService.fetchArticles()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

struct ArticleListView: View {
    @State private var viewModel: ArticleListViewModel

    init(articleService: ArticleService) {
        _viewModel = State(wrappedValue: ArticleListViewModel(articleService: articleService))
    }

    var body: some View {
        List(viewModel.articles) { article in
            ArticleRow(article: article)
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            if let message = viewModel.errorMessage {
                Text(message)
            }
        }
        .task {
            await viewModel.loadArticles()
        }
    }
}
```

**Benefits:**
- No `@Published` needed
- Fine-grained observation (only tracks accessed properties)
- Better performance than ObservableObject
- Less boilerplate
