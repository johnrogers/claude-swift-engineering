---
description: Run tests for the current project or feature
---

# Swift Test

Run tests and report results.

## Invocation

- `/swift-test` — run all tests
- `/swift-test <feature-name>` — run tests for specific feature

## Workflow

### 1. Run Tests

```
@swift-build
```
Run in test mode: detect simulator, run `xcodebuild test`, capture results.

### 2. Report Results

**On success:**
> "✓ All tests passing (X tests in Y seconds)"

**On failure:**
> "✗ X test(s) failed:
>
> 1. `testSomeBehavior` in `FeatureTests.swift:42`
>    - Expected: X
>    - Actual: Y
>
> Would you like me to attempt to fix these?"

### 3. Handle Failures

If user wants fixes:
```
@swift-testing
```
Analyze and fix failing tests, then re-run.

If user declines:
- Provide summary only
