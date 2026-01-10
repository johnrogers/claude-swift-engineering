---
name: swift-diagnostics
description: Use when debugging NavigationStack issues (not responding, unexpected pops, crashes), build failures (SPM resolution, "No such module", hanging builds), or memory problems (retain cycles, leaks, deinit not called). Systematic diagnostic workflows for iOS/macOS.
---

# Swift Diagnostics

Systematic debugging workflows for iOS/macOS development. These patterns help identify root causes in minutes rather than hours by following structured diagnostic approaches.

## Reference Loading Guide

**ALWAYS load reference files if there is even a small chance the content may be required.** It's better to have the context than to miss a pattern or make a mistake.

| Reference | Load When |
|-----------|-----------|
| **[Navigation](references/navigation.md)** | NavigationStack not responding, unexpected pops, deep link failures |
| **[Build Issues](references/build-issues.md)** | SPM resolution, "No such module", dependency conflicts |
| **[Memory](references/memory.md)** | Retain cycles, memory growth, deinit not called |
| **[Build Performance](references/build-performance.md)** | Slow builds, Derived Data issues, Xcode hangs |
| **[Xcode Debugging](references/xcode-debugging.md)** | LLDB commands, breakpoints, view debugging |

## Core Workflow

1. **Identify symptom category** - Navigation, build, memory, or performance
2. **Load the relevant reference** - Each has diagnostic decision trees
3. **Run mandatory first checks** - Before changing any code
4. **Follow the decision tree** - Reach diagnosis in 2-5 minutes
5. **Apply fix and verify** - One fix at a time, test each

## Key Principle

80% of "mysterious" issues stem from predictable patterns:
- Navigation: Path state management or destination placement
- Build: Stale caches or dependency resolution
- Memory: Timer/observer leaks or closure captures
- Performance: Environment problems, not code bugs

Diagnose systematically. Never guess.

## Common Mistakes

1. **Skipping mandatory first checks** — Jumping straight to code changes before running diagnostics (clean build, restart simulator, restart Xcode) means you'll chase ghosts. Always start with the mandatory checks.

2. **Changing multiple things at once** — "Let me delete DerivedData AND restart simulator AND kill Xcode" means you can't isolate which fix actually worked. Change one variable at a time.

3. **Assuming you know the cause** — "NavigationStack stopped working, must be my reducer" — actually it was stale DerivedData. Diagnostic trees prevent assumptions. Follow the tree, don't guess.

4. **Missing memory basics** — Calling `deinit` not being called is a retain cycle, but beginners often blame architecture. Use Instruments to verify leaks before refactoring. Data, not intuition.

5. **Not isolating the problem** — Testing with your whole app complicates diagnosis. Create a minimal reproducible example with just the problematic feature. Isolation reveals root causes.
