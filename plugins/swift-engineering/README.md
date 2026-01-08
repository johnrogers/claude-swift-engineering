# Swift Engineering Plugin

**Version:** 0.1.27

> ⚠️ **Experimental** — This plugin is actively developed. APIs, agents, and workflows may evolve.

Modern Swift/SwiftUI development toolkit with TCA support for Claude Code. Provides 12 specialized agents and 18 comprehensive skills for planning, implementing, testing, and shipping production iOS/macOS applications.

## Features at a Glance

- **12 specialized agents** — Planning, architecture, implementation, testing, and documentation
- **18 comprehensive skills** — Architecture patterns, frameworks, design guidelines, and development tools
- **Ultra-modern Swift** — iOS 26+, Swift 6.2, strict concurrency, SwiftUI-only
- **TCA-first architecture** — Separate architect and engineer agents with coordinated handoffs
- **Production-ready** — Built-in code review, testing, and quality assurance workflows
- **Coordination via plans** — All agents share state through plan files, no manual coordination needed

## Table of Contents

- [Core Capabilities](#core-capabilities)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Using Agents](#using-agents)
- [Agents](#agents)
- [Skills](#skills)
- [Installation](#installation)
- [Advanced Features](#advanced-features)
- [Workflow](#workflow)
- [Agent Handoff Model](#agent-handoff-model)
- [Plan File Format](#plan-file-format)
- [Architecture Conventions](#architecture-conventions)
- [Model Usage](#model-usage)
- [Quality Assurance](#quality-assurance)
- [Contributing](#contributing)
- [License](#license)
- [Feedback](#feedback)

## Core Capabilities

### Planning & Architecture
- Design features with UI mockups or descriptions
- Architecture decisions (TCA vs vanilla Swift)
- TCA-specific design (state, actions, effects, dependencies)

### Implementation
- Reducers and effects (TCA)
- Business logic and models (vanilla Swift)
- SwiftUI views with accessibility
- Modern async/await patterns
- Database operations (SQLite, CloudKit sync)

### Quality Assurance
- Comprehensive testing with Swift Testing
- Code review (security, performance, HIG compliance)
- Modernization (legacy to modern Swift conversion)
- Documentation generation

### Coordination
- Shared plan files for agent handoffs
- Automatic status tracking
- Clear ownership and next steps

## Prerequisites

**Sosumi MCP Server** — Required for Apple documentation lookup. Agents use this to verify modern API usage (2025). Configure in your Claude Code settings before using this plugin.

## Getting Started

1. **Install** this plugin in your Claude Code plugins directory
2. **Build a feature** by invoking agents in order (start with `@swift-architect` for new features)
3. **Agents coordinate** through plan files — no manual handoffs needed
4. **End with code review** via `@swift-code-reviewer` before shipping

For detailed workflows and examples, see [Using Agents](#using-agents) section below.

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

**Step 6: Code review and verification**
```
@swift-code-reviewer Review the implementation for quality, security, and performance
```
Verifies code meets project standards before shipping.

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

**Step 4: Code review**
```
@swift-code-reviewer Review the implementation for quality and performance
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
| Code review | `@swift-code-reviewer` | Review the implementation for quality and security |

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
- **Always end with `@swift-code-reviewer`** to verify quality before shipping
- **Agents coordinate via plan files** — No manual handoff needed, just invoke the next agent

## Agents

### Planning Agents (Opus, READ-ONLY)

| Agent | Purpose | Model |
|-------|---------|-------|
| `@swift-ui-design` | Analyze mockups OR descriptions into UI specifications | Opus |
| `@swift-architect` | Architecture decisions (TCA vs vanilla, persistence) | Opus |
| `@tca-architect` | TCA-specific design (state, actions, dependencies) | Opus |

### Implementation Agents (Inherit)

| Agent | Purpose | Model |
|-------|---------|-------|
| `@tca-engineer` | TCA implementation (reducers, effects) | Inherit |
| `@swift-engineer` | Vanilla Swift implementation (models, services) | Inherit |
| `@swiftui-specialist` | SwiftUI views (declarative only, no business logic) | Inherit |
| `@swift-test-creator` | Create tests using Swift Testing | Inherit |
| `@swift-documenter` | Generate API documentation and comments | Haiku |
| `@documentation-generator` | Generate comprehensive, LLM-optimized project documentation | Inherit |
| `@swift-code-reviewer` | Review code quality, security, performance | Inherit |
| `@swift-modernizer` | Migrate legacy patterns to modern Swift | Inherit |

### Utility Agents (Haiku)

| Agent | Purpose | Model |
|-------|---------|-------|
| `@search` | Fast code search to prevent grep noise from polluting context | Haiku |

## Skills

### Architecture & Patterns
| Skill | Purpose |
|-------|---------|
| `composable-architecture` | TCA patterns, reducers, effects, testing, performance |
| `swiftui-patterns` | iOS 17+ SwiftUI (@Observable, @Bindable, navigation, accessibility) |
| `swiftui-advanced` | Advanced gestures, adaptive layout, architecture decisions |
| `modern-swift` | Swift 6.2 concurrency (async/await, actors, @MainActor, Sendable) |

### Frameworks & Libraries
| Skill | Purpose |
|-------|---------|
| `sqlite-data` | SQLiteData library (@Table, migrations, CloudKit sync) |
| `grdb` | GRDB direct SQLite access (complex queries, performance) |
| `storekit` | StoreKit 2 in-app purchases and subscriptions |
| `foundation-models` | Apple on-device AI (iOS 26+, summarization, extraction) |
| `swift-networking` | Network.framework (TCP/UDP, custom protocols) |

### Platform & Design
| Skill | Purpose |
|-------|---------|
| `ios-hig` | Apple Human Interface Guidelines (accessibility, dark mode, haptics) |
| `ios-26-platform` | iOS 26 features (Liquid Glass, new APIs, backward compatibility) |
| `haptics` | Haptic feedback (UIFeedbackGenerator, Core Haptics, AHAP patterns) |
| `localization` | Internationalization (String Catalogs, pluralization, RTL) |

### Development Tools
| Skill | Purpose |
|-------|---------|
| `swift-testing` | Swift Testing framework (@Test, parameterized tests, async) |
| `swift-style` | Code style conventions (naming, golden path, organization) |
| `swift-diagnostics` | Systematic debugging (navigation, build issues, memory) |
| `generating-swift-package-docs` | Generate API docs for Swift package dependencies |

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

### Local Development
Drop this folder into your Claude Code plugins directory:

```bash
~/.claude/plugins/swift-engineering/
```

Then in Claude Code:
```
/plugin reload
```

### Configuration
Before using agents, ensure the **Sosumi MCP Server** is configured in your Claude Code settings for Apple documentation lookup.

Optional: Configure hooks for git automation. See [hooks-scripts/README.md](hooks-scripts/README.md) for details.

### First Run
1. Navigate to your Swift project directory
2. Invoke an agent: `@swift-architect Design a new feature`
3. Agent creates a plan file at `docs/plans/<feature-name>.md`
4. Each subsequent agent updates the plan and adds handoff notes

## Workflow

```
UI description/mockup? ──yes──► @swift-ui-design (Opus)
        │                              │
        no                             │
        │◄──────────────────────────────
        ▼
   @swift-architect (Opus)  →  docs/plans/<feature>.md
        │
        ├── TCA chosen ──► @tca-architect (Opus) ──► @tca-engineer (Inherit)
        │                                                    │
        └── Vanilla chosen ───────────────► @swift-engineer (Inherit)
                                                    │
                                                    ▼
                                          @swiftui-specialist (Inherit)
                                                    │
                                                    ▼
                                         @swift-test-creator (Inherit)
                                                    │
                                                    ▼
                                       @swift-code-reviewer (Inherit)
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
| @swift-test-creator | @swift-code-reviewer | Tests written |
| @swift-code-reviewer | @swift-documenter | Code review complete |

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
- [ ] Code review (@swift-code-reviewer)
- [ ] Documentation (@swift-documenter)

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
| Opus | @swift-architect, @swift-ui-design, @tca-architect | Best reasoning for architecture decisions |
| Inherit | Implementation agents (engineer, test, review, modernizer, docs) | Balanced quality and cost (uses parent session model) |
| Haiku | @search, @swift-documenter | Fast, efficient for mechanical tasks |

## Quality Assurance

### Validation Checklist

When modifying agents or skills:

- [ ] All agents have `name`, `description`, `tools`, `model` fields
- [ ] Planning agents (`@swift-architect`, `@swift-ui-design`, `@tca-architect`) are Opus
- [ ] Implementation agents use Inherit (allows cost-effective scaling with session model)
- [ ] Utility agents (`@search`, `@swift-documenter`) are Haiku
- [ ] Planning agents have explicit no-modify constraints
- [ ] All handoffs are documented in Agent Handoff Model
- [ ] All skill references exist in `skills/` directory

## Contributing

Contributions are welcome! Areas of focus:

- **New agents** — Specialized agents for underserved tasks
- **Skill enhancements** — Additional frameworks, patterns, or design guidance
- **Bug fixes** — Issues, regressions, or edge cases in existing agents
- **Documentation** — Clarity, examples, or new guides
- **Testing** — Verify agent workflows work end-to-end

Please ensure:
- Agents follow the established [specification](#agents)
- Skills adhere to [writing-skills best practices](https://github.com/anthropics/claude-code/blob/main/docs/skills.md)
- Changes are tested with actual Swift projects
- Documentation is updated

## License

This plugin is available under the MIT License. See [LICENSE](LICENSE) file for details.

## Feedback

Report issues or suggest features at the [GitHub repository](https://github.com/johnrogers/claude-swift-engineering/issues).
