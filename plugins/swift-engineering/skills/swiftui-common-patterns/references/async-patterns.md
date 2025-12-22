# Async Operation Patterns

## Task Modifier

**Use for:** Loading data when view appears

```swift
struct ArticleDetailView: View {
    let articleId: String
    @State private var article: Article?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let article {
                ArticleContent(article: article)
            } else if isLoading {
                ProgressView()
            } else {
                ContentUnavailableView("Article Not Found", systemImage: "doc.text")
            }
        }
        .task {
            await loadArticle()
        }
    }

    private func loadArticle() async {
        isLoading = true
        defer { isLoading = false }

        do {
            article = try await articleService.fetchArticle(id: articleId)
        } catch {
            print("Error loading article: \(error)")
        }
    }
}
```

## Refreshable Content

**Use for:** Pull-to-refresh lists

```swift
struct ArticleListView: View {
    @State private var articles: [Article] = []

    var body: some View {
        List(articles) { article in
            ArticleRow(article: article)
        }
        .refreshable {
            await refreshArticles()
        }
    }

    private func refreshArticles() async {
        do {
            articles = try await articleService.fetchArticles()
        } catch {
            print("Error refreshing: \(error)")
        }
    }
}
```

## Background Tasks

**Use for:** Non-blocking async operations

```swift
struct ArticleDetailView: View {
    let article: Article
    @State private var isSaved = false

    var body: some View {
        ArticleContent(article: article)
            .toolbar {
                Button(isSaved ? "Saved" : "Save") {
                    Task {
                        await saveArticle()
                    }
                }
            }
    }

    private func saveArticle() async {
        do {
            try await articleService.saveArticle(article)
            isSaved = true
        } catch {
            print("Error saving: \(error)")
        }
    }
}
```
