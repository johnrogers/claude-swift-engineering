---
description: Start a new Swift feature — plan, implement, test, and build. Uses plugin agents, not Claude's built-in Plan mode.
---

# Swift Feature Workflow

> ⛔ **DO NOT use Claude's built-in Plan mode**
>
> This command uses specialized agents:
> - Planning: `@swift-architect`, `@tca-architect`
> - Implementation: `@swift-engineer`, `@tca-engineer`, `@swiftui-specialist`
>
> Call agents via `Task(subagent_type: "swift-engineering:agent-name", ...)`.
> EnterPlanMode will break this workflow.

Guide the user through developing a complete Swift feature using this plugin's specialized agents.

## Invocation

- `/feature` — prompt for feature description
- `/feature <description>` — start with provided description

## Plan File Format

All agents share state via a plan file at `docs/plans/<feature-name>.md`. If it does not exist, create it:

```markdown
# Feature: <FeatureName>

## Status
- [ ] UI design (@swift-ui-design)
- [ ] Architecture (@swift-architect)
- [ ] TCA design (@tca-architect) — if TCA
- [ ] Implementation (@tca-engineer or @swift-engineer)
- [ ] Views (@swiftui-specialist)
- [ ] Code review (@swift-code-reviewer) — optional
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
> "What feature would you like to build? Describe what it should do."

Then ask about UI input:
> "Do you have a screenshot or mockup of the UI? You can:
> - Paste an image
> - Describe the UI visually
> - Say 'skip' to proceed without UI design analysis"

Once you have a description:

- Strongly consider consulting either @swift-architect, @tca-architect, or @swift-ui-design to battle-test the plan.

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
@swift-ui-design
```
Pass the screenshot/description. Output: UI Design Analysis section in plan.

**Otherwise:**
```
@swift-planner
```

⛔ **DO NOT** call `EnterPlanMode`. The agent IS the planning mechanism.

### 3. Confirm Automation Preference

Ask the user:
> "How would you like to proceed?
> 1. **Fully automated** — I'll run through all steps, pausing only on issues
> 2. **Semi-guided** — I'll complete each step and ask approval before the next
>
> Which do you prefer?"

### 4. Execute Workflow

Execute each phase by calling the specified agent. Each agent updates the plan file with handoff notes.

---

#### Phase 1: UI Analysis (if UI description or mockup provided)

```
@swift-ui-design
```

**WHY:** UI requirements (from mockup OR description) need analysis to identify SwiftUI components, HIG compliance issues, and interaction patterns before architecture decisions.

**BOUNDARY:** Hand off to @swift-architect when UI Design Analysis is written to plan file.

*If semi-guided:* "UI analysis complete. Ready to proceed to architecture planning?"

---

#### Phase 2: Architecture Planning

```
@swift-architect
```

**WHY:** Architecture decisions (TCA vs vanilla, persistence strategy, feature boundaries) must be made before implementation to avoid rework.

**DECISION POINT:** Based on architecture choice:
- If TCA → proceed to Phase 3 (@tca-architect)
- If vanilla Swift → skip to Phase 4 (@swift-engineer)

**BOUNDARY:** Hand off when architecture decision is documented in plan.

*If semi-guided:* "Architecture planning complete. Review the plan. Ready for implementation?"

---

#### Phase 3: TCA Architecture (if TCA chosen)

```
@tca-architect
```

**WHY:** TCA feature design requires specialized knowledge. Separating design from implementation reduces errors and uses Opus for better architectural decisions.

**BOUNDARY:** Hand off to @tca-engineer when TCA Design section is complete in plan file.

*If semi-guided:* "TCA architecture designed. Ready for implementation?"

---

#### Phase 4: Implementation

**DECISION:** Based on architecture from Phase 2:
- TCA path → `@tca-engineer`
- Vanilla path → `@swift-engineer`

```
@tca-engineer
```
OR
```
@swift-engineer
```

**WHY:** Implementation follows the architectural blueprint exactly. TCA and vanilla Swift have fundamentally different patterns.

**BOUNDARY:** Hand off to @swiftui-specialist when core implementation is complete.

*If semi-guided:* "Core implementation complete. Ready for view layer?"

---

#### Phase 5: Views

```
@swiftui-specialist
```

**WHY:** Views are declarative only. Separating view implementation ensures no business logic leaks into the view layer.

**BOUNDARY:** Ask if user wants code review. If no, ask if user wants tests. Hand off accordingly.

*If semi-guided:* "Views implemented. Would you like me to run a code review? (If no, I'll ask about testing next)"

---

#### Phase 6: Code Review (optional)

```
@swift-code-reviewer
```

**WHY:** Catch quality, security, and performance issues before testing.

**BOUNDARY:** If issues found, hand back to implementation agent. Otherwise, ask if user wants tests.

*If semi-guided:* "Review complete. Would you like me to create tests? (If no, I'll proceed to build verification)"

---

#### Phase 7: Testing (optional)

```
@swift-test-creator
```

**WHY:** Creates comprehensive tests using Swift Testing framework. Tests verify behavior without influencing implementation decisions.

**BOUNDARY:** Hand off to @swift-builder when tests are written.

*If semi-guided:* "Tests written. Ready to verify build?"

---

#### Phase 8: Build Verification

```
@swift-builder
```

**WHY:** Mechanical error fixing uses Haiku for efficiency. Builder fixes compiler errors only, not logic.

**BOUNDARY:** If complex error, hand off to appropriate implementation agent. Otherwise, proceed to documentation or complete.

*If semi-guided:* "Build successful! Update documentation?"

---

#### Phase 9: Documentation (optional)

Ask: "Would you like me to update documentation?"
If yes:

```
@swift-documenter
```

**WHY:** Documentation after implementation captures actual behavior.

**BOUNDARY:** Workflow complete.

---

### 5. Completion

Summarize what was created:
> "✓ **Feature complete:** `UserProfile`
> - **Plan:** `docs/plans/user-profile.md`
> - **Implementation:** `Features/UserProfile/...`
> - **Tests:** `ProjectTests/UserProfileTests/...`
> - **Build:** Passing"
