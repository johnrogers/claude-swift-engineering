---
description: Run tests for the current project or feature
---

# Swift Testing

> ⛔ **DO NOT use Claude's built-in Plan mode or direct tool usage**
>
> This command delegates to specialized agents:
> - **@swift-test-creator** — Creates comprehensive tests using Swift Testing framework
> - **@swift-builder** — Runs tests and reports results
> - **@tca-engineer** — Fixes TCA test issues if needed
> - **@swiftui-specialist** — Fixes SwiftUI test issues if needed
> - **@swift-engineer** — Fixes general Swift test issues if needed
>
> <!-- MAINTENANCE: Keep this agent list in sync with available agents in plugin.yaml -->

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

### 2. Invoke Test Agent

After determining scope, immediately delegate to the appropriate agent:

**If tests need to be created:** Delegate to **@swift-test-creator**.

**WHY:** @swift-test-creator creates comprehensive tests using Swift Testing framework (@Test, #expect, #require). Produces:
- Unit tests for reducers, services, clients
- Integration tests for feature flows
- TCA TestStore tests for state management
- Parameterized tests for edge cases

**Otherwise, if only running tests:** Delegate to **@swift-builder**.

⛔ **DO NOT** call `EnterPlanMode`
⛔ **DO NOT** use Read, Grep, or Glob tools to search for tests yourself

### 3. Run Tests

**@swift-test-creator** hands off to **@swift-builder** when tests are written.

**@swift-builder** builds and runs the test suite. Uses Haiku for efficient mechanical work. Handles test failures and build errors.

**What it does:**
- Runs `xcodebuild test` with appropriate scheme
- Reports pass/fail status
- Offers to fix failing tests

### 4. Handle Failures

If tests fail, **@swift-builder** will:
1. Show failure summary with file:line locations
2. Ask if you want automatic fixes or just a report
3. Hand off to implementation agent if logic fix needed:
   - TCA issues → **@tca-engineer**
   - View issues → **@swiftui-specialist**
   - Other Swift → **@swift-engineer**

### 5. Completion

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
