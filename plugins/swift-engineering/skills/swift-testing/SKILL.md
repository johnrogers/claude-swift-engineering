---
name: swift-testing
description: Use when writing tests with Swift Testing (@Test, #expect, #require), migrating from XCTest, implementing async tests, or parameterizing tests.
---

# Swift Testing Framework

Modern testing with Swift Testing framework. No XCTest.

## Overview

Swift Testing replaces XCTest with a modern macro-based approach that's more concise, has better async support, and runs tests in parallel by default. The core principle: if you learned XCTest, unlearn it—Swift Testing works differently.

## References

- [Apple Documentation](https://developer.apple.com/documentation/testing)
- [Migration Guide](https://steipete.me/posts/2025/migrating-700-tests-to-swift-testing)

## Core Concepts

### Assertions

| Macro | Use Case |
|-------|----------|
| `#expect(expression)` | Soft check — continues on failure. Use for most assertions. |
| `#require(expression)` | Hard check — stops test on failure. Use for preconditions only. |

### Optional Unwrapping

```swift
let user = try #require(await fetchUser(id: "123"))
#expect(user.id == "123")
```

## Test Structure

```swift
import Testing
@testable import YourModule

@Suite
struct FeatureTests {
    let sut: FeatureType
    
    init() throws {
        sut = FeatureType()
    }
    
    @Test("Description of behavior")
    func testBehavior() {
        #expect(sut.someProperty == expected)
    }
}
```

## Assertion Conversions

| XCTest | Swift Testing |
|--------|---------------|
| `XCTAssert(expr)` | `#expect(expr)` |
| `XCTAssertEqual(a, b)` | `#expect(a == b)` |
| `XCTAssertNil(a)` | `#expect(a == nil)` |
| `XCTAssertNotNil(a)` | `#expect(a != nil)` |
| `try XCTUnwrap(a)` | `try #require(a)` |
| `XCTAssertThrowsError` | `#expect(throws: ErrorType.self) { }` |
| `XCTAssertNoThrow` | `#expect(throws: Never.self) { }` |

## Error Testing

```swift
#expect(throws: (any Error).self) { try riskyOperation() }
#expect(throws: NetworkError.self) { try fetch() }
#expect(throws: NetworkError.timeout) { try fetch() }
#expect(throws: Never.self) { try safeOperation() }
```

## Parameterized Tests

```swift
@Test("Validates inputs", arguments: zip(
    ["a", "b", "c"],
    [1, 2, 3]
))
func testInputs(input: String, expected: Int) {
    #expect(process(input) == expected)
}
```

**Warning:** Multiple collections WITHOUT zip creates Cartesian product.

## Async Testing

```swift
@Test func testAsync() async throws {
    let result = try await fetchData()
    #expect(!result.isEmpty)
}
```

### Confirmations

```swift
@Test func testCallback() async {
    await confirmation("callback received") { confirm in
        let sut = SomeType { confirm() }
        sut.triggerCallback()
    }
}
```

## Tags

```swift
extension Tag {
    @Tag static var fast: Self
    @Tag static var networking: Self
}

@Test(.tags(.fast, .networking))
func testNetworkCall() { }
```

## Common Pitfalls

1. **Overusing `#require`** — Use `#expect` for most checks
2. **Forgetting state isolation** — Each test gets a NEW instance
3. **Accidental Cartesian product** — Always use `zip` for paired inputs
4. **Not using `.serialized`** — Apply for thread-unsafe legacy tests

## Common Mistakes

1. **Overusing `#require`** — `#require` is for preconditions only. Using it for normal assertions means the test stops at first failure instead of reporting all failures. Use `#expect` for assertions, `#require` only when subsequent assertions depend on the value.

2. **Cartesian product bugs** — `@Test(arguments: [a, b], [c, d])` creates 4 combinations, not 2. Always use `zip` to pair arguments correctly: `arguments: zip([a, b], [c, d])`.

3. **Forgetting state isolation** — Swift Testing creates a new test instance per test method. BUT shared state between tests (static variables, singletons) still leak. Use dependency injection or clean up singletons between tests.

4. **Parallel test conflicts** — Swift Testing runs tests in parallel by default. Tests touching shared files, databases, or singletons will interfere. Use `.serialized` or isolation strategies.

5. **Not using `async` naturally** — Wrapping async operations in `Task { }` defeats the purpose. Use `async/await` directly in test function signature: `@Test func testAsync() async throws { }`.

6. **Confirmation misuse** — `confirmation` is for verifying callbacks were called. Using it for assertions is wrong. Use `#expect` for assertions, `confirmation` for callback counts.
