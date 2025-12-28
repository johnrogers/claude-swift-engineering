# Troubleshooting Foundation Models

## Anti-Patterns

### Using for World Knowledge
Model is 3B parameters - optimized for summarization/extraction, NOT encyclopedic knowledge.
```swift
// BAD - Will hallucinate
session.respond(to: "What's the capital of France?")
```
**Fix:** Use server LLMs or provide data via Tools.

### Manual JSON Parsing
```swift
// BAD - Crashes on wrong keys/invalid JSON
let json = try await session.respond(to: "Generate person as JSON")
JSONDecoder().decode(Person.self, from: json.data)
```
**Fix:** Use @Generable for guaranteed structure.

### Blocking Main Thread
```swift
// BAD - UI freezes
Button("Go") {
    let r = try await session.respond(to: prompt) // Frozen!
}
```
**Fix:** Wrap in `Task {}`.

### Ignoring Context Limits
4096 token limit (input + output). Break large tasks into smaller ones.

## Error Handling

```swift
do {
    let response = try await session.respond(to: prompt)
} catch LanguageModelSession.GenerationError.exceededContextWindowSize {
    // Condense transcript, create new session
    session = condensedSession(from: session)
} catch LanguageModelSession.GenerationError.guardrailViolation {
    showMessage("I can't help with that request")
} catch LanguageModelSession.GenerationError.unsupportedLanguageOrLocale {
    showMessage("Language not supported")
}
```

## Context Overflow Fix

```swift
func condensedSession(from prev: LanguageModelSession) -> LanguageModelSession {
    let entries = prev.transcript.entries
    guard entries.count > 2 else { return prev }

    // Keep first (instructions) + last (recent)
    let condensed = [entries.first!, entries.last!]
    return LanguageModelSession(transcript: Transcript(entries: condensed))
}
```

## Availability Issues

```swift
switch SystemLanguageModel.default.availability {
case .available:
    // Proceed
case .unavailable:
    // Show: "AI requires iPhone 15 Pro+ or M1 iPad/Mac"
    // Or: "Enable in Settings > Apple Intelligence"
}
```

## Performance Fixes

| Issue | Solution |
|-------|----------|
| Slow first generation | Prewarm session in `init()` |
| Long wait for results | Use `streamResponse()` |
| Schema overhead | `includeSchemaInPrompt: false` on subsequent requests |
| Complex prompt | Break into multiple smaller calls |

## Quick Reference

| Symptom | Cause | Fix |
|---------|-------|-----|
| Won't start | .unavailable | Check device/region/opt-in |
| exceededContextWindowSize | >4096 tokens | Condense transcript |
| guardrailViolation | Content policy | Handle gracefully |
| Hallucinated output | Wrong use case | Use for extraction only |
| Wrong structure | No @Generable | Use @Generable |
| Initial delay | Model loading | Prewarm session |
| UI frozen | Main thread | Use Task {} |

## Checklist

- [ ] Availability checked before session
- [ ] Using @Generable (not JSON)
- [ ] Handling context overflow
- [ ] Handling guardrails
- [ ] Streaming for >1s generations
- [ ] Not blocking UI
- [ ] Tools for external data
- [ ] Not using for world knowledge
