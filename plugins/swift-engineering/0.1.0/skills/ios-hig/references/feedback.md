# Feedback

Apple Human Interface Guidelines for motion, haptics, loading states, and error handling.

## Table of Contents
1. [Motion and Haptics](#motion-and-haptics)
2. [Status and Error Feedback](#status-and-error-feedback)

## Motion and Haptics

### Critical Rules

- Motion should be **purposeful**: reinforce state change, hierarchy, or causality—not decoration
- Keep animations **subtle and consistent**; avoid stacking multiple effects (scale + rotate + blur) for routine interactions
- Respect accessibility settings (Reduce Motion); don't rely on animation as the only feedback
- Use haptics sparingly for meaningful moments (confirmations, errors), not for every tap

### Examples

```swift
// ✅ Subtle animation tied to state change
withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
    model.isExpanded.toggle()
}

// ❌ Excessive motion for routine UI; feels noisy and fatiguing
withAnimation(.easeInOut(duration: 2.0)) {
    model.isExpanded.toggle()
}
// Plus additional scale/rotation/blur effects on the entire screen
```

### Motion Guidelines

**Purposeful Animation**:
- State transitions (expanding/collapsing)
- Hierarchy changes (list reordering)
- Causality (deletion leading to list reflow)

**Animation Parameters**:
- Spring response: 0.3-0.4 seconds
- Damping fraction: 0.8-0.9 (less bouncy)
- Easing: Prefer springs over linear or custom curves

**Accessibility**:
- Always respect `@Environment(\.accessibilityReduceMotion)`
- Provide non-animated alternatives
- Don't use motion as the only feedback mechanism

## Status and Error Feedback

### Critical Rules

- Always show **state feedback** for async work: loading, success, failure, and empty
- Prefer **inline** status for local issues (validation) and **alerts** for exceptional interruptions
- Make errors **actionable**: explain what happened in plain language and offer a next step (retry, fix input, dismiss)
- Avoid blaming the user; avoid exposing raw system error text
- Use system patterns for empty states (`ContentUnavailableView`) and progress (`ProgressView`)

### Examples

```swift
// ✅ Clear empty state and recoverable error with retry
Group {
    if model.isLoading {
        ProgressView("Loading…")
    } else if model.items.isEmpty {
        ContentUnavailableView(
            "No items",
            systemImage: "tray",
            description: Text("Add your first item to get started.")
        )
    } else {
        List(model.items) { item in Text(item.title) }
    }
}
.alert("Couldn't load items", isPresented: $model.isShowingError) {
    Button("Retry", action: model.reload)
    Button("Cancel", role: .cancel) {}
} message: {
    Text("Check your connection and try again.")
}

// ❌ Silent failures and raw errors; no next step
List(model.items) { item in Text(item.title) }
// On error: print(error) and keep stale UI with no feedback
```

### Status Guidelines

**Loading States**:
- Use `ProgressView` for async operations
- Show progress for operations >1 second
- Provide context ("Loading items…")

**Empty States**:
- Use `ContentUnavailableView` for empty collections
- Explain what the view is for
- Provide a primary action to get started

**Error States**:
- Use alerts for unexpected errors that interrupt flow
- Use inline validation for expected errors (form fields)
- Always provide a recovery action

**Error Messages**:
- ✅ "Couldn't save item. Check your connection and try again."
- ❌ "Error: NetworkError.timeout"

**Next Steps**:
- Retry button for transient failures
- Fix input guidance for validation errors
- Dismiss or cancel for unrecoverable errors

## Summary

**Key Principles**:
1. Keep motion subtle, purposeful, and tied to state changes
2. Respect Reduce Motion accessibility setting
3. Always show feedback for async operations (loading, empty, error)
4. Make errors actionable with plain language and recovery steps
5. Use system patterns (`ProgressView`, `ContentUnavailableView`, alerts)
6. Prefer inline validation for expected errors, alerts for exceptional interruptions
