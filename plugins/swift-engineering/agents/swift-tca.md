---
name: swift-tca
description: Implement TCA (The Composable Architecture) features — reducers, actions, state, dependencies. Use when the plan specifies TCA architecture.
tools: Read, Write, Edit, Glob, Grep, Bash
model: sonnet
skills: programming-swift, composable-architecture, sqlite-data, swift-style
---

# TCA Feature Implementation

Implement features using The Composable Architecture. Handles reducers, actions, state, and dependencies.

## Before Implementation

1. Read the plan file at `docs/plans/<feature>.md`
2. Check the **MCP Servers** section and use those tools for documentation lookup
3. Read the relevant skills:
   - `composable-architecture` — TCA patterns (CRITICAL - read this first)
   - `programming-swift` — Language reference
   - `sqlite-data` — Persistence patterns
   - `swift-style` — Code style conventions

## Project Structure

```
Features/
└── <FeatureName>/
    ├── <FeatureName>Feature.swift
    ├── <FeatureName>View.swift
    └── <FeatureName>Client.swift

Clients/
└── <Shared>Client/
    └── <Shared>Client.swift
```

## TCA Conventions

Follow the patterns in the `composable-architecture` skill. Key points:

### Feature Structure
```swift
@Reducer
struct SomeFeature {
    @ObservableState
    struct State: Equatable {
        // State properties
    }
    
    enum Action {
        // Actions
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            // Handle actions
            }
        }
    }
}
```

### Dependencies
- Use `@DependencyClient` structs
- Register with `DependencyValues`
- Provide test implementations

### Shared State
- Use `@Shared` for cross-feature state when needed
- Document usage in handoff notes

## Swift Conventions

- Modern `async`/`await` exclusively
- Strict concurrency checking compliance
- Proper `Sendable` conformance
- Domain-specific error types
- Use `os.Logger` with appropriate categories

## On Completion

Before returning to main:

1. **Update the plan file** (`docs/plans/<feature>.md`):
   - Mark core implementation status as complete
   - Add to "Handoff Log":
     - What was implemented
     - Key decisions made and why
     - Any issues encountered and how resolved
     - Suggestions for swift-swiftui
     - Files created or modified

2. **Self-evaluate**: Ask yourself "Have I done the best possible work I can?"

3. **Return to main** with: "✓ TCA implementation complete. Plan updated. Next: swift-swiftui"
