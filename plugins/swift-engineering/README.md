# Swift Development Plugin

Modern Swift/SwiftUI development toolkit with TCA support for Claude Code.

## Features

- **Feature workflow** — Plan, implement, test, and build Swift features
- **TCA support** — Full Composable Architecture integration
- **iOS 26+ / Swift 6.2** — Modern Swift with strict concurrency
- **Swift Testing** — Modern testing framework patterns
- **Build automation** — Xcode build and test verification

## Prerequisites

**Sosumi MCP Server** — Required for Apple documentation lookup. Agents use this to verify modern API usage. Configure in your Claude Code settings before using this plugin.

## Commands

| Command | Description |
|---------|-------------|
| `/swift-feature` | Full feature workflow |
| `/swift-plan` | Plan without implementing |
| `/swift-test` | Run tests |
| `/swift-build` | Build and check errors |

## Agents

| Agent | Purpose |
|-------|---------|
| `swift-ui-design` | Analyze mockups into UI plan |
| `swift-planner` | Plan with architecture decisions |
| `swift-core` | Vanilla Swift implementation |
| `swift-tca` | TCA implementation |
| `swift-swiftui` | SwiftUI views |
| `swift-testing` | Tests |
| `swift-docs` | Documentation |
| `swift-build` | Build verification |

## Skills

| Skill | Status |
|-------|--------|
| `swift-testing` | ✓ Complete |
| `swift-style` | ✓ Complete |
| `programming-swift` | Placeholder |
| `composable-architecture` | Placeholder |
| `ios-hig` | Placeholder |
| `sqlite-data` | Placeholder |
| `generating-swift-package-docs` | Placeholder |

## Installation

Drop this folder into your Claude Code plugins directory:

```
~/.claude/plugins/swift-development/
```

Or install from a marketplace:

```
/plugin marketplace add <your-marketplace>
/plugin install swift-development@<marketplace>
```

## Setup

Replace placeholder SKILL.md files in `skills/` with your actual content.

## Workflow

```
Screenshot/mockup? ──yes──► swift-ui-design
        │                         │
        no                        │
        │◄─────────────────────────
        ▼
   swift-planner  →  docs/plans/<feature>.md
        │               (includes MCP servers to use)
        ▼
 swift-tca/core   →  Implementation
        │
        ▼
   swift-swiftui  →  Views
        │
        ▼
  swift-testing   →  Tests
        │
        ▼
   swift-build    →  Verification
```

## MCP Server Configuration

The plan document specifies which MCP servers to use. By default:

- **Sosumi** — Apple documentation lookup

Agents read the plan and use the specified MCP servers for documentation lookup, ensuring modern APIs are always used.

## Architecture

- **iOS 26.0+** minimum
- **Swift 6.2** with strict concurrency
- **SwiftUI only** (no UIKit unless requested)
- **TCA** for complex state, vanilla Swift for simple features
- **SQLite** for persistence (never SwiftData)
- **Swift Testing** framework (no XCTest)
