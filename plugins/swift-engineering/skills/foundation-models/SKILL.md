---
name: foundation-models
description: Use when implementing on-device AI with Apple's Foundation Models framework (iOS 26+). Covers @Generable structured output, LanguageModelSession, Tool calling, streaming responses, context limits, and avoiding pitfalls like blocking UI or using for world knowledge.
---

# Foundation Models

Apple's on-device AI framework providing access to a 3B parameter language model for summarization, extraction, classification, and content generation. Runs entirely on-device with no network required.

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
