# Modern Networking Architecture

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
