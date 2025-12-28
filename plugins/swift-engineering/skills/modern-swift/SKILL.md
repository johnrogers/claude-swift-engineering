---
name: modern-swift
description: Swift 6.2 concurrency essentials — async/await, actors, @MainActor, Sendable
---

# Modern Swift (6.2+)

## Quick Reference

| Need | Use | NOT |
|------|-----|-----|
| Async operation | `async/await` | Completion handlers |
| Main thread work | `@MainActor` | `DispatchQueue.main` |
| Shared mutable state | `actor` | Locks, serial queues |
| Parallel tasks | `TaskGroup` | `DispatchGroup` |
| Thread safety | `Sendable` | `@unchecked` everywhere |

## Core Workflow

When writing async Swift code:
1. Mark async functions with `async`, call with `await`
2. Apply `@MainActor` to view models and UI-updating code
3. Use `actor` instead of locks for shared mutable state
4. Check `Task.isCancelled` or call `Task.checkCancellation()` in loops
5. Enable strict concurrency in Package.swift for compile-time safety

## References

Load these based on what you need:
- **[Concurrency Essentials](references/concurrency-essentials.md)** — Load when writing new async code or converting completion handlers
- **[Swift 6 Concurrency](references/swift6-concurrency.md)** — Load when using @concurrent, nonisolated(unsafe), or actor patterns
- **[Task Groups](references/task-groups.md)** — Load when running multiple async operations in parallel
- **[Task Cancellation](references/task-cancellation.md)** — Load when implementing long-running or cancellable operations
- **[Strict Concurrency](references/strict-concurrency.md)** — Load when enabling Swift 6 strict mode or fixing Sendable errors
- **[Macros](references/macros.md)** — Load when using or understanding Swift macros like @Observable
- **[Modern Attributes](references/modern-attributes.md)** — Load when migrating legacy code or using @preconcurrency, @backDeployed
- **[Migration Patterns](references/migration-patterns.md)** — Load when modernizing delegate patterns or UIKit views
