---
description: Plan a Swift feature without implementing. Uses swift-architect agent, not Claude's built-in Plan mode.
---

# Swift Planning Only

> ⛔ **DO NOT use Claude's built-in Plan mode or direct tool usage**
>
> This command delegates to specialized agents:
> - **@swift-ui-design** — Analyzes UI mockups/descriptions to inform architecture
> - **@swift-architect** — Designs feature architecture and persistence strategy
> - **@tca-architect** — Designs detailed TCA state/action/dependency structure (if TCA chosen)
>
> <!-- MAINTENANCE: Keep this agent list in sync with available agents in plugin.yaml -->

Create an architecture plan for a Swift feature without implementing it.

## Invocation

- `/plan` — prompt for feature description
- `/plan <description>` — start with provided description

## When to Use

- When you want to plan before implementing
- When exploring architecture options
- When you need stakeholder review before coding
- When estimating scope of a feature

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
- [ ] Documentation (@swift-documenter) — optional

## MCP Servers
- **sosumi** — Apple documentation lookup (2025 APIs)

## Handoff Log

### @agent-name (YYYY-MM-DD)
**Work done:** [Summary]
**Files created:** [List]
**Notes for next agent:** [Context]
**Next:** @agent-name — [Reason for handoff]
```

## Workflow

### 1. Gather Requirements

If no description provided, ask:
> "What feature would you like to plan? Describe what it should do."

Then ask about UI:
> "Do you have a UI description or mockup? You can:
> - Paste an image
> - Describe the UI visually
> - Say 'skip' to proceed without UI design analysis"

### 2. Invoke Planning Agent

After gathering requirements, immediately delegate to the appropriate agent:

**If UI mockup/description provided:** Delegate to **@swift-ui-design** first.

**WHY:** UI requirements inform architecture decisions. Analyzing UI first helps identify state management needs and component complexity.

**Otherwise:** Delegate to **@swift-architect** directly.

⛔ **DO NOT** call `EnterPlanMode`
⛔ **DO NOT** use Read, Grep, or Glob tools to explore the codebase yourself
⛔ **DO NOT** start implementing. This command is for planning ONLY

### 3. Architecture Planning

**@swift-ui-design** (if UI provided) hands off to **@swift-architect** when UI Design Analysis is complete.

**@swift-architect** makes architecture decisions (TCA vs vanilla, persistence strategy, feature boundaries).

**DECISION POINT:** Based on architecture choice:
- If TCA → hand off to **@tca-architect**
- If vanilla Swift → planning complete

### 4. TCA Architecture (if TCA chosen)

**@tca-architect** designs detailed TCA state/action/dependency structure.

**WHY:** TCA feature design requires specialized knowledge. Detailed state/action/dependency design prevents implementation confusion.

Planning is complete when TCA Design section is written.

### 5. Completion

Summarize the plan:
> "✓ **Plan complete:** `UserProfile`
> - **Plan file:** `docs/plans/user-profile.md`
> - **Architecture:** TCA / Vanilla Swift
> - **Persistence:** SQLite / UserDefaults / None
> - **Key decisions:** [list]
>
> Run `/feature` when ready to implement."
