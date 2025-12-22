# Swift Engineering Plugin

**Version:** 0.1.7

Modern Swift/SwiftUI development toolkit with TCA support for Claude Code.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Commands](#commands)
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

## Quick Start

### Run Your First Feature

Try building a complete feature with TCA:

```bash
/feature Build a counter with increment/decrement buttons using TCA
```

The plugin will automatically:
1. Analyze requirements and design TCA architecture (`@swift-architect`, `@tca-architect`)
2. Implement reducer, state, actions, and effects (`@tca-engineer`)
3. Create SwiftUI views (`@swiftui-specialist`)
4. Write tests (`@swift-test-creator`)
5. Verify build (`@swift-builder`)
6. Generate documentation (`@swift-documenter`, optional)

See [Workflow](#workflow) and [Agent Handoff Model](#agent-handoff-model) for detailed process.

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

### Hooks System

The plugin includes a hooks system to enforce best practices and prevent common pitfalls.

**UserPromptSubmit Hook: skill-forced-eval-hook.sh**

Forces explicit skill evaluation before implementation to ensure relevant knowledge bases are activated:

- Requires YES/NO evaluation of each available skill
- Ensures activation via the Skill tool for relevant skills
- Prevents skipping directly to implementation without proper context

**Setup Instructions:**

```bash
# 1. Symlink hooks-scripts to ~/.claude
ln -s /path/to/claude-swift-engineering/plugins/swift-engineering/hooks-scripts ~/.claude/hooks-scripts

# 2. Add to ~/.claude/settings.json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "cat ~/.claude/hooks-scripts/UserPromptSubmit/skill-forced-eval-hook.sh"
          }
        ]
      }
    ]
  }
}
```

See [hooks-scripts/README.md](hooks-scripts/README.md) for complete documentation.

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

### Smoke Test Suite

The plugin includes a comprehensive smoke test suite to validate agent configuration and catch common errors.

**Automated Tests:**

- **Agent Metadata Validation** — Ensures all agents have required fields (name, description, color, tools, model)
- **Model Assignment Verification** — Confirms agents are assigned correct models (Opus/Sonnet/Haiku)
- **Read-Only Agent Constraints** — Validates planning agents cannot modify files
- **Handoff Chain Completeness** — Verifies no agents are orphaned or unreachable
- **Skill Reference Validation** — Ensures all agent references to skills point to valid files

**Manual Integration Tests:**

- Full feature workflow with TCA (UI → architecture → implementation → testing)
- Full feature workflow with Vanilla Swift
- Planning agent read-only enforcement (cannot create/modify implementation files)
- Error triage and handoff (build failures route to `@swift-builder`)
- Context budget compliance (agents respect token limits)

### Running Tests

See [docs/smoke-tests.md](docs/smoke-tests.md) for complete test suite documentation and CI integration instructions.

Quick validation:

```bash
cd plugins/swift-engineering
# Run basic validation
cat docs/smoke-tests.md
```

### Validation Checklist

When modifying agents or skills:

- [ ] All agents have `name`, `description`, `color`, `tools`, `model` fields
- [ ] Planning agents (`@swift-architect`, `@swift-ui-design`, `@tca-architect`) are Opus
- [ ] Implementation agents are Sonnet (except `@search` which is Haiku)
- [ ] Planning agents have explicit no-modify constraints
- [ ] All handoffs are documented in Agent Handoff Model
- [ ] All skill references exist in `skills/` directory
- [ ] Smoke tests pass before committing changes
