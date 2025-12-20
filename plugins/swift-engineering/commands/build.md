---
description: Build the project and check for errors/warnings
---

# Swift Build Verification

> ⛔ **DO NOT use Claude's built-in Plan mode**
>
> This command uses specialized agents:
> - Planning: `@swift-architect`, `@tca-architect`
> - Implementation: `@swift-engineer`, `@tca-engineer`, `@swiftui-specialist`
>
> Call agents via `Task(subagent_type: "swift-engineering:agent-name", ...)`.
> EnterPlanMode will break this workflow.

Build the project and resolve any compiler errors or warnings.

## Invocation

- `/build` — build and check for errors
- `/build --fix` — automatically attempt to fix errors

## When to Use

- After making code changes
- Before committing
- To verify a clean build
- To fix compiler errors

## Workflow

### 1. Execute Build

```
@swift-builder
```

**WHY:** Uses Haiku for efficient mechanical work. Runs xcodebuild with the appropriate scheme and simulator, parses errors/warnings, and can attempt fixes.

### 2. Handle Results

#### On Build Failure

@swift-builder will ask:
> "Build failed with X error(s). Would you like me to:
> 1. **Automatically fix** — I'll attempt to fix errors (max 3 cycles)
> 2. **Just show me** — I'll summarize errors and suggest fixes
>
> Which do you prefer?"

If "Automatically fix":
- Attempts to fix each error
- Rebuilds after fixes
- Hands off to specialist if needed after 3 attempts:
  - TCA errors → @tca-engineer
  - View errors → @swiftui-specialist
  - Test errors → @swift-test-creator
  - Other errors → @swift-engineer

If "Just show me":
- Displays condensed error summary:
  ```
  ## Build Errors (3)

  1. `Features/Profile/ProfileFeature.swift:42` — Missing conformance to `Equatable`
     → Add `Equatable` conformance to `ProfileState`

  2. `Clients/APIClient.swift:18` — Cannot convert `String` to `URL`
     → Use `URL(string:)` initializer with guard
  ```

#### On Build Success with Warnings

@swift-builder presents each warning:
> "Warning: [description] in [file]:[line]"
> "Should I fix this? (yes/no)"

Only fixes warnings you approve.

#### On Clean Build

> "✓ Build successful. No errors or warnings."

### 3. Completion

Summarize build status:
> "✓ **Build complete**
> - **Errors:** 0
> - **Warnings:** 0 (or X fixed)
> - **Status:** Clean build"

OR if issues remain:
> "⚠️ **Build incomplete**
> - **Errors:** X remaining
> - **Warnings:** Y remaining
> - **Next steps:** [recommendation]"

## Common Error Patterns

@swift-builder knows how to fix:

| Error | Fix |
|-------|-----|
| `Cannot find type 'X' in scope` | Add missing import |
| `Sending 'value' risks causing data races` | Add Sendable or isolate to actor |
| `Cannot convert value of type 'X' to 'Y'` | Add explicit conversion |
| `Missing return` | Add return statement |
| `Value of type 'X' has no member 'Y'` | Check spelling or add extension |
