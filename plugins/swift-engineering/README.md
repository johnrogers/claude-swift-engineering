# Swift Engineering Plugin

Modern Swift/SwiftUI development toolkit with TCA support for Claude Code.

## Features

- **Ultra-specialized agents** — Each agent has clear boundaries and handoffs
- **TCA support** — Separate architect (design) and engineer (implementation) agents
- **iOS 26+ / Swift 6.2** — Modern Swift with strict concurrency
- **Swift Testing** — Modern testing framework (@Test, #expect, #require)
- **Build automation** — Xcode build and test verification
- **Code review** — Quality, security, performance, and HIG compliance
- **Modernization** — Migrate legacy patterns to modern Swift

## Prerequisites

**Sosumi MCP Server** — Required for Apple documentation lookup. Agents use this to verify modern API usage (2025). Configure in your Claude Code settings before using this plugin.

## Commands

| Command | Description |
|---------|-------------|
| `/feature` | Full feature workflow — plan, implement, test, build |
| `/plan` | Plan without implementing |
| `/test` | Create and run tests |
| `/build` | Build and check errors |
| `/review` | Code review for quality, security, performance |
| `/modernize` | Migrate legacy patterns to modern Swift |

## Agents

### Planning Agents (Opus, READ-ONLY)

| Agent | Purpose |
|-------|---------|
| `@swift-ui-design` | Analyze mockups OR descriptions into UI specifications |
| `@swift-architect` | Architecture decisions (TCA vs vanilla, persistence) |
| `@tca-architect` | TCA-specific design (state, actions, dependencies) |

### Implementation Agents (Sonnet)

| Agent | Purpose |
|-------|---------|
| `@tca-engineer` | TCA implementation (reducers, effects) |
| `@swift-engineer` | Vanilla Swift implementation (models, services) |
| `@swiftui-specialist` | SwiftUI views (declarative only, no business logic) |
| `@swift-test-creator` | Create tests using Swift Testing |
| `@swift-documenter` | Generate documentation |
| `@swift-code-reviewer` | Review code quality, security, performance |
| `@swift-modernizer` | Migrate legacy patterns |

### Mechanical Agent (Haiku)

| Agent | Purpose |
|-------|---------|
| `@swift-builder` | Build verification and error fixing |

## Skills

| Skill | Purpose |
|-------|---------|
| `modern-swift` | Swift 6.2 concurrency essentials (async/await, actors, @MainActor) |
| `swift-common-patterns` | Architecture patterns (DefaultProvider, actors, DI, networking) |
| `modern-swiftui` | Modern SwiftUI patterns (iOS 17+, @Observable, @Bindable) |
| `swiftui-common-patterns` | SwiftUI patterns (MVVM, navigation, performance, accessibility) |
| `composable-architecture` | TCA patterns and best practices |
| `ios-hig` | Apple Human Interface Guidelines |
| `swift-testing` | Swift Testing framework patterns |
| `swift-style` | Code style conventions |
| `sqlite-data` | SQLite persistence patterns |
| `generating-swift-package-docs` | Package documentation generation |
| `programming-swift` | Language reference (loaded on-demand) |

## Installation

Drop this folder into your Claude Code plugins directory:

```
~/.claude/plugins/swift-engineering/
```

Or install from a marketplace:

```
/plugin marketplace add <your-marketplace>
/plugin install swift-engineering@<marketplace>
```

## Workflow

```
UI description/mockup? ──yes──► @swift-ui-design (Opus)
        │                              │
        no                             │
        │◄──────────────────────────────
        ▼
   @swift-architect (Opus)  →  docs/plans/<feature>.md
        │
        ├── TCA chosen ──► @tca-architect (Opus) ──► @tca-engineer (Sonnet)
        │                                                    │
        └── Vanilla chosen ───────────────► @swift-engineer (Sonnet)
                                                    │
                                                    ▼
                                          @swiftui-specialist (Sonnet)
                                                    │
                                                    ▼
                                       @swift-code-reviewer (optional)
                                                    │
                                                    ▼
                                         @swift-test-creator (Sonnet)
                                                    │
                                                    ▼
                                           @swift-builder (Haiku)
                                                    │
                                                    ▼
                                        @swift-documenter (optional)
```

## Agent Handoff Model

Each agent knows exactly when to hand off:

| From | To | Condition |
|------|----|-----------|
| @swift-ui-design | @swift-architect | UI analysis complete |
| @swift-architect | @tca-architect | TCA architecture chosen |
| @swift-architect | @swift-engineer | Vanilla architecture chosen |
| @tca-architect | @tca-engineer | TCA design complete |
| @tca-engineer | @swiftui-specialist | Implementation complete |
| @swift-engineer | @swiftui-specialist | Implementation complete |
| @swiftui-specialist | @swift-test-creator | Views complete |
| @swift-test-creator | @swift-builder | Tests written |
| @swift-builder | @swift-documenter | Build successful |

## Plan File Format

All agents share state via a plan file at `docs/plans/<feature-name>.md`:

```markdown
# Feature: <FeatureName>

## Status
- [ ] UI design (@swift-ui-design)
- [ ] Architecture (@swift-architect)
- [ ] TCA design (@tca-architect) — if TCA
- [ ] Implementation (@tca-engineer or @swift-engineer)
- [ ] Views (@swiftui-specialist)
- [ ] Tests (@swift-test-creator)
- [ ] Build verified (@swift-builder)

## MCP Servers
- **sosumi** — Apple documentation lookup (2025 APIs)

## Handoff Log

### @agent-name (YYYY-MM-DD)
**Work done:** [Summary]
**Files created:** [List]
**Notes for next agent:** [Context]
**Next:** @agent-name — [Reason]
```

## Architecture Conventions

- **iOS 26.0+** minimum deployment target
- **Swift 6.2** with strict concurrency checking
- **SwiftUI only** (no UIKit unless explicitly requested)
- **TCA** for complex state management, vanilla Swift for simpler features
- **SQLite** for persistence (never SwiftData)
- **Swift Testing** framework (no XCTest)
- **async/await** exclusively (no completion handlers)

## Model Usage

| Model | Agents | Rationale |
|-------|--------|-----------|
| Opus | Planning agents | Better architectural decisions |
| Sonnet | Implementation agents | Balanced speed and quality |
| Haiku | Build verification | Fast mechanical work |
