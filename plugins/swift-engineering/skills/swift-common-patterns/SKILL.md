---
name: swift-common-patterns
description: Use when implementing architecture patterns for Swift apps: DefaultProvider protocol, type-safe token resolution, actor-isolated managers, MVVM, dependency injection, async networking, or domain-specific error handling.
---

# Swift Common Patterns

## Quick Reference

| Pattern | Use When |
|---------|----------|
| DefaultProvider | Config types needing consistent defaults |
| ConcreteResolvable | Theme tokens with type-safe resolution |
| Actor-Isolated Managers | Shared mutable state, caches |
| Model-ViewModel-View | Complex view computations |
| Environment DI | App-wide service injection |
| Modern Networking | API clients |
| Domain Errors | User-facing errors |

## Core Workflow

When architecting a Swift app:
1. Define configuration types with `DefaultProvider` for consistent defaults
2. Use `actor` for any shared mutable state (caches, services)
3. Inject dependencies via SwiftUI `Environment` — avoid singletons
4. Create domain-specific error types with `LocalizedError` conformance
5. Build API clients as actors with typed endpoints

## References

Load these based on what you need:
- **[DefaultProvider Protocol](references/default-provider.md)** — Load when creating config/style types with defaults
- **[Type-Safe Resolution](references/type-safe-resolution.md)** — Load when building theme systems or token resolution
- **[Actor-Isolated Managers](references/actor-managers.md)** — Load when creating thread-safe services or caches
- **[Model-ViewModel-View](references/mvvm-pattern.md)** — Load when building complex views with environment dependencies
- **[Dependency Injection](references/dependency-injection.md)** — Load when setting up app-wide service injection
- **[Modern Networking](references/networking.md)** — Load when building API clients from scratch
- **[Error Handling](references/error-handling.md)** — Load when designing domain-specific error types
