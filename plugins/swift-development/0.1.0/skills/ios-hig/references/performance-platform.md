# Performance and Platform Conventions

Apple Human Interface Guidelines for performance, responsiveness, and platform-native patterns.

## Table of Contents
1. [Performance and Responsiveness](#performance-and-responsiveness)
2. [Platform Conventions](#platform-conventions)

## Performance and Responsiveness

### Critical Rules

- Optimize for **perceived performance**: show progress quickly, keep interactions responsive, and avoid blocking the main actor
- Use incremental loading patterns where appropriate; avoid doing heavy work during view rendering
- Prefer clear placeholder/progress UI over a frozen screen
- Avoid unnecessary animations, shadows, and effects that degrade scrolling performance

### Examples

```swift
// ✅ Immediate feedback and non-blocking load
VStack {
    if model.isLoading {
        ProgressView("Loading…")
    } else {
        List(model.items) { item in Text(item.title) }
    }
}
.task { await model.loadIfNeeded() }

// ❌ Heavy synchronous work during view body; causes jank
var body: some View {
    let items = model.computeExpensiveListSynchronously()
    return List(items) { item in Text(item.title) }
}
```

### Performance Guidelines

**Perceived Performance**:
- Show UI immediately, even if data isn't ready
- Use `ProgressView` or skeleton states while loading
- Keep interactions responsive (<100ms feedback)
- Avoid blocking the main thread

**Async Work**:
- Use `.task { }` for async loading in views
- Move heavy computation to background tasks
- Never do expensive work in `body` or computed properties

**Rendering Performance**:
- Avoid heavy shadows, blurs, or complex gradients in scrolling views
- Use `LazyVStack`/`LazyHStack` for large lists
- Profile with Instruments if scrolling feels janky

**Loading Patterns**:
- Show skeleton/placeholder UI immediately
- Load data incrementally when appropriate
- Provide progress indication for operations >1 second

## Platform Conventions

### Critical Rules

- Prefer system components before custom UI (Lists, Forms, toolbars, menus, context menus)
- Use SF Symbols consistently and pair icons with text for clarity when appropriate
- Keep controls and terminology consistent with iOS conventions (Done/Cancel, Back, Edit)
- Avoid recreating iOS UI patterns with bespoke visuals unless you have a strong UX reason

### Examples

```swift
// ✅ System toolbar placements and familiar labels
.toolbar {
    ToolbarItem(placement: .cancellationAction) {
        Button("Cancel", role: .cancel) { model.cancel() }
    }
    ToolbarItem(placement: .confirmationAction) {
        Button("Done", action: model.done)
    }
}

// ❌ Custom "Close" / "Okay" in random placements; inconsistent with platform
.toolbar {
    ToolbarItem(placement: .automatic) { Button("Okay") {} }
    ToolbarItem(placement: .automatic) { Button("Close") {} }
}
```

### Platform Guidelines

**System Components**:
- `List` for browsable content
- `Form` for settings and data entry
- `Toolbar` for actions
- `NavigationStack` for hierarchical navigation
- `Menu` and context menus for secondary actions

**SF Symbols**:
- Use SF Symbols for icons (system-provided, adapts to Dynamic Type)
- Pair icons with text labels for clarity
- Use consistent symbols throughout the app
- Prefer standard symbols over custom icons

**Platform Terminology**:
- ✅ "Done", "Cancel", "Save", "Delete", "Edit"
- ❌ "Okay", "Close", "Submit", "Remove", "Modify"

**Standard Placements**:
- `.cancellationAction` - Cancel/Back (leading on modals)
- `.confirmationAction` - Done/Save (trailing on modals)
- `.destructive` role for Delete actions
- `.primaryAction` for main toolbar actions

**Consistency**:
- Follow iOS patterns for common flows (creation, editing, deletion)
- Use standard gestures (swipe to delete, pull to refresh)
- Respect system settings (Dynamic Type, Reduce Motion, Reduce Transparency)

## Summary

**Key Principles**:
1. Show UI immediately; load data asynchronously
2. Use `ProgressView` and skeleton states while loading
3. Avoid heavy work during view rendering
4. Prefer system components over custom UI
5. Use SF Symbols and standard terminology
6. Follow platform conventions for toolbar placements and actions
7. Keep controls and terminology consistent with iOS
