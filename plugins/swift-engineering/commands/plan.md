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

Once you have a description:

1. **Analyze the description** and suggest:
   - Feature name (e.g., `UserProfile`)
   - Likely files to create
   - Architecture recommendation (TCA vs vanilla Swift) with rationale
   - Persistence needs (SQLite, UserDefaults, CloudKit, or none)
   - New dependencies needed

2. **Present suggestions and ask for feedback**

3. **Ask clarifying questions** if needed

### 2. IMMEDIATELY Invoke Planning Agent

After gathering requirements, your VERY NEXT ACTION must be to invoke an agent:

**If UI mockup/description provided:**
```
Task(
  subagent_type: "swift-engineering:swift-ui-design",
  description: "Analyze UI for [feature-name]",
  prompt: "Analyze the provided UI [mockup/description]. [Include all gathered requirements]"
)
```

**Otherwise:**
```
Task(
  subagent_type: "swift-engineering:swift-architect",
  description: "Plan [feature-name] architecture",
  prompt: "Design architecture for [feature description]. [Include all requirements]"
)
```

⛔ **DO NOT** call `EnterPlanMode`. The agent IS the planning mechanism.
⛔ **DO NOT** use Read, Grep, or Glob tools to explore the codebase yourself.
⛔ **DO NOT** start implementing. This command is for planning ONLY.

### 3. UI Analysis (if UI provided)

```
@swift-ui-design
```

**WHY:** UI requirements inform architecture decisions. Analyzing UI first helps identify state management needs and component complexity.

**BOUNDARY:** Hand off to @swift-architect when UI Design Analysis is complete.

### 4. Architecture Planning

```
@swift-architect
```

**WHY:** Architecture decisions (TCA vs vanilla, persistence strategy, feature boundaries) must be made before implementation.

**DECISION POINT:** Based on architecture choice:
- If TCA → proceed to TCA design
- If vanilla Swift → planning complete

**BOUNDARY:** Hand off to @tca-architect if TCA, otherwise complete.

### 5. TCA Architecture (if TCA chosen)

```
@tca-architect
```

**WHY:** TCA feature design requires specialized knowledge. Detailed state/action/dependency design prevents implementation confusion.

**BOUNDARY:** Planning complete when TCA Design section is written.

### 6. Completion

Summarize the plan:
> "✓ **Plan complete:** `UserProfile`
> - **Plan file:** `docs/plans/user-profile.md`
> - **Architecture:** TCA / Vanilla Swift
> - **Persistence:** SQLite / UserDefaults / None
> - **Key decisions:** [list]
>
> Run `/feature` when ready to implement."
