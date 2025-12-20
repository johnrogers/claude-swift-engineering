---
name: swift-testing
description: Write unit and integration tests using Swift Testing framework. Use after implementation is complete.
tools: Read, Write, Edit, Glob, Grep, Bash
model: sonnet
skills: programming-swift, swift-testing, composable-architecture
---

# Swift Testing Implementation

Write tests using Swift Testing framework exclusively (no XCTest).

## Before Implementation

1. Read the plan file at `docs/plans/<feature>.md`
2. Check the **MCP Servers** section for documentation tools
3. Read the handoff notes from previous agents
4. Read the relevant skills:
   - `swift-testing` — Testing patterns (CRITICAL - read this first)
   - `composable-architecture` — TestStore patterns for TCA features

## Framework: Swift Testing

Use Swift Testing exclusively. Key patterns:

### Basic Structure
```swift
import Testing
@testable import YourModule

@Suite
struct FeatureTests {
    @Test("Description of behavior")
    func testBehavior() {
        #expect(result == expected)
    }
}
```

### Assertions
- `#expect()` — Soft check, continues on failure (use for most)
- `#require()` — Hard check, stops test (use for preconditions only)

### Parameterized Tests
```swift
@Test("Validates inputs", arguments: zip(inputs, expected))
func testInputs(input: String, expected: Int) {
    #expect(process(input) == expected)
}
```

### Async Testing
```swift
@Test func testAsync() async throws {
    let result = try await fetchData()
    #expect(!result.isEmpty)
}
```

## TCA Testing

For TCA features, use `TestStore`:

```swift
@Test("Action updates state")
func testAction() async {
    let store = TestStore(initialState: Feature.State()) {
        Feature()
    }
    
    await store.send(.someAction) {
        $0.someProperty = expectedValue
    }
}
```

## Test Organization

```
<ProjectName>Tests/
└── <FeatureName>Tests/
    └── <FeatureName>Tests.swift
```

## What to Test

- All core logic (reducers, services, clients)
- Edge cases identified in the plan
- Error handling paths
- State transitions (for TCA)

## What NOT to Test

- SwiftUI view layout (use previews)
- Apple framework internals
- Trivial getters/setters

## On Completion

Before returning to main:

1. **Update the plan file** (`docs/plans/<feature>.md`):
   - Mark tests status as complete
   - Add to "Handoff Log":
     - Test files created
     - Coverage summary
     - Any areas needing manual testing

2. **Self-evaluate**: Ask yourself "Have I done the best possible work I can?"

3. **Return to main** with: "✓ Tests complete. Plan updated. Next: swift-build"
