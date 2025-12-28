# Structured Output with @Generable

## Why @Generable Over JSON

Manual JSON parsing fails unpredictably:

```swift
// BAD - Model might output wrong keys or invalid JSON
let response = try await session.respond(to: "Generate person as JSON")
let person = try JSONDecoder().decode(Person.self, from: data) // CRASHES!
```

@Generable uses constrained decoding - model can only generate valid structure:

```swift
@Generable
struct Person {
    let name: String
    let age: Int
}

let response = try await session.respond(
    to: "Generate a person",
    generating: Person.self
)
let person = response.content // Guaranteed valid Person
```

## Supported Types

```swift
@Generable
struct Example {
    let text: String           // Primitives
    let count: Int
    let isActive: Bool
    let items: [String]        // Arrays
    let plan: DayPlan          // Nested @Generable types
}

@Generable
enum Encounter {               // Enums with associated values
    case order(item: String)
    case complaint(reason: String)
}
```

## @Guide Constraints

```swift
@Generable
struct Character {
    @Guide(description: "A full name")
    let name: String

    @Guide(.range(1...10))
    let level: Int

    @Guide(.count(4))
    var searchTerms: [String]   // Exactly 4 items

    @Guide(.maximumCount(3))
    let topics: [String]        // Up to 3 items
}
```

**Regex patterns:**
```swift
@Guide(Regex {
    ChoiceOf { "Mr"; "Mrs" }
    ". "
    OneOrMore(.word)
})
let name: String  // Output: "Mrs. Brewster"
```

## Property Order Matters

Properties generate in declaration order. Put summaries last:

```swift
@Generable
struct Itinerary {
    var destination: String  // Generated first
    var days: [DayPlan]      // Generated second
    var summary: String      // Generated last (references days)
}
```

## Skip Schema on Subsequent Requests

```swift
// First request - schema inserted automatically
let first = try await session.respond(to: "Generate person", generating: Person.self)

// Subsequent - skip schema for 10-20% speedup
let second = try await session.respond(
    to: "Generate another",
    generating: Person.self,
    options: GenerationOptions(includeSchemaInPrompt: false)
)
```

## Content Tagging Adapter

```swift
let session = LanguageModelSession(
    model: SystemLanguageModel(useCase: .contentTagging)
)

@Generable
struct TagResult {
    @Guide(.maximumCount(5))
    let topics: [String]
}

let result = try await session.respond(to: article, generating: TagResult.self)
```
