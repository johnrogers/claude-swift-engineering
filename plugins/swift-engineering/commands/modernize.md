---
description: Migrate legacy Swift patterns to modern best practices — async/await, modern APIs, SwiftUI
---

# Swift Modernization

> ⛔ **DO NOT use Claude's built-in Plan mode**
>
> This command uses specialized agents:
> - Planning: `@swift-architect`, `@tca-architect`
> - Implementation: `@swift-engineer`, `@tca-engineer`, `@swiftui-specialist`
>
> Call agents via `Task(subagent_type: "swift-engineering:agent-name", ...)`.
> EnterPlanMode will break this workflow.

Migrate legacy Swift code to modern best practices.

## Invocation

- `/modernize` — analyze codebase for modernization opportunities
- `/modernize <file-or-folder>` — modernize specific code
- `/modernize --pattern <pattern>` — migrate specific pattern (e.g., "rxswift", "callbacks")

## When to Use

- Migrating RxSwift to async/await
- Updating deprecated APIs
- Converting completion handlers to async/await
- Migrating UIKit to SwiftUI
- Adopting Swift concurrency
- Updating to Swift 6.2+ patterns

## Workflow

### 1. Gather Scope

Ask if not specified:
> "What would you like to modernize?
> 1. **Specific file/folder** — Target specific code
> 2. **Specific pattern** — e.g., 'RxSwift to async/await', 'UIKit to SwiftUI'
> 3. **Full audit** — Scan entire codebase for modernization opportunities"

### 2. Analyze

```
@swift-modernizer
```

**WHY:** Expert in legacy patterns and modern replacements. Preserves functionality while updating to current Swift best practices. Uses `programming-swift` skill for language reference when needed.

### 3. Migration Report

@swift-modernizer produces an analysis:

```markdown
## Modernization Analysis

### High Impact Migrations
1. **RxSwift → async/await**
   - Files affected: 12
   - Effort: Medium
   - Risk: Low (mechanical replacement)
   - Impact: Remove 10MB dependency

2. **Completion handlers → async/await**
   - Files affected: 8
   - Effort: Low
   - Risk: Low
   - Impact: Cleaner code, better error handling

### Medium Impact Migrations
1. **UIColor(named:) → Design tokens**
   - Files affected: 45
   - Effort: Medium
   - Risk: Low

### Deprecated API Replacements
1. `onChange(of:perform:)` → `onChange(of:initial:_:)`
2. `UIDevice.current.userInterfaceIdiom` → Environment check
```

### 4. Execute Migration

Ask:
> "Which migrations would you like to proceed with?
> - All migrations
> - Specific migrations (list numbers)
> - None (just the report)"

@swift-modernizer implements changes using safe, incremental patterns:
- One logical change at a time
- Preserve existing behavior
- Maintain backward compatibility where needed
- Create clear git commits

### 5. Verify

```
@swift-builder
```

**WHY:** Ensure modernized code compiles and tests pass. Catch any issues introduced by migration.

### 6. Completion

Summarize results:
> "✓ **Modernization complete**
> - **Patterns migrated:** 3
> - **Files updated:** 28
> - **Dependencies removed:** RxSwift
> - **Build status:** Passing
> - **Tests status:** Passing"

OR if issues:
> "⚠️ **Modernization incomplete**
> - **Completed:** 2/3 patterns
> - **Issues:** [summary]
> - **Next steps:** [recommendation]"

## Common Migrations

@swift-modernizer handles these patterns:

### Concurrency
| Legacy | Modern |
|--------|--------|
| Completion handlers | async/await |
| DispatchQueue.main | @MainActor |
| Shared mutable state | Actor isolation |
| DispatchGroup | TaskGroup |

### Reactive
| Legacy | Modern |
|--------|--------|
| RxSwift Observable | AsyncSequence / async/await |
| Combine Publisher | AsyncSequence (where appropriate) |
| NotificationCenter | @Observable + onChange |

### UI
| Legacy | Modern |
|--------|--------|
| UIKit view controllers | SwiftUI views |
| UIColor(named:) | Color assets / design tokens |
| Storyboards | SwiftUI declarative |
| Auto Layout (code) | SwiftUI layout |

### APIs
| Legacy | Modern |
|--------|--------|
| URLSession callbacks | async URLSession |
| Codable with manual keys | Modern Codable |
| Force-unwrapped optionals | Safe unwrapping |
| Implicit returns | Explicit where clearer |
