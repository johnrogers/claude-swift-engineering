---
description: Plan a Swift feature without implementing. Uses swift-planner agent, not Claude's built-in Plan mode.
---

# Swift Plan

Create a feature plan without proceeding to implementation.

**IMPORTANT:** Do NOT use Claude's built-in Plan mode. Use the plugin agents specified below.

## Invocation

- `/swift-plan` — prompt for feature description
- `/swift-plan <description>` — start with provided description

## Workflow

### 1. Gather Requirements

If no description provided, ask:
> "What feature would you like to plan? Describe what it should do."

Ask about UI input:
> "Do you have a screenshot or mockup? (paste image, describe, or 'skip')"

If provided:
```
@swift-ui-design
```
Pass the screenshot/description.

Once you have a description:

1. Analyze and suggest feature name, files, architecture, persistence
2. Present suggestions and ask for feedback
3. Ask clarifying questions if needed

### 2. Create Plan

```
@swift-planner
```
Pass the feature requirements. Include `Sosumi` in the MCP Servers section.

### 3. Output

> "✓ **Plan created:** `docs/plans/<feature-name>.md`
>
> **Summary:**
> - Architecture: TCA
> - Files: 3 new files
> - Dependencies: 1 new client
>
> When ready, run `/swift-feature` or invoke agents directly:
> - `@swift-tca` for TCA implementation
> - `@swift-core` for vanilla Swift implementation"
