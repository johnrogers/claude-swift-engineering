---
description: Build the project and check for errors/warnings
---

# Swift Build

Verify the project builds and optionally address warnings/errors.

## Invocation

- `/swift-build` — build and report

## Workflow

### 1. Build Project

```
@swift-build
```
Detect simulator, run `xcodebuild`, capture output.

### 2. Handle Build Failure

**ALWAYS ASK FIRST:**
> "Build failed with X error(s). Would you like me to:
> 1. **Automatically fix** — max 3 cycles
> 2. **Just show me** — summarize with suggested fixes
>
> Which do you prefer?"

### 3. Handle Warnings

For each warning, ask:
> "Warning: [description] in [file]:[line]"
> "Should I fix this? (yes/no)"

Only fix approved warnings.

### 4. Report Success

> "✓ Build successful. No errors or warnings."
