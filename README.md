# claude-swift-engineering

[![Version](https://img.shields.io/badge/version-0.1.7-blue)](#) [![License](https://img.shields.io/badge/license-MIT-green)](#) [![Platform](https://img.shields.io/badge/platform-iOS%2026%2B%20%7C%20macOS-blue)](#)

> Claude Code plugin marketplace for modern Swift/SwiftUI development

A specialized AI toolkit for building professional iOS/macOS features with modern Swift 6.2, TCA (The Composable Architecture), and SwiftUI. This plugin provides ultra-specialized agents that orchestrate planning, implementation, testing, and deployment.

## Swift Engineering Plugin

The **swift-engineering plugin** (v0.1.7) is a production-ready toolkit for professional Swift development:

- **13 Ultra-Specialized Agents** — Planning (Opus), implementation (Sonnet), mechanical tasks (Haiku) with clear handoffs
- **TCA Support** — Full workflow from architecture design to testing for The Composable Architecture
- **Modern Swift 6.2** — iOS 26+ with strict concurrency, async/await, actors, Sendable
- **End-to-End Workflows** — Plan → Implement → Review → Test → Build → Document
- **Quality Assurance** — Automated smoke tests, code review, build verification
- **Knowledge Skills** — 11 specialized knowledge bases covering modern Swift, SwiftUI, TCA, testing, and more

## Quick Start

### Installation

Add the plugin to Claude Code:

```bash
# Add marketplace source
/plugin marketplace add https://github.com/johnrogers/claude-swift-engineering

# Install swift-engineering plugin
/plugin install swift-engineering
```

### Your First Feature

Try building a feature with the plugin:

```bash
/feature Build a counter with increment/decrement buttons using TCA
```

The plugin will guide you through the complete workflow:
1. **@swift-architect** analyzes requirements and designs architecture
2. **@tca-architect** designs the TCA state, actions, and effects
3. **@tca-engineer** implements the reducer
4. **@swiftui-specialist** creates the UI views
5. **@swift-test-creator** writes tests
6. **@swift-builder** verifies the build
7. **@swift-documenter** generates documentation

See [plugins/swift-engineering/README.md](plugins/swift-engineering/README.md) for complete documentation.

## What's Included

### 13 Specialized Agents

| Type | Agents | Responsibility |
|------|--------|-----------------|
| **Planning** | @swift-ui-design, @swift-architect, @tca-architect | Architecture decisions (Opus, read-only) |
| **Implementation** | @tca-engineer, @swift-engineer, @swiftui-specialist, @swift-test-creator, @swift-documenter, @documentation-generator, @swift-code-reviewer, @swift-modernizer | Code creation and review (Sonnet) |
| **Mechanical** | @swift-builder, @search | Build verification and code search (Haiku) |

### 11 Knowledge Skills

Modern Swift, TCA, SwiftUI, iOS HIG, Testing, Persistence, and more. Each skill provides deep guidance on modern patterns and best practices.

### 6 Workflow Commands

Commands are experimental and located in `/experimental-do-not-use/commands/`:

| Command | Purpose |
|---------|---------|
| `/feature` | Full feature workflow (plan → implement → test → build) |
| `/plan` | Architecture planning without implementation |
| `/test` | Create and run tests using Swift Testing |
| `/build` | Build project and fix errors |
| `/review` | Code review for quality, security, performance |
| `/modernize` | Migrate legacy Swift patterns to modern approaches |

> ⚠️ **Note**: Experimental commands are a preview. Use the plugin's built-in workflows instead. See [plugins/swift-engineering/README.md](plugins/swift-engineering/README.md) for production-ready workflows.

### Hooks System

Enforce best practices with hooks that require explicit skill evaluation before implementation. See [plugins/swift-engineering/hooks-scripts/README.md](plugins/swift-engineering/hooks-scripts/README.md) for setup.

## For Contributors

### Repository Structure

```
claude-swift-engineering/
├── .claude-plugin/
│   └── marketplace.json                    # Marketplace configuration
├── .github/workflows/                      # CI/CD pipelines
├── plugins/
│   └── swift-engineering/                  # Main plugin (v0.1.7)
│       ├── agents/                         # 13 specialized agents
│       ├── skills/                         # 11 knowledge skills
│       ├── hooks-scripts/                  # Hooks system
│       ├── scripts/                        # Helper utilities
│       ├── rules/                          # Development rules
│       ├── docs/                           # Smoke test suite
│       └── README.md                       # Plugin documentation
├── experimental-do-not-use/
│   └── commands/                           # NOT PRODUCTION READY
└── worktrees/                              # Git worktrees for features
```

### Development Workflow

#### Testing Changes

Run the comprehensive smoke test suite to validate agent configuration:

```bash
cd plugins/swift-engineering
cat docs/smoke-tests.md  # See full test suite documentation
```

Tests validate:
- Agent metadata (required fields, correct structure)
- Model assignments (Opus/Sonnet/Haiku correctness)
- Read-only agent constraints
- Handoff chain completeness
- Skill references

#### Bumping Version

When making changes, increment the plugin version:

```bash
bash plugins/swift-engineering/scripts/bump-plugin-version.sh <new-version>
```

This updates version numbers across plugin.json, marketplace.json, and other metadata files.

#### Adding Agents or Skills

1. Create new agent or skill file following existing patterns (see examples in `agents/` or `skills/`)
2. Update `plugin.json` if defining new tool capabilities
3. Run smoke tests to validate configuration
4. Update both README files (root and plugin)
5. Test integration with the workflow

#### Experimental Commands

The `/experimental-do-not-use/` directory contains preview commands that are NOT production-ready:

- `/feature` — Extended feature planning
- `/plan` — Experimental planning workflow
- `/test` — Experimental testing workflow
- `/build` — Experimental build workflow
- `/review` — Experimental code review
- `/modernize` — Experimental modernization workflow

**Do NOT use these in production.** Use the plugin's stable agent-based workflows instead.

### Code Organization

- **Agents** (`agents/`) — Each agent has a `.md` file with metadata and instructions
- **Skills** (`skills/`) — Knowledge resources agents reference, organized by topic
- **Hooks** (`hooks-scripts/`) — Executable hooks that enforce workflows
- **Scripts** (`scripts/`) — Utility shell scripts for automation
- **Rules** (`rules/`) — Development practices and decision-making frameworks
- **Documentation** (`docs/`) — Smoke tests and validation suite

## Architecture & Design Principles

The plugin implements several key principles:

- **Ultra-Specialization** — Each agent has one clear responsibility with defined handoffs
- **Model Stratification** — Opus for architecture (cost-effective and accurate), Sonnet for implementation (balanced), Haiku for mechanical tasks (fast)
- **Local-First** — Default to SQLite and UserDefaults, never SwiftData or Core Data
- **Modern Swift Only** — Swift 6.2 with strict concurrency, no deprecated APIs
- **Read-Only Planning** — Planning agents cannot modify code, ensuring clear separation
- **Plan File Coordination** — Agents share state via `docs/plans/<feature>.md`

See [plugins/swift-engineering/README.md](plugins/swift-engineering/README.md) for architecture details, workflow diagrams, and handoff models.

## License

MIT License — See [LICENSE](LICENSE) file for details.

## Credits

**Author:** John Rogers
**Repository:** claude-swift-engineering
**Plugin Version:** 0.1.7
**Swift Version:** 6.2+
**iOS Deployment Target:** 26.0+

---

For detailed documentation, agent specifications, and usage examples, see [plugins/swift-engineering/README.md](plugins/swift-engineering/README.md).
