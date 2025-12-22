# Swift Engineering Skills Review

Review against writing-skills best practices from superpowers:writing-skills skill.

## Critical Issues (Must Fix)

### 1. Missing `name` Field in Frontmatter

**Skills affected:**
- `modern-swiftui` - Has description only
- `swift-common-patterns` - Has description only
- `swiftui-common-patterns` - Has description only

**Fix:** Add `name` field matching directory name.

### 2. Description Violates CSO Guidelines

**generating-swift-package-docs:**
```yaml
# ❌ CURRENT: 462 chars, summarizes workflow
description: Use when encountering unfamiliar import statements; when exploring a dependency's API; when user asks "what's import X?", "what does import X do?", or about package documentation. - Generates comprehensive API documentation for Swift package dependencies on-demand. This skill helps you quickly obtain documentation for packages used in Xcode projects when you encounter unfamiliar module imports. Automatically resolves modules to packages and caches documentation for reuse. This is the primary tool for understanding individual `import` statements.
```

**Problem:** Summarizes workflow after triggering conditions. Per writing-skills: "Description = When to Use, NOT What the Skill Does"

**Fix:**
```yaml
# ✅ PROPOSED: ~200 chars, triggers only
description: Use when encountering unfamiliar import statements, exploring dependency APIs, or when user asks "what's import X" or "what does X do". Generates on-demand API documentation for Swift package dependencies.
```

### 3. Description Doesn't Start with "Use when..."

**composable-architecture:**
```yaml
# ❌ CURRENT: General description + keyword stuffing
description: Comprehensive guide for The Composable Architecture (TCA) patterns in Swift. Use when building features with TCA, structuring reducers, managing state, handling effects, navigation, or testing. Triggers: TCA, composable architecture, reducer, feature, state management, SwiftUI architecture.
```

**Fix:**
```yaml
# ✅ PROPOSED
description: Use when building features with TCA (The Composable Architecture), structuring reducers, managing state, handling effects, navigation, or testing TCA features. Triggers: TCA, @Reducer, Store, Effect, TestStore, reducer composition.
```

**ios-hig:**
```yaml
# ❌ CURRENT
description: Apple Human Interface Guidelines for iOS app design with SwiftUI. Use when designing iOS interfaces, working with SwiftUI views, handling user interaction, managing accessibility, choosing colors and typography, implementing navigation, providing feedback, optimizing performance, or requesting permissions. Triggers: SwiftUI, iOS design, accessibility, Dynamic Type, VoiceOver, navigation, modals, empty states, loading states, animations, haptics, permissions, SF Symbols, system components.
```

**Fix:**
```yaml
# ✅ PROPOSED
description: Use when designing iOS interfaces, working with SwiftUI views, handling user interaction, managing accessibility (VoiceOver, Dynamic Type), choosing colors/typography, implementing navigation, providing feedback (animations, haptics), or requesting permissions. Apple Human Interface Guidelines for iOS.
```

## Progressive Disclosure Violations

**Skills that are too long and need references/:**

### swiftui-common-patterns (767 lines)
**Should be:** ~50 line index + references/

**Structure:**
```
SKILL.md (~50 lines)
  - Quick Reference table
  - Links to:
    - references/mvvm-observable.md
    - references/navigation.md
    - references/performance.md
    - references/uikit-interop.md
    - references/accessibility.md
    - references/async-patterns.md
    - references/composition.md
```

### swift-common-patterns (478 lines)
**Should be:** ~50 line index + references/

**Structure:**
```
SKILL.md (~50 lines)
  - Quick Reference table
  - Links to:
    - references/default-provider.md
    - references/type-safe-resolution.md
    - references/actor-managers.md
    - references/mvvm-pattern.md
    - references/dependency-injection.md
    - references/networking.md
    - references/error-handling.md
```

### modern-swiftui (315 lines)
**Should be:** ~50 line index + references/

**Structure:**
```
SKILL.md (~50 lines)
  - Quick Reference table comparing old vs new patterns
  - Links to:
    - references/observable.md
    - references/state-management.md
    - references/environment.md
    - references/view-modifiers.md
    - references/async-views.md
    - references/migration-guide.md
```

### swift-testing (124 lines)
**Borderline** - Could stay inline OR move to references if frequently loaded

## Token Efficiency Issues

### Repetitive Content

**swift-style (136 lines):**
- Mostly examples showing same pattern multiple times
- Could condense to ~80 lines
- Quick reference table would be more efficient than prose

## Summary of Changes Needed

| Skill | Issue | Priority | Estimated Lines After |
|-------|-------|----------|----------------------|
| modern-swiftui | Missing `name`, needs progressive disclosure | HIGH | 50 + refs/ |
| swift-common-patterns | Missing `name`, needs progressive disclosure | HIGH | 50 + refs/ |
| swiftui-common-patterns | Missing `name`, needs progressive disclosure | HIGH | 50 + refs/ |
| composable-architecture | Description format | MEDIUM | 16 (unchanged) |
| ios-hig | Description format | MEDIUM | 14 (unchanged) |
| generating-swift-package-docs | Description too long, violates CSO | HIGH | 16 (unchanged) |
| swift-style | Token efficiency | LOW | ~80-100 |
| swift-testing | Optional progressive disclosure | LOW | 50 + refs/ OR keep |

## Frontmatter Standards

All skills MUST have:
```yaml
---
name: skill-name-with-hyphens
description: Use when [specific triggering conditions]. Max 500 chars, NO workflow summary.
---
```

## Description Formula

```
Use when [symptoms/situations/triggers]. [Optional 1-sentence context]. Triggers: [keywords].
```

**Examples:**

✅ Good:
```yaml
description: Use when implementing local data persistence, database operations, or private CloudKit synchronization. Patterns for SQLite with CloudKit sync.
```

✅ Good:
```yaml
description: Use when writing Swift code to ensure consistent formatting, naming, organization, and idiomatic patterns. Code style conventions.
```

❌ Bad (workflow summary):
```yaml
description: Use when creating skills - write test first, watch fail, write skill, watch pass, refactor
```

❌ Bad (too abstract):
```yaml
description: For Swift development
```

## Implementation Order

1. **Fix frontmatter (all missing `name` fields)** - 5 min
2. **Fix descriptions (CSO violations)** - 10 min
3. **Progressive disclosure refactoring:**
   - swiftui-common-patterns (highest priority, 767 lines)
   - swift-common-patterns (478 lines)
   - modern-swiftui (315 lines)
4. **Optional: swift-testing progressive disclosure** - Low priority

## Validation Checklist

For each skill:
- [ ] Has `name` field (kebab-case, matches directory)
- [ ] Has `description` field (max 1024 chars total, ideally < 500)
- [ ] Description starts with "Use when..."
- [ ] Description has NO workflow summary
- [ ] Description includes specific triggers/symptoms
- [ ] SKILL.md is < 200 lines (or has good reason to be longer)
- [ ] If > 200 lines, uses progressive disclosure with references/
- [ ] Keywords throughout for search
- [ ] Quick reference table (not just prose)
