---
name: swiftui-advanced
description: Use when implementing gesture composition (simultaneous, sequenced, exclusive), adaptive layouts (ViewThatFits, AnyLayout, size classes), or choosing architecture patterns (MVVM vs TCA vs vanilla, State-as-Bridge). Covers advanced SwiftUI patterns beyond basic views.
---

# SwiftUI Advanced

Advanced SwiftUI patterns for gesture composition, adaptive layouts, architecture decisions, and performance optimization.

## Reference Loading Guide

**ALWAYS load reference files if there is even a small chance the content may be required.** It's better to have the context than to miss a pattern or make a mistake.

| Reference | Load When |
|-----------|-----------|
| **[Gestures](references/gestures.md)** | Composing multiple gestures, GestureState, custom recognizers |
| **[Adaptive Layout](references/adaptive-layout.md)** | ViewThatFits, AnyLayout, size classes, iOS 26 free-form windows |
| **[Architecture](references/architecture.md)** | MVVM vs TCA decision, State-as-Bridge, property wrapper selection |
| **[Performance](references/performance.md)** | Instruments 26, view body optimization, unnecessary updates |

## Core Workflow

1. **Identify pattern category** from user's question
2. **Load relevant reference** for detailed patterns and code examples
3. **Apply pattern** following the decision trees and anti-patterns
4. **Verify** using provided checklists or profiling guidance

## Decision Trees

### Gesture Composition
- Both gestures at same time? -> `.simultaneously`
- One must complete before next? -> `.sequenced`
- Only one should win? -> `.exclusively`

### Layout Adaptation
- Pick best-fitting variant? -> `ViewThatFits`
- Animated H/V switch? -> `AnyLayout`
- Need actual dimensions? -> `onGeometryChange`

### Architecture Selection
- Small app, Apple patterns? -> @Observable + State-as-Bridge
- Complex presentation logic? -> MVVM with @Observable
- Rigorous testability needed? -> TCA

## Common Mistakes

1. **Gesture composition order matters** — `.simultaneously` and `.sequenced` have different trigger timing. Swapping them silently changes behavior. Understand gesture semantics before using.

2. **ViewThatFits over-used** — ViewThatFits remeasures on every view change. For animated H/V switches, use `AnyLayout` instead. Use ViewThatFits only for static variant selection.

3. **onGeometryChange triggering unnecessary updates** — Reading geometry changes geometry, which triggers updates, which changes geometry... circular. Use `.onGeometryChange` only with proper state management to avoid loops.

4. **Architecture mismatch mid-project** — Starting with @Observable + State-as-Bridge then realizing you need TCA is expensive. Choose architecture upfront based on complexity (small app = @Observable, complex = TCA).

5. **Ignoring view body optimization** — Computing expensive calculations in view body repeatedly kills performance. Move calculations to properties or models. Profile with Instruments 26 before optimizing prematurely.
