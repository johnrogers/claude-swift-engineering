---
description: Common Swift architecture patterns — DefaultProvider, type-safe resolution, actors, DI, networking
---

# Swift Common Patterns

Essential architecture patterns for modern Swift development. Use these patterns to build maintainable, type-safe, concurrent applications.

## DefaultProvider Protocol Pattern

**Use for:** Configuration types, theme tokens, style objects, default values

**Problem:** Need consistent defaults and easy comparison across configuration types.

**Solution:**
```swift
public protocol DefaultProvider: Sendable {
    static var defaultValue: Self { get }
    var isDefault: Bool { get }
}

// Implementation
public struct ArticleCardConfig: DefaultProvider, Sendable {
    public static let defaultValue = ArticleCardConfig(
        showThumbnail: true,
        titleLines: 2,
        showAuthor: true
    )

    public var isDefault: Bool {
        self == .defaultValue
    }

    public let showThumbnail: Bool
    public let titleLines: Int
    public let showAuthor: Bool
}

// Usage
let config: ArticleCardConfig = .defaultValue
if config.isDefault {
    // Use optimized rendering
}
```

**Benefits:**
- Consistent default pattern across all config types
- Easy to check if using default (no magic values)
- Sendable compliance built-in
- Self-documenting code

## ConcreteResolvable Pattern (Type-Safe Token Resolution)

**Use for:** Theme tokens, design systems, configuration resolution with fallbacks

**Problem:** Need type-safe resolution of design tokens with graceful fallbacks, no runtime casting.

**Solution:**
```swift
// Phantom type pattern: Resolvable → Concrete transformation
public protocol ConcreteResolvable: Sendable {
    associatedtype C: Sendable & DefaultProvider
    func resolveConcrete(in resolver: ThemeResolver, for context: ThemeContext) throws -> C
}

// Token type (resolvable)
public struct ColorToken: ConcreteResolvable, Sendable {
    public typealias C = UIColor

    let tokenPath: String

    public func resolveConcrete(in resolver: ThemeResolver, for context: ThemeContext) throws -> UIColor {
        // Try to resolve from theme
        if let color = try? resolver.resolveColor(tokenPath, context: context) {
            return color
        }
        // Fallback to default
        return UIColor.defaultValue
    }
}

// Usage
extension UIColor: DefaultProvider {
    public static var defaultValue: UIColor { .systemGray }
    public var isDefault: Bool { self == .systemGray }
}

let token = ColorToken(tokenPath: "semantic.background.base")
let resolvedColor = try token.resolveConcrete(in: themeResolver, for: .light) // UIColor
```

**Benefits:**
- Compile-time type safety (no runtime casting)
- Graceful fallback to defaults
- Works with any Sendable + DefaultProvider type
- Phantom type ensures correct resolution

## Actor-Isolated Managers

**Use for:** Shared mutable state, network services, database managers, caches

**Problem:** Need thread-safe shared state without locks or serial queues.

**Solution:**
```swift
public actor NetworkService: Sendable {
    private let session: URLSession
    private var cache: [String: Data] = [:]

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        // Check cache first
        if let cached = cache[url.absoluteString],
           let decoded = try? JSONDecoder().decode(T.self, from: cached) {
            return decoded
        }

        // Fetch from network
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }

        // Cache result
        cache[url.absoluteString] = data

        return try JSONDecoder().decode(T.self, from: data)
    }

    public func clearCache() {
        cache.removeAll()
    }
}

enum NetworkError: Error {
    case httpError(Int)
}

// Usage
let networkService = NetworkService()

Task {
    let articles = try await networkService.fetch([Article].self, from: articlesURL)
    // Actor-isolated, thread-safe by default
}
```

**Benefits:**
- No explicit locks needed
- Thread-safe by default
- Clear actor boundaries
- Sendable compliance automatic

## Model-ViewModel-View Pattern (SwiftUI)

**Use for:** Complex views with computed properties based on environment

**Problem:** Need to compute view data from model + environment without re-computation.

**Solution:**
```swift
struct ArticleCard: View {
    // Immutable model (passed down)
    struct Model: Sendable {
        let article: Article
        let style: CardStyle
    }

    // Environment-reactive ViewModel (computed once)
    @Environment(\.designSystem) private var designSystem

    var viewModel: ViewModel {
        ViewModel(model: model, designSystem: designSystem)
    }

    struct ViewModel {
        let title: String
        let imageURL: URL?
        let backgroundColor: Color
        let foregroundColor: Color

        init(model: Model, designSystem: DesignSystem) {
            self.title = model.article.title
            self.imageURL = model.article.imageURL
            self.backgroundColor = designSystem.colorTokens.semanticBackgroundBase.color
            self.foregroundColor = designSystem.colorTokens.semanticForegroundBase.color
        }
    }

    let model: Model

    var body: some View {
        VStack(alignment: .leading) {
            if let imageURL = viewModel.imageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 200)
            }

            Text(viewModel.title)
                .foregroundColor(viewModel.foregroundColor)
        }
        .background(viewModel.backgroundColor)
    }
}
```

**Benefits:**
- Clear separation: Model (data) → ViewModel (presentation) → View (rendering)
- ViewModel recomputes when environment changes
- No business logic in View
- Testable ViewModels

## Environment-Based Dependency Injection

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

## Modern Networking Architecture

**Use for:** API clients, RESTful services, async networking

**Problem:** Need clean async/await networking without third-party dependencies.

**Solution:**
```swift
// Actor-based network service
actor APIClient: Sendable {
    private let session: URLSession
    private let baseURL: URL

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func fetch<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

// Endpoint definition
struct Endpoint {
    let path: String
    let method: HTTPMethod
    let body: (any Encodable)?

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
}

enum APIError: Error {
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
}

// Usage
let api = APIClient(baseURL: URL(string: "https://api.example.com")!)

Task {
    let articles = try await api.fetch(
        Endpoint(path: "/articles", method: .get, body: nil),
        as: [Article].self
    )
}
```

**Benefits:**
- No external dependencies (no Alamofire/Moya)
- Actor isolation for thread safety
- Clean async/await patterns
- Type-safe endpoints

## Error Handling Patterns

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

## When to Use Each Pattern

| Pattern | Use When | Don't Use When |
|---------|----------|----------------|
| DefaultProvider | Config types, tokens, styles | Simple primitives |
| ConcreteResolvable | Theme systems, token resolution | Direct value access |
| Actor-Isolated Managers | Shared mutable state | Read-only data |
| Model-ViewModel-View | Complex view computations | Simple views |
| Environment DI | App-wide services | Local state |
| Modern Networking | API clients | Simple URL fetches |
| Domain Errors | User-facing errors | Internal assertions |

## Quick Reference

```swift
// Default values
struct Config: DefaultProvider { static let defaultValue = Config() }

// Type-safe resolution
protocol Resolvable { associatedtype C: DefaultProvider }

// Thread safety
actor Service { private var cache: [String: Data] = [:] }

// View architecture
struct CardView: View {
    struct Model { let data: Data }
    struct ViewModel { init(model: Model, env: Env) }
}

// Dependency injection
extension EnvironmentValues { @Entry var service: Service = .default }

// Networking
actor APIClient { func fetch<T: Decodable>() async throws -> T }

// Errors
enum DomainError: Error, LocalizedError { var errorDescription: String? }
```
