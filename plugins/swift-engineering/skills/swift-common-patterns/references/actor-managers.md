# Actor-Isolated Managers

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
