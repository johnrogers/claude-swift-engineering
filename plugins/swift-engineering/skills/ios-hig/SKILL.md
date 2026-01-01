---
name: ios-hig
description: Use when designing iOS interfaces, implementing accessibility (VoiceOver, Dynamic Type), handling dark mode, ensuring adequate touch targets, providing animation/haptic feedback, or requesting user permissions. Apple Human Interface Guidelines for iOS compliance.
---

# iOS Human Interface Guidelines

Apple's Human Interface Guidelines define the visual language, interaction patterns, and accessibility standards that make iOS apps feel native and intuitive. The core principle: clarity and consistency through thoughtful design.

## Overview

- **[Interaction](references/interaction.md)** - Touch targets, navigation, layout, hierarchy
- **[Content](references/content.md)** - Empty states, writing copy, typography
- **[Visual Design](references/visual-design.md)** - Colors, materials, contrast, dark mode
- **[Accessibility](references/accessibility.md)** - VoiceOver, Dynamic Type, Reduce Motion
- **[Feedback](references/feedback.md)** - Animations, haptics, loading states, errors
- **[Performance](references/performance-platform.md)** - Responsiveness, system components
- **[Privacy](references/privacy-permissions.md)** - Permission requests, data handling

## Common Mistakes

1. **Touch targets smaller than 44x44 points** — Buttons and interactive elements must be at least 44x44 points (iOS) to accommodate thumbs. Smaller targets cause frustrated users and accessibility failures.

2. **Ignoring Dynamic Type constraints** — Text with fixed sizes doesn't respect user accessibility settings. Use Dynamic Type sizes, test with Large or Extra Large settings, and avoid hardcoded font sizes.

3. **Insufficient color contrast in dark mode** — Colors that work in light mode may fail accessibility in dark mode. Test with Reduce Contrast accessibility setting enabled for both modes.

4. **Over-animating transitions** — Animations that feel smooth at 60fps can trigger motion sickness in users with vestibular issues. Respect Reduce Motion settings and keep animations under 300ms.

5. **Missing VoiceOver labels on custom controls** — Custom buttons, toggles, or interactive views need `.accessibilityLabel()` and `.accessibilityHint()` or they're completely unusable to screen reader users.

6. **Haptic overuse** — Every action does NOT need haptic feedback. Reserve haptics for confirmations (purchase, critical action) and errors. Excessive haptics are annoying and drain battery.
