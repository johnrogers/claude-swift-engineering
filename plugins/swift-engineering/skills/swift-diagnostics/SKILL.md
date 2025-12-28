---
name: swift-diagnostics
description: Use when debugging NavigationStack issues (not responding, unexpected pops, crashes), build failures (SPM resolution, "No such module", hanging builds), or memory problems (retain cycles, leaks, deinit not called). Systematic diagnostic workflows for iOS/macOS.
---

# Swift Diagnostics

Systematic debugging workflows for iOS/macOS development. These patterns help identify root causes in minutes rather than hours by following structured diagnostic approaches.

## Quick Reference

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
