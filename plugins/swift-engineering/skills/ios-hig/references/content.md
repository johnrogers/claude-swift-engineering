# Content

Apple Human Interface Guidelines for content, empty states, writing, and typography.

## Table of Contents
1. [Empty States](#empty-states)
2. [Writing and Labels](#writing-and-labels)
3. [Typography and Dynamic Type](#typography-and-dynamic-type)

## Empty States

### Critical Rules

- Use empty states to **explain what this screen is** and **what to do next**
- Prefer lightweight guidance (one sentence + primary action) over multi-step tutorials
- Keep onboarding contextual: explain features at the moment the user needs them
- Avoid placeholder junk content that looks real; make it obvious when content is sample/demo

### Examples

```swift
// ✅ Helpful empty state with a clear next step
ContentUnavailableView {
    Label("No links yet", systemImage: "link")
} description: {
    Text("Save links to find them quickly later.")
} actions: {
    Button("Add link", systemImage: "plus") { model.presentAddLink() }
        .buttonStyle(.borderedProminent)
}

// ❌ Empty UI with no explanation
List { }
```

## Writing and Labels

### Critical Rules

- Prefer **plain language** and short phrases; avoid jargon and developer terms
- Buttons should describe the action ("Save", "Add link"), not vague labels ("OK", "Yes")
- Keep terminology consistent across the app (e.g., "Link" vs "URL"); choose one and stick to it
- Error messages should explain the problem and the next step, without blame

### Examples

```swift
// ✅ Clear action labels and consistent terminology
Button("Add link", systemImage: "plus") { model.addLink() }
Button("Save", action: model.save)

// Error message example
Text("Could not save link. Check your connection and try again.")

// ❌ Vague and inconsistent
Button("OK") { model.save() }
Button("Add URL") { model.addLink() }

// Error message without guidance
Text("Error: Save failed")
```

### Writing Guidelines

**Button Labels**:
- ✅ "Delete", "Save", "Add link"
- ❌ "OK", "Yes", "No"

**Error Messages**:
- ✅ "Could not load items. Pull to refresh."
- ❌ "Error code 404"

**Terminology Consistency**:
- Choose one term and use it throughout
- "Link" not "URL" or "Website"
- "Save" not "Add" or "Create" interchangeably

## Typography and Dynamic Type

### Critical Rules

- Use **Dynamic Type** styles (`.body`, `.headline`, `.caption`) instead of hard-coded sizes
- Prefer **short, scannable labels**; use secondary text (`.secondary`) for supporting detail
- Avoid truncation for critical info; if truncation can happen, provide an alternative (multi-line, disclosure, copy)
- Use appropriate alignment and line limits; avoid overly dense paragraphs
- Ensure text remains legible in accessibility sizes (test with larger sizes)

### Examples

```swift
// ✅ Dynamic Type + predictable wrapping for important content
VStack(alignment: .leading, spacing: 8) {
    Text(item.title)
        .font(.headline)
        .lineLimit(2)

    if let summary = item.summary {
        Text(summary)
            .font(.body)
            .foregroundStyle(.secondary)
            .lineLimit(3)
    }
}

// ❌ Hard-coded sizes and single-line truncation for critical info
VStack(alignment: .leading) {
    Text(item.title)
        .font(.system(size: 14))
        .lineLimit(1)
    Text(item.summary ?? "")
        .font(.system(size: 11))
        .lineLimit(1)
}
```

### Dynamic Type Styles

Use system text styles that scale with Dynamic Type:
- `.largeTitle`, `.title`, `.title2`, `.title3`
- `.headline`, `.body`, `.callout`
- `.subheadline`, `.footnote`, `.caption`, `.caption2`

```swift
// ✅ System styles that scale
Text("Main heading")
    .font(.title2)
Text("Body content")
    .font(.body)
Text("Supporting detail")
    .font(.caption)
    .foregroundStyle(.secondary)
```

## Summary

**Key Principles**:
1. Use `ContentUnavailableView` for helpful empty states
2. Write clear, action-oriented button labels
3. Keep terminology consistent throughout the app
4. Error messages explain the problem and next step
5. Use Dynamic Type styles, never hard-coded sizes
6. Allow important text to wrap (don't truncate critical info)
