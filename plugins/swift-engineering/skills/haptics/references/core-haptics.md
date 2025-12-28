# Core Haptics

Advanced haptic API for custom patterns. Available iOS 13+, requires iPhone 8+.

## Four Fundamental Elements

1. **Engine** (`CHHapticEngine`) - Link to the phone's actuator
2. **Player** (`CHHapticPatternPlayer`) - Playback control
3. **Pattern** (`CHHapticPattern`) - Collection of events over time
4. **Events** (`CHHapticEvent`) - Building blocks specifying the experience

## CHHapticEngine Lifecycle

```swift
import CoreHaptics

class HapticManager {
    private var engine: CHHapticEngine?

    func initializeHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            engine?.stoppedHandler = { [weak self] _ in self?.restartEngine() }
            engine?.resetHandler = { [weak self] in self?.restartEngine() }
            try engine?.start()
        } catch {
            print("Failed to create haptic engine: \(error)")
        }
    }

    private func restartEngine() {
        try? engine?.start()
    }
}
```

**Critical**: Always set `stoppedHandler` and `resetHandler` to handle system interruptions.

## CHHapticEvent Types

### Transient Events (short tap)

```swift
let event = CHHapticEvent(
    eventType: .hapticTransient,
    parameters: [
        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
    ],
    relativeTime: 0.0
)
```

**Parameters**:
- `hapticIntensity`: 0.0 (barely felt) to 1.0 (maximum)
- `hapticSharpness`: 0.0 (dull thud) to 1.0 (crisp snap)

### Continuous Events (sustained vibration)

```swift
let event = CHHapticEvent(
    eventType: .hapticContinuous,
    parameters: [
        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
    ],
    relativeTime: 0.0,
    duration: 2.0
)
```

## Creating and Playing Patterns

```swift
func playCustomPattern() {
    let events = [
        CHHapticEvent(eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            ], relativeTime: 0.0),
        CHHapticEvent(eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            ], relativeTime: 0.3)
    ]

    do {
        let pattern = try CHHapticPattern(events: events, parameters: [])
        let player = try engine?.makePlayer(with: pattern)
        try player?.start(atTime: CHHapticTimeImmediate)
    } catch {
        print("Failed to play pattern: \(error)")
    }
}
```

## Advanced Player: Looping and Dynamic Updates

```swift
func startRollingTexture() {
    let event = CHHapticEvent(
        eventType: .hapticContinuous,
        parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
        ],
        relativeTime: 0.0, duration: 0.5)

    do {
        let pattern = try CHHapticPattern(events: [event], parameters: [])
        let player = try engine?.makeAdvancedPlayer(with: pattern)
        player?.loopEnabled = true
        try player?.start(atTime: CHHapticTimeImmediate)
    } catch {
        print("Failed: \(error)")
    }
}

func updateIntensity(player: CHHapticAdvancedPatternPlayer?, value: Float) {
    let param = CHHapticDynamicParameter(
        parameterID: .hapticIntensityControl, value: value, relativeTime: 0)
    try? player?.sendParameters([param], atTime: CHHapticTimeImmediate)
}
```

## Troubleshooting

**Engine fails to start**:
- Device < iPhone 8 doesn't support Core Haptics
- Haptics disabled in Settings or Low Power Mode enabled

```swift
func safelyStartEngine() {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
        useFallbackHaptics() // Use UIFeedbackGenerator
        return
    }
    try? engine?.start()
}
```

**Haptics not felt**:
- Check Settings > Sounds & Haptics > System Haptics is ON
- Check Low Power Mode is OFF
- Verify intensity > 0.3 (values below may be too subtle)
