# Getting Started with Foundation Models

## Availability Check

Always check before creating a session:

```swift
import FoundationModels

switch SystemLanguageModel.default.availability {
case .available:
    print("Foundation Models available")
case .unavailable(let reason):
    print("Unavailable: \(reason)")
}
```

**Requirements:** iPhone 15 Pro+, M1+ iPad/Mac, supported region, user opted in.

## Creating a Session

```swift
// Basic
let session = LanguageModelSession()

// With instructions (define model's role)
let session = LanguageModelSession(instructions: """
    You are a helpful travel assistant.
    Respond concisely.
    """
)
```

**Important:** Never interpolate user input into instructions (security risk).

## Basic Text Generation

```swift
let session = LanguageModelSession()
let response = try await session.respond(to: "Summarize this article...")
print(response.content)
```

## Multi-Turn Conversations

Sessions retain transcript automatically:

```swift
let session = LanguageModelSession()

let first = try await session.respond(to: "Write a haiku about fishing")
// "Silent waters gleam..."

let second = try await session.respond(to: "Now one about golf")
// Model remembers context from first turn
```

## Preventing Concurrent Requests

```swift
Button("Generate") {
    Task {
        result = try await session.respond(to: "Write a haiku").content
    }
}
.disabled(session.isResponding)
```

## Prewarming for Performance

First generation takes 1-2s to load. Prewarm before user interaction:

```swift
class ViewModel: ObservableObject {
    private var session: LanguageModelSession?

    init() {
        Task { self.session = LanguageModelSession() }
    }

    func generate(prompt: String) async throws -> String {
        try await session!.respond(to: prompt).content
    }
}
```

## SwiftUI Availability Pattern

```swift
struct AIFeatureView: View {
    var body: some View {
        switch SystemLanguageModel.default.availability {
        case .available:
            AIContentView()
        case .unavailable:
            Text("AI features require Apple Intelligence")
        }
    }
}
```

## Model Specifications

- **Context Window:** 4096 tokens (~12,000 chars)
- **Good for:** Summarization, extraction, classification
- **Not for:** World knowledge, complex reasoning
