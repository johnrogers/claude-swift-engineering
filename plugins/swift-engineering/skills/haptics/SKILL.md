---
name: haptics
description: Use when implementing haptic feedback with UIFeedbackGenerator or Core Haptics (CHHapticEngine). Covers Causality-Harmony-Utility design principles, AHAP patterns, audio-haptic synchronization, and haptic timing best practices.
---

# Haptics

Haptic feedback provides tactile confirmation of user actions and system events. When designed thoughtfully, haptics transform interfaces from functional to delightful.

## Quick Reference

| Reference | Load When |
|-----------|-----------|
| **[UIFeedbackGenerator](references/uifeedbackgenerator.md)** | Using simple impact/selection/notification haptics |
| **[Core Haptics](references/core-haptics.md)** | Creating custom patterns with CHHapticEngine |
| **[AHAP Patterns](references/ahap-patterns.md)** | Working with Apple Haptic Audio Pattern files |
| **[Design Principles](references/design-principles.md)** | Applying Causality, Harmony, Utility framework |

## Core Workflow

1. **Choose complexity level**: Simple (UIFeedbackGenerator) vs Custom (Core Haptics)
2. **For simple haptics**: Use UIImpactFeedbackGenerator, UISelectionFeedbackGenerator, or UINotificationFeedbackGenerator
3. **For custom patterns**: Create CHHapticEngine, define CHHapticEvents, build CHHapticPattern
4. **Prepare before triggering**: Call `prepare()` to reduce latency
5. **Apply design principles**: Ensure Causality (timing), Harmony (multimodal), Utility (meaningful)

## System Requirements

- **iOS 10+** for UIFeedbackGenerator
- **iOS 13+** for Core Haptics (CHHapticEngine)
- **iPhone 8+** for Core Haptics hardware support
- **Physical device required** - haptics cannot be tested in Simulator
