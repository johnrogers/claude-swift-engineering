---
name: ios-26-platform
description: Use when implementing iOS 26 Liquid Glass design, SwiftUI 26 APIs, or updating UI for iOS 26+ compatibility. Covers glassEffect modifiers, Regular vs Clear variants, WebView, Chart3D, @Animatable macro, rich text editing, toolbar customization, and backward compatibility patterns.
---

# iOS 26 Platform

iOS 26 introduces Liquid Glass, Apple's next-generation material design system that dynamically bends light, moves organically, and adapts automatically across all platforms.

## Quick Reference

| Reference | Load When |
|-----------|-----------|
| **[Liquid Glass](references/liquid-glass.md)** | Implementing glass effects, choosing Regular vs Clear variants, or understanding visual properties |
| **[Automatic Adoption](references/automatic-adoption.md)** | Understanding what iOS 26 changes automatically vs what requires code |
| **[SwiftUI APIs](references/swiftui-apis.md)** | Using WebView, Chart3D, @Animatable, AttributedString, or new view modifiers |
| **[Toolbar & Navigation](references/toolbar-navigation.md)** | Customizing toolbars with spacers, morphing, glass button styles, or search |
| **[Backward Compatibility](references/backward-compat.md)** | Supporting iOS 17/18 alongside iOS 26, or using UIDesignRequiresCompatibility |

## Core Workflow

1. **Check deployment target** — iOS 26+ required for Liquid Glass
2. **Recompile with Xcode 26** — Standard controls get glass automatically
3. **Identify navigation layer** — Apply glass to tab bars, toolbars, navigation (not content)
4. **Choose variant** — Regular (95% of cases) or Clear (media-rich backgrounds only)
5. **Add @available guards** — For backward compatibility with iOS 17/18
6. **Test accessibility** — Verify Reduce Transparency, Increase Contrast, Reduce Motion
