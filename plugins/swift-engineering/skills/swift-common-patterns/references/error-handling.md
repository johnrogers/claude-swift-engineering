# Error Handling Patterns

**Use for:** Domain-specific errors with context

**Problem:** Need rich error information for debugging and user messages.

**Solution:**
```swift
// Domain-specific error types
enum ArticleError: Error, LocalizedError {
    case notFound(id: String)
    case invalidData(reason: String)
    case networkFailure(underlying: Error)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .notFound(let id):
            return "Article '\(id)' not found"
        case .invalidData(let reason):
            return "Invalid article data: \(reason)"
        case .networkFailure(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized:
            return "Authentication required"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .notFound:
            return "Try searching for a different article"
        case .invalidData:
            return "Contact support if this persists"
        case .networkFailure:
            return "Check your internet connection"
        case .unauthorized:
            return "Please sign in"
        }
    }
}

// Usage
func fetchArticle(id: String) async throws -> Article {
    guard let url = URL(string: "https://api.example.com/articles/\(id)") else {
        throw ArticleError.invalidData(reason: "Invalid article ID")
    }

    do {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ArticleError.networkFailure(underlying: URLError(.badServerResponse))
        }

        switch httpResponse.statusCode {
        case 200...299:
            return try JSONDecoder().decode(Article.self, from: data)
        case 401:
            throw ArticleError.unauthorized
        case 404:
            throw ArticleError.notFound(id: id)
        default:
            throw ArticleError.networkFailure(underlying: URLError(.badServerResponse))
        }
    } catch let error as ArticleError {
        throw error
    } catch {
        throw ArticleError.networkFailure(underlying: error)
    }
}
```

**Benefits:**
- User-friendly error messages
- Contextual error information
- Recovery suggestions
- Type-safe error handling
