---
description: Start a new Swift feature — plan, implement, test, and build. Uses plugin agents, not Claude's built-in Plan mode.
---

# Swift Feature Workflow

Guide the user through developing a complete Swift feature using this plugin's agents.

**IMPORTANT:** Do NOT use Claude's built-in Plan mode. Always use the plugin agents specified below with @agent syntax.

## Invocation

- `/swift-feature` — prompt for feature description
- `/swift-feature <description>` — start with provided description

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

1. **Analyze the description** and suggest:
   - Feature name (e.g., `UserProfile`)
   - Likely files to create
   - Architecture recommendation (TCA vs vanilla Swift) with rationale
   - Persistence needs (SQLite, UserDefaults, CloudKit, or none)
   - New dependencies needed

2. **Present suggestions and ask for feedback**

3. **Ask clarifying questions** if needed

### 2. Confirm Automation Preference

Ask the user:
> "How would you like to proceed?
> 1. **Fully automated** — I'll run through all steps, pausing only on issues
> 2. **Semi-guided** — I'll complete each step and ask approval before the next
>
> Which do you prefer?"

### 3. Execute Workflow

Execute each phase by calling the specified agent. Do NOT use Claude's built-in planning.

**UI Design Phase (if UI input provided):**
```
@swift-ui-design
```
Pass the screenshot/description. Output: UI Design Analysis section in plan.

*If semi-guided:* "UI analysis complete. Ready to proceed to planning?"

**Planning Phase:**
```
@swift-planner
```
Pass the feature requirements and UI analysis (if any). Include `Sosumi` in the MCP Servers section.
Output: `docs/plans/<feature-name>.md`

*If semi-guided:* "Planning complete. Review the plan. Ready to proceed with implementation?"

**Implementation Phase:**
Based on the plan's architecture decision:
```
@swift-tca
```
OR
```
@swift-core
```

Then:
```
@swift-swiftui
```

*If semi-guided:* "Implementation complete. Ready for testing?"

**Testing Phase:**
```
@swift-testing
```

*If semi-guided:* "Tests written. Ready to verify build?"

**Build Phase:**
```
@swift-build
```
Handle errors/warnings per agent instructions.

*If semi-guided:* "Build successful! Update documentation?"

**Documentation Phase (optional):**
Ask: "Would you like me to update documentation?"
If yes:
```
@swift-docs
```

### 4. Completion

Summarize what was created:
> "✓ **Feature complete:** `UserProfile`
> - **Plan:** `docs/plans/user-profile.md`
> - **Implementation:** `Features/UserProfile/...`
> - **Tests:** `ProjectTests/UserProfileTests/...`
> - **Build:** Passing"
