---
name: haptics
description: Use when adding haptic feedback for user confirmations (button presses, toggles, purchases), error notifications, or custom tactile patterns (Core Haptics). Covers UIFeedbackGenerator and CHHapticEngine patterns.
---

# Haptics

Haptic feedback provides tactile confirmation of user actions and system events. When designed thoughtfully, haptics transform interfaces from functional to delightful.

## Overview

Haptics should enhance interactions, not dominate them. The core principle: haptic feedback is like sound design—every haptic should have purpose (confirmation, error, warning), timing (immediate or delayed), and restraint (less is more).

## Reference Loading Guide

**ALWAYS load reference files if there is even a small chance the content may be required.** It's better to have the context than to miss a pattern or make a mistake.

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

## Common Mistakes

1. **Haptic feedback on every action** — Every button doesn't need haptics. Reserve haptics for critical confirmations (purchase, delete, settings change). Over-haptics are annoying and drain battery.

2. **Triggering haptics on main thread blocks** — Long haptic patterns can freeze UI briefly. Use background threads or async for Core Haptics `prepare()` calls to prevent jank.

3. **Haptic without audio/visual feedback** — Relying ONLY on haptics means deaf or deaf-blind users miss feedback. Always pair haptics with sound or visual response.

4. **Ignoring haptic settings** — Some users disable haptics system-wide. Check `UIFeedbackGenerator.isHapticFeedbackEnabled` before triggering. Graceful degradation is required.

5. **AHAP file errors silently** — Invalid AHAP files fail silently without errors. Test with Xcode's haptic designer and validate file syntax before shipping.

6. **Forgetting battery impact** — Continuous haptic patterns (progress bars, loading states) drain battery fast. Use haptics for state changes only, not ongoing feedback.
