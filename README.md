# claude-swift-engineering

[![License](https://img.shields.io/badge/license-MIT-green)](#) [![Platform](https://img.shields.io/badge/platform-iOS%2026%2B%20%7C%20macOS-blue)](#)

> Claude Code plugin marketplace for modern Swift/SwiftUI development

A specialized AI toolkit for building professional iOS/macOS features with modern Swift 6.2, TCA (The Composable Architecture), and SwiftUI. This plugin provides ultra-specialized agents that orchestrate planning, implementation, testing, and deployment.

## Swift Engineering Plugin

The **swift-engineering plugin** is a production-ready toolkit for professional Swift development:

- **12 Ultra-Specialized Agents** — Planning (Opus), implementation (Inherit), utilities (Haiku) with clear handoffs
- **TCA Support** — Full workflow from architecture design to testing for The Composable Architecture
- **Modern Swift 6.2** — iOS 26+ with strict concurrency, async/await, actors, Sendable
- **Code Quality** — Integrated code review, accessibility compliance, and performance checks
- **Knowledge Skills** — 18 specialized knowledge bases covering architecture patterns, frameworks, design, and development tools

## Quick Start

### Installation

Add the plugin to Claude Code:

```bash
# Add marketplace source
/plugin marketplace add https://github.com/johnrogers/claude-swift-engineering

# Install swift-engineering plugin
/plugin install swift-engineering
```

### Hooks (Optional)

Enable skill/agent evaluation hooks for better workflow discipline:

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
          },
          {
            "type": "command",
            "command": "cat ~/.claude/hooks-scripts/UserPromptSubmit/agent-forced-eval-hook.sh"
          }
        ]
      }
    ]
  }
}
```

See [plugins/swift-engineering/hooks-scripts/README.md](plugins/swift-engineering/hooks-scripts/README.md) for complete hook documentation.

See [plugins/swift-engineering/README.md](plugins/swift-engineering/README.md) for complete documentation on using agents and available workflows.

## What's Included

### 12 Specialized Agents

| Type | Agents | Responsibility |
|------|--------|-----------------|
| **Planning** | @swift-ui-design, @swift-architect, @tca-architect | Architecture decisions (Opus, read-only) |
| **Implementation** | @tca-engineer, @swift-engineer, @swiftui-specialist, @swift-test-creator, @documentation-generator, @swift-code-reviewer, @swift-modernizer | Code creation and review (Inherit) |
| **Utilities** | @swift-documenter, @search | API documentation and code search (Haiku) |

### 18 Knowledge Skills

Architecture patterns (TCA, SwiftUI, modern Swift, advanced gestures), frameworks (SQLite, GRDB, StoreKit, networking), platform design (iOS 26, HIG, localization, haptics), and development tools (testing, style, diagnostics). Each skill provides deep guidance on modern patterns and best practices.

## For Contributors

### Repository Structure

```
claude-swift-engineering/
├── .claude-plugin/
│   └── marketplace.json                    # Marketplace configuration
├── .github/workflows/                      # CI/CD pipelines
├── plugins/
│   └── swift-engineering/                  # Main plugin
│       ├── agents/                         # 12 specialized agents
│       ├── skills/                         # 18 comprehensive skills
│       ├── hooks-scripts/                  # Hooks system
│       ├── scripts/                        # Helper utilities
│       ├── rules/                          # Development rules
│       └── README.md                       # Plugin documentation
└── worktrees/                              # Git worktrees for features
```

### Development Workflow

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
- **Model Stratification** — Opus for architecture (best reasoning), Inherit for implementation (cost-effective), Haiku for utilities (fast)
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
**Swift Version:** 6.2+
**iOS Deployment Target:** 26.0+

---

For detailed documentation, agent specifications, and usage examples, see [plugins/swift-engineering/README.md](plugins/swift-engineering/README.md).
