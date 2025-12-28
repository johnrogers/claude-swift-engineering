# Haptic Design Principles

Apple's Causality-Harmony-Utility framework from WWDC 2021 for multimodal feedback design.

## Causality: Make it Obvious What Caused the Feedback

**Problem**: User can't tell what triggered the haptic.
**Solution**: Haptic timing must match the visual/interaction moment.

### Good vs Bad Timing

```swift
// Good: Immediate feedback on touch
@objc func buttonTapped() {
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred()  // Fire immediately
    performAction()
}

// Bad: Delayed feedback loses causality
@objc func buttonTapped() {
    performAction()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()  // Too late - user confused
    }
}
```

### WWDC Example
- Ball hits wall -> haptic fires at collision moment (correct)
- Ball hits wall -> haptic fires 100ms later (confusing)

### Key Insight
Fire haptic at the **exact moment** the visual change occurs. Even 100ms delay breaks the illusion of physical feedback.

## Harmony: Senses Work Best When Coherent

**Problem**: Visual, audio, and haptic don't match.
**Solution**: All three senses should feel like a unified experience.

### Matching Intensity Across Senses

| Object | Visual | Audio | Haptic |
|--------|--------|-------|--------|
| Small ball | Small, light | High pitch | `.light` or low intensity |
| Large ball | Large, heavy | Low pitch | `.heavy` or high intensity |

### Code Pattern

```swift
func playImpact(for objectMass: CGFloat) {
    // Match haptic intensity to visual/audio characteristics
    let normalizedMass = min(max(objectMass / 100.0, 0.0), 1.0)

    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred(intensity: normalizedMass)

    // Audio pitch should also scale with mass
    playSound(pitch: 1.0 - (normalizedMass * 0.5))
}
```

### WWDC Example: Shield Transformation
Initial attempt: 3 transient pulses (haptic) + progressive continuous sound (audio) - no harmony.
Solution: Continuous haptic + continuous audio - unified experience.

## Utility: Provide Clear Value

**Problem**: Haptics used everywhere "just because we can."
**Solution**: Reserve haptics for significant moments that benefit the user.

### When to Use Haptics

| Use Case | Why |
|----------|-----|
| Confirming important action | Payment completed, message sent |
| Alerting to critical events | Low battery, error occurred |
| Providing continuous feedback | Scrubbing slider, dragging item |
| Enhancing delight | App launch flourish, achievement |

### When NOT to Use Haptics

| Avoid | Why |
|-------|-----|
| Every single tap | Overwhelming, loses meaning |
| Scrolling through lists | Battery drain, no value |
| Background events | Confusing, user can't see cause |
| Decorative animations | No user benefit |

### Decision Framework

```swift
func shouldPlayHaptic(for event: UserEvent) -> Bool {
    switch event {
    case .buttonTap(let importance):
        return importance == .high  // Only important buttons
    case .selectionChange:
        return true  // Picker-style selection feedback
    case .scroll:
        return false  // Never haptic on scroll
    case .success, .error:
        return true  // Always confirm outcomes
    }
}
```

## Audio-Haptic Synchronization

### Matching Animation Timing

```swift
func performShieldTransformation() {
    // Start haptic simultaneously with animation
    playShieldPattern()

    UIView.animate(withDuration: 0.5) {
        self.shieldView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
    }
}
```

### Coordinated Start

```swift
func playCoordinatedExperience() {
    impactGenerator.prepare()  // Reduce latency

    // Start both simultaneously
    audioPlayer.play()
    impactGenerator.impactOccurred()
}
```

## Testing Checklist

- [ ] Does the haptic fire at the exact moment of visual change? (Causality)
- [ ] Do visual, audio, and haptic feel unified? (Harmony)
- [ ] Does this haptic provide clear value to the user? (Utility)
- [ ] Is the intensity appropriate for the action?
- [ ] Test with haptics disabled - does the UI still work?

## Related WWDC Sessions

- Practice audio haptic design (WWDC 2021/10278)
- Introducing Core Haptics (WWDC 2019/520)
- Expanding the Sensory Experience (WWDC 2019/223)
