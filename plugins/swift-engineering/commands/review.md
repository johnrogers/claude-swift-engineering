---
description: Review Swift code for quality, security, performance, and HIG compliance
---

# Swift Code Review

> ⛔ **DO NOT use Claude's built-in Plan mode**
>
> This command uses specialized agents:
> - Planning: `@swift-architect`, `@tca-architect`
> - Implementation: `@swift-engineer`, `@tca-engineer`, `@swiftui-specialist`
>
> Call agents via `Task(subagent_type: "swift-engineering:agent-name", ...)`.
> EnterPlanMode will break this workflow.

Review Swift/iOS code for quality, security, performance, and HIG compliance.

## Invocation

- `/review` — review recent changes (git diff)
- `/review <file-or-folder>` — review specific code
- `/review --full` — review entire feature or codebase

## When to Use

- Before committing significant changes
- After major refactoring
- For code audits
- When onboarding to unfamiliar code
- Before submitting a PR

## Workflow

### 1. Gather Scope

Ask if not specified:
> "What would you like me to review?
> 1. **Recent changes** — Review uncommitted changes (git diff)
> 2. **Specific files** — Name the files or folders
> 3. **Full feature** — Review an entire feature directory"

### 2. IMMEDIATELY Invoke Review Agent

After determining scope, your VERY NEXT ACTION must be to invoke the code reviewer agent:

```
Task(
  subagent_type: "swift-engineering:swift-code-reviewer",
  description: "Review code for quality and issues",
  prompt: "Review [scope description]. Check for code quality, security, performance, and HIG compliance."
)
```

⛔ **DO NOT** call `EnterPlanMode`. The agent IS the review mechanism.
⛔ **DO NOT** use Read, Grep, or Glob tools to review code yourself.

### 3. Execute Review

```
@swift-code-reviewer
```

**WHY:** Expert review catches issues before they reach production. Checks for:
- **Code Quality:** Structure, naming, complexity, duplication
- **Concurrency Safety:** Actor isolation, Sendable conformance, data races
- **HIG Compliance:** UI patterns, accessibility, platform conventions
- **Performance:** Memory leaks, inefficient patterns, unnecessary work
- **Security:** Input validation, data protection, secure networking
- **Swift Best Practices:** Modern patterns, deprecated API usage

### 4. Review Report

@swift-code-reviewer produces a structured report:

```markdown
## Code Review Summary

### Critical Issues (must fix)
1. **[Security]** `APIClient.swift:45` — API key hardcoded
   → Move to secure storage (Keychain)

2. **[Concurrency]** `ProfileViewModel.swift:23` — Data race on `items` property
   → Add @MainActor or make actor

### Warnings (should fix)
1. **[Performance]** `ListView.swift:67` — Image loading in ForEach body
   → Move to AsyncImage with caching

### Suggestions (nice to have)
1. **[Style]** `UserModel.swift:12` — Consider using `let` instead of `var`

### Passed Checks
✓ HIG compliance
✓ Accessibility labels
✓ Error handling
```

### 5. Handle Issues

If issues found, ask:
> "I found [N] issues. Would you like me to fix them?"

If yes, hand off to appropriate implementation agent:
- TCA issues → @tca-engineer
- View issues → @swiftui-specialist
- Other Swift → @swift-engineer

After fixes, re-run review to verify.

### 6. Completion

Summarize review:
> "✓ **Review complete**
> - **Critical:** 0
> - **Warnings:** 2 fixed
> - **Suggestions:** 1 noted
> - **Status:** Ready for testing"

OR if issues remain:
> "⚠️ **Review found issues**
> - **Critical:** 1 (must address)
> - **Warnings:** 2
> - **Next steps:** [recommendation]"

## Review Checklist

@swift-code-reviewer evaluates:

### Swift 6.2+ Compliance
- [ ] Strict concurrency checking passes
- [ ] No deprecated APIs
- [ ] Modern async/await patterns
- [ ] Proper Sendable conformance

### TCA Best Practices (if applicable)
- [ ] State is @ObservableState
- [ ] Actions are properly namespaced
- [ ] Dependencies use @DependencyClient
- [ ] Effects are testable

### SwiftUI Best Practices
- [ ] Views are declarative only
- [ ] No business logic in views
- [ ] Proper state management (@State, @Observable)
- [ ] Accessibility labels and hints

### Security
- [ ] No hardcoded secrets
- [ ] Input validation
- [ ] Secure data storage
- [ ] HTTPS for all network calls

### Performance
- [ ] No retain cycles
- [ ] Efficient list rendering
- [ ] Lazy loading where appropriate
- [ ] Minimal view body complexity
