---
description: Run tests for the current project or feature
---

# Swift Testing

> ⛔ **DO NOT use Claude's built-in Plan mode**
>
> This command uses specialized agents:
> - Planning: `@swift-architect`, `@tca-architect`
> - Implementation: `@swift-engineer`, `@tca-engineer`, `@swiftui-specialist`
>
> Call agents via `Task(subagent_type: "swift-engineering:agent-name", ...)`.
> EnterPlanMode will break this workflow.

Create and/or run tests for Swift features.

## Invocation

- `/test` — run all tests
- `/test <feature>` — test specific feature

## When to Use

- After implementing a feature
- When adding tests to existing code
- When debugging failing tests
- Before submitting a PR

## Workflow

### 1. Determine Scope

Ask if not specified:
> "What would you like to test?
> 1. **All tests** — Run the full test suite
> 2. **Specific feature** — Name the feature or file
> 3. **Create new tests** — For code without tests"

### 2. IMMEDIATELY Invoke Test Agent

After determining scope, your VERY NEXT ACTION must be to invoke the test creator agent:

**If tests need to be created:**
```
Task(
  subagent_type: "swift-engineering:swift-test-creator",
  description: "Create tests for [feature-name]",
  prompt: "Create comprehensive tests for [feature description]. [Include requirements]"
)
```

**Otherwise, if only running tests:**
```
Task(
  subagent_type: "swift-engineering:swift-builder",
  description: "Run tests for [feature-name]",
  prompt: "Run the test suite for [feature/scope]. Report results."
)
```

⛔ **DO NOT** call `EnterPlanMode`. The agent IS the mechanism for testing.
⛔ **DO NOT** use Read, Grep, or Glob tools to search for tests yourself.

### 3. Create Tests (if needed)

```
@swift-test-creator
```

**WHY:** Creates comprehensive tests using Swift Testing framework (@Test, #expect, #require). This agent writes test code but does NOT run tests.

**What it produces:**
- Unit tests for reducers, services, clients
- Integration tests for feature flows
- TCA TestStore tests for state management
- Parameterized tests for edge cases

**BOUNDARY:** Hand off to @swift-builder when tests are written.

### 4. Run Tests

```
@swift-builder
```

**WHY:** Builds and runs the test suite. Uses Haiku for efficient mechanical work. Handles test failures and build errors.

**What it does:**
- Runs `xcodebuild test` with appropriate scheme
- Reports pass/fail status
- Offers to fix failing tests

### 5. Handle Failures

If tests fail, @swift-builder will:
1. Show failure summary with file:line locations
2. Ask if you want automatic fixes or just a report
3. Hand off to implementation agent if logic fix needed:
   - TCA issues → @tca-engineer
   - View issues → @swiftui-specialist
   - Other Swift → @swift-engineer

### 6. Completion

Summarize results:
> "✓ **Tests complete**
> - **Passed:** 42
> - **Failed:** 0
> - **Coverage:** [summary if available]"

OR if failures:
> "⚠️ **Tests incomplete**
> - **Passed:** 40
> - **Failed:** 2
> - **Issues:** [summary]
> - **Next steps:** [recommendation]"
