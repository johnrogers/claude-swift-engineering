# Swift Engineering Plugin

**Version:** 0.1.21

> ⚠️ **Experimental** — This plugin is a work in progress. APIs, agents, and workflows may change.

Modern Swift/SwiftUI development toolkit with TCA support for Claude Code.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Using Agents](#using-agents)
- [Agents](#agents)
- [Skills](#skills)
- [Advanced Features](#advanced-features)
- [Workflow](#workflow)
- [Agent Handoff Model](#agent-handoff-model)
- [Plan File Format](#plan-file-format)
- [Architecture Conventions](#architecture-conventions)
- [Model Usage](#model-usage)
- [Quality Assurance](#quality-assurance)

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

## Using Agents

This plugin provides ultra-specialized agents that you invoke directly to build features. Each agent has a specific role and understands when to hand off to the next agent in the workflow.

### Basic Workflow: Building a TCA Feature

For a typical feature using The Composable Architecture:

**Step 1: Plan the architecture**
```
@swift-architect Design a counter feature with increment/decrement buttons using TCA
```
This creates a plan file at `docs/plans/counter.md` with architecture decisions.

**Step 2: Design TCA architecture**
```
@tca-architect Design the state, actions, and effects for the counter based on the plan
```
Updates the plan with TCA-specific design details.

**Step 3: Implement the reducer**
```
@tca-engineer Implement the counter reducer and effects following the TCA design
```
Creates the actual Reducer implementation.

**Step 4: Create SwiftUI views**
```
@swiftui-specialist Create the counter view that displays the state and handles actions
```
Implements the UI without mixing in business logic.

**Step 5: Write tests**
```
@swift-test-creator Write comprehensive tests for the counter using Swift Testing
```
Creates test files with test cases.

**Step 6: Verify build**
```
@swift-builder Build the project and verify everything compiles without errors
```
Ensures the code is production-ready.

### Alternative Workflow: Vanilla Swift Feature (No TCA)

For simpler features without complex state management:

**Step 1: Plan architecture**
```
@swift-architect Design a calculator utility (vanilla Swift, no UI)
```

**Step 2: Implement core logic**
```
@swift-engineer Implement the calculator logic following the plan
```

**Step 3: Write tests**
```
@swift-test-creator Write tests for the calculator using Swift Testing
```

**Step 4: Verify build**
```
@swift-builder Build and verify
```

### Common Tasks by Agent

| Task | Agent | Example |
|------|-------|---------|
| Analyze UI mockups/screenshots | `@swift-ui-design` | Analyze this design mockup and create UI specifications |
| Plan new features | `@swift-architect` | Plan a user authentication system |
| Design TCA architecture | `@tca-architect` | Design state/actions/effects for authentication |
| Implement TCA features | `@tca-engineer` | Implement the authentication reducer |
| Implement vanilla Swift | `@swift-engineer` | Implement the Settings model and persistence |
| Build SwiftUI views | `@swiftui-specialist` | Create the authentication UI following the design |
| Create tests | `@swift-test-creator` | Write tests for the authentication flow |
| Code review | `@swift-code-reviewer` | Review the authentication module for security and quality |
| Modernize code | `@swift-modernizer` | Migrate this legacy code to async/await |
| Documentation | `@swift-documenter` | Document the public API surface |
| Project docs | `@documentation-generator` | Create comprehensive project documentation |
| Fast code search | `@search` | Find all UserDefaults usage in the codebase |
| Build verification | `@swift-builder` | Build the project and fix any errors |

### Plan File Coordination

All agents coordinate through a shared plan file at `docs/plans/<feature-name>.md`. This file:
- Records architecture decisions (created by `@swift-architect`)
- Tracks implementation status
- Contains handoff notes from each agent to the next
- Ensures continuity across agent handoffs

Each agent will automatically read the plan, update it with their work, and add notes for the next agent.

### Key Principles

- **Start with `@swift-architect`** for new features to get architecture decisions
- **Use `@swift-ui-design`** if you have mockups or screenshots to analyze
- **Choose your path** — TCA for complex state, vanilla Swift for simpler features
- **Always end with `@swift-builder`** to verify the project compiles
- **Agents coordinate via plan files** — No manual handoff needed, just invoke the next agent

## Agents

### Planning Agents (Opus, READ-ONLY)

| Agent | Purpose | Color |
|-------|---------|-------|
| `@swift-ui-design` | Analyze mockups OR descriptions into UI specifications | cyan |
| `@swift-architect` | Architecture decisions (TCA vs vanilla, persistence) | — |
| `@tca-architect` | TCA-specific design (state, actions, dependencies) | orange |

### Implementation Agents (Sonnet)

| Agent | Purpose | Color |
|-------|---------|-------|
| `@tca-engineer` | TCA implementation (reducers, effects) | green |
| `@swift-engineer` | Vanilla Swift implementation (models, services) | green |
| `@swiftui-specialist` | SwiftUI views (declarative only, no business logic) | yellow |
| `@swift-test-creator` | Create tests using Swift Testing | green |
| `@swift-documenter` | Generate inline and API documentation | cyan |
| `@documentation-generator` | Generate comprehensive, LLM-optimized project documentation | green |
| `@swift-code-reviewer` | Review code quality, security, performance | orange |
| `@swift-modernizer` | Migrate legacy patterns to modern Swift | pink |

### Mechanical Agents (Haiku)

| Agent | Purpose | Color |
|-------|---------|-------|
| `@swift-builder` | Build verification and error fixing | — |
| `@search` | Fast code search to prevent grep noise from polluting context | orange |

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

## Advanced Features

### Helper Scripts

**get-recent-simulator.sh**

Gets the most recent iOS simulator available for Xcode builds.

Usage:
```bash
bash scripts/get-recent-simulator.sh
```

Used by build automation to select the correct simulator for testing.

**bump-plugin-version.sh**

Automates version bumping across plugin metadata files.

Usage:
```bash
bash scripts/bump-plugin-version.sh <new-version>
```

This script updates version numbers in:
- `.claude-plugin/plugin.json`
- Any other version-managed files

### Development Rules

**five-whys.md**

Root cause analysis technique for debugging complex issues:
- Structured approach to dig deeper into problems
- Leads to systemic improvements rather than symptoms
- Useful for understanding agent failures and design decisions

**thinking-partner.md**

Collaborative problem-solving approach for design decisions and complex architecture questions.

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

See [hooks-scripts/README.md](hooks-scripts/README.md) for optional hooks configuration.

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

## Quality Assurance

### Validation Checklist

When modifying agents or skills:

- [ ] All agents have `name`, `description`, `color`, `tools`, `model` fields
- [ ] Planning agents (`@swift-architect`, `@swift-ui-design`, `@tca-architect`) are Opus
- [ ] Implementation agents are Sonnet (except `@search` which is Haiku)
- [ ] Planning agents have explicit no-modify constraints
- [ ] All handoffs are documented in Agent Handoff Model
- [ ] All skill references exist in `skills/` directory
