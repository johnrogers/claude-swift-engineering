# AHAP Patterns

AHAP (Apple Haptic Audio Pattern) files are JSON files combining haptic events and audio.

## Basic AHAP Structure

```json
{
  "Version": 1.0,
  "Metadata": { "Project": "My App", "Created": "2024-01-15" },
  "Pattern": [
    {
      "Event": {
        "Time": 0.0,
        "EventType": "HapticTransient",
        "EventParameters": [
          { "ParameterID": "HapticIntensity", "ParameterValue": 1.0 },
          { "ParameterID": "HapticSharpness", "ParameterValue": 0.5 }
        ]
      }
    }
  ]
}
```

## Event Types

### HapticTransient (short tap)
```json
{ "Event": { "Time": 0.0, "EventType": "HapticTransient",
    "EventParameters": [
      { "ParameterID": "HapticIntensity", "ParameterValue": 0.8 },
      { "ParameterID": "HapticSharpness", "ParameterValue": 0.6 }
    ] } }
```

### HapticContinuous (sustained vibration)
```json
{ "Event": { "Time": 0.0, "EventType": "HapticContinuous", "EventDuration": 0.5,
    "EventParameters": [
      { "ParameterID": "HapticIntensity", "ParameterValue": 0.6 },
      { "ParameterID": "HapticSharpness", "ParameterValue": 0.3 }
    ] } }
```

### AudioCustom (synchronized audio)
```json
{ "Event": { "Time": 0.0, "EventType": "AudioCustom",
    "EventWaveformPath": "impact_sound.wav",
    "EventParameters": [{ "ParameterID": "AudioVolume", "ParameterValue": 0.8 }]
  } }
```

## Loading AHAP Files

```swift
func loadAHAPPattern(named name: String) -> CHHapticPattern? {
    guard let url = Bundle.main.url(forResource: name, withExtension: "ahap") else {
        return nil
    }
    return try? CHHapticPattern(contentsOf: url)
}

// Usage
func playPattern() {
    guard let pattern = loadAHAPPattern(named: "ShieldTransient") else { return }
    let player = try? engine?.makePlayer(with: pattern)
    try? player?.start(atTime: CHHapticTimeImmediate)
}
```

## Multi-Event Crescendo Pattern

```json
{
  "Version": 1.0,
  "Pattern": [
    { "Event": { "Time": 0.0, "EventType": "HapticTransient",
        "EventParameters": [
          { "ParameterID": "HapticIntensity", "ParameterValue": 0.3 },
          { "ParameterID": "HapticSharpness", "ParameterValue": 0.3 }] } },
    { "Event": { "Time": 0.15, "EventType": "HapticTransient",
        "EventParameters": [
          { "ParameterID": "HapticIntensity", "ParameterValue": 0.6 },
          { "ParameterID": "HapticSharpness", "ParameterValue": 0.5 }] } },
    { "Event": { "Time": 0.3, "EventType": "HapticTransient",
        "EventParameters": [
          { "ParameterID": "HapticIntensity", "ParameterValue": 1.0 },
          { "ParameterID": "HapticSharpness", "ParameterValue": 0.8 }] } }
  ]
}
```

## Parameter Curves

Smooth intensity transitions:

```json
{
  "Version": 1.0,
  "Pattern": [
    { "Event": { "Time": 0.0, "EventType": "HapticContinuous", "EventDuration": 1.0,
        "EventParameters": [
          { "ParameterID": "HapticIntensity", "ParameterValue": 0.5 },
          { "ParameterID": "HapticSharpness", "ParameterValue": 0.5 }] } },
    { "ParameterCurve": { "ParameterID": "HapticIntensityControl", "Time": 0.0,
        "ParameterCurveControlPoints": [
          { "Time": 0.0, "ParameterValue": 0.0 },
          { "Time": 0.5, "ParameterValue": 1.0 },
          { "Time": 1.0, "ParameterValue": 0.0 }] } }
  ]
}
```

## Audio File Requirements

- **Maximum size**: 4.2 MB
- **Maximum duration**: 23 seconds
- **Formats**: WAV, CAF, AIFF, AAC
- **Recommended**: Use AAC for smaller file sizes

## Troubleshooting

- **AHAP fails to load**: Verify JSON syntax, check audio file paths, ensure files in bundle
- **Audio out of sync**: Audio file too large/long, test on physical device
