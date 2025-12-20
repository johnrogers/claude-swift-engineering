---
description: Plan a Swift feature without implementing. Uses swift-architect agent, not Claude's built-in Plan mode.
---

# Swift Planning Only

> ⛔ **DO NOT use Claude's built-in Plan mode**
>
> This command uses specialized agents:
> - Planning: `@swift-architect`, `@tca-architect`
> - Implementation: `@swift-engineer`, `@tca-engineer`, `@swiftui-specialist`
>
> Call agents via `Task(subagent_type: "swift-engineering:agent-name", ...)`.
> EnterPlanMode will break this workflow.

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

### 2. UI Analysis (if UI provided)

```
@swift-ui-design
```

**WHY:** UI requirements inform architecture decisions. Analyzing UI first helps identify state management needs and component complexity.

**BOUNDARY:** Hand off to @swift-architect when UI Design Analysis is complete.

### 3. Architecture Planning

```
@swift-architect
```

**WHY:** Architecture decisions (TCA vs vanilla, persistence strategy, feature boundaries) must be made before implementation.

**DECISION POINT:** Based on architecture choice:
- If TCA → proceed to TCA design
- If vanilla Swift → planning complete

**BOUNDARY:** Hand off to @tca-architect if TCA, otherwise complete.

### 4. TCA Architecture (if TCA chosen)

```
@tca-architect
```

**WHY:** TCA feature design requires specialized knowledge. Detailed state/action/dependency design prevents implementation confusion.

**BOUNDARY:** Planning complete when TCA Design section is written.

### 5. Completion

Summarize the plan:
> "✓ **Plan complete:** `UserProfile`
> - **Plan file:** `docs/plans/user-profile.md`
> - **Architecture:** TCA / Vanilla Swift
> - **Persistence:** SQLite / UserDefaults / None
> - **Key decisions:** [list]
>
> Run `/feature` when ready to implement."
