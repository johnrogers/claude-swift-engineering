---
name: foundation-models
description: Use when implementing on-device AI with Apple's Foundation Models framework (iOS 26+), building summarization/extraction/classification features, or using @Generable for type-safe structured output.
---

# Foundation Models

Apple's on-device AI framework providing access to a 3B parameter language model for summarization, extraction, classification, and content generation. Runs entirely on-device with no network required.

## Overview

Foundation Models enable intelligent text processing directly on device without server round-trips, user data sharing, or network dependencies. The core principle: leverage on-device AI for specific, contained tasks (not for general knowledge).

## Quick Reference

| Reference | Load When |
|-----------|-----------|
| **[Getting Started](references/getting-started.md)** | Setting up LanguageModelSession, checking availability, basic prompts |
| **[Structured Output](references/structured-output.md)** | Using @Generable for type-safe responses, @Guide constraints |
| **[Tool Calling](references/tool-calling.md)** | Integrating external data (weather, contacts, MapKit) via Tool protocol |
| **[Streaming](references/streaming.md)** | AsyncSequence for progressive UI updates, PartiallyGenerated types |
| **[Troubleshooting](references/troubleshooting.md)** | Context overflow, guardrails, errors, anti-patterns |

## Core Workflow

1. Check availability with `SystemLanguageModel.default.availability`
2. Create `LanguageModelSession` with optional instructions
3. Choose output type: plain String or @Generable struct
4. Use streaming for long generations (>1 second)
5. Handle errors: context overflow, guardrails, unsupported language

## Model Capabilities

| Use Case | Foundation Models? | Alternative |
|----------|-------------------|-------------|
| Summarization | Yes | - |
| Extraction (key info) | Yes | - |
| Classification | Yes | - |
| Content tagging | Yes (built-in adapter) | - |
| World knowledge | No | ChatGPT, Claude, Gemini |
| Complex reasoning | No | Server LLMs |

## Platform Requirements

- iOS 26+, macOS 26+, iPadOS 26+, visionOS 26+
- Apple Intelligence-enabled device (iPhone 15 Pro+, M1+ iPad/Mac)
- User opted into Apple Intelligence

## Common Mistakes

1. **Using Foundation Models for world knowledge** — The 3B model is trained for on-device tasks only. It won't know current events, specific facts, or "who is X". Use ChatGPT/Claude for that. Keep prompts to: summarizing user's own content, extracting info, classifying text.

2. **Blocking the main thread** — LanguageModelSession calls must run on a background thread or async context. Blocking the main thread locks UI. Always use `Task { }` or background queue.

3. **Ignoring context overflow** — The model has finite context. If the user pastes a 50KB document, it will fail silently or truncate. Check input length and trim/truncate proactively.

4. **Forgetting to check availability** — Not all devices support Foundation Models. Check `SystemLanguageModel.default.availability` before using. Graceful degradation is required.

5. **Ignoring guardrails** — The model won't answer harmful queries. Instead of fighting it, design prompts that respect safety guidelines. Rephrasing requests usually works.
