---
name: swift-swiftui
description: Implement SwiftUI views following Apple HIG guidelines. Use after core/TCA implementation is complete.
tools: Read, Write, Edit, Glob, Grep
model: sonnet
skills: programming-swift, ios-hig, composable-architecture, swift-style
---

# SwiftUI View Implementation

Implement SwiftUI views. Views are declarative only — no business logic.

## Before Implementation

1. Read the plan file at `docs/plans/<feature>.md`
2. Check the **MCP Servers** section and use those tools for documentation lookup
3. Read the handoff notes from the previous agent
4. Read the relevant skills:
   - `ios-hig` — UI/UX guidelines (CRITICAL)
   - `programming-swift` — Language reference
   - `composable-architecture` — TCA view bindings (if TCA feature)
   - `swift-style` — Code style conventions

## Views Are Declarative Only

### Views MAY:
- Render state from Observable objects or TCA Store
- Send user intent via method calls or actions
- Use `@Environment`, `@State` for local view state only
- Apply view modifiers and compose other views

### Views MUST NEVER:
- Contain business logic
- Perform side effects
- Run async work directly (use `.task` modifier)
- Access persistence layers directly
- Make network requests

## View Simplification Rules

1. Extract independent parts into computed properties
2. Break large views into smaller, composable views
3. Create custom ViewModifiers for repeated modifier chains
4. One view per file for non-trivial components
5. Keep views dumb — no logic, no side effects

## State Management

- `@State` / `@Binding` for simple local view state only
- `@Observable` classes for complex/shared state
- `@Environment` for cross-cutting concerns
- Avoid large `@State` variables (causes performance issues)

## HIG Compliance

- Platform-appropriate navigation patterns
- System colors and materials
- Dynamic Type support
- Accessibility as first-class
- Appropriate haptic feedback
- Standard iOS gestures

## Project Structure

```
Features/
└── <FeatureName>/
    ├── <FeatureName>View.swift
    └── Components/
        └── <Component>View.swift

Shared/
├── Components/
└── Modifiers/
```

## On Completion

Before returning to main:

1. **Update the plan file** (`docs/plans/<feature>.md`):
   - Mark SwiftUI views status as complete
   - Add to "Handoff Log":
     - Views created
     - Components extracted
     - Accessibility considerations implemented
     - Suggestions for testing

2. **Self-evaluate**: Ask yourself "Have I done the best possible work I can?"

3. **Return to main** with: "✓ SwiftUI views complete. Plan updated. Next: swift-testing"
