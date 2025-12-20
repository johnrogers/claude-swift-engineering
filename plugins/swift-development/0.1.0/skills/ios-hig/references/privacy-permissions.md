# Privacy and Permissions

Apple Human Interface Guidelines for requesting permissions and handling sensitive data.

## Critical Rules

- Request permissions **in context**, right before the feature needs it—never at app launch without cause
- Explain **why** in user language and connect it to a clear benefit
- If denied, provide a functional fallback and a clear path to Settings when appropriate
- Minimize data collection; don't surface sensitive data in logs or UI where not needed

## Examples

### Permission Request Pattern

```swift
// ✅ Ask in context and handle denial gracefully
Button("Enable notifications") {
    model.requestNotifications()
}
// On denial: show a non-blocking explanation + "Open Settings" action

// ❌ Permission request on launch with no context
struct AppStart {
    func start() {
        model.requestNotifications()
        model.requestLocation()
    }
}
```

### Complete Permission Flow

```swift
// ✅ Full permission flow with context and fallback
struct NotificationSettingsView: View {
    @State private var showingDeniedAlert = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Get notified when items are shared with you")
                .font(.headline)

            Text("Turn on notifications to stay updated when friends share links and notes.")
                .font(.body)
                .foregroundStyle(.secondary)

            Button("Enable Notifications") {
                Task {
                    let granted = await requestNotificationPermission()
                    if !granted {
                        showingDeniedAlert = true
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .alert("Notifications Disabled", isPresented: $showingDeniedAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Not Now", role: .cancel) {}
        } message: {
            Text("To receive notifications, enable them in Settings.")
        }
    }

    func requestNotificationPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }
}
```

## Guidelines

### When to Request Permissions

**Good timing**:
- Right before using the feature (user taps "Add location")
- During feature onboarding (user enters location-based feature)
- When user explicitly opts in (settings toggle)

**Bad timing**:
- App launch before any context
- Background without user interaction
- Bundled with other unrelated requests

### How to Request Permissions

**Clear value proposition**:
- Explain the benefit in user terms
- Show what they'll gain, not what you need
- Use the feature's context to explain why

**Examples**:
- ✅ "Get notified when items are shared with you"
- ❌ "This app would like to send you notifications"
- ✅ "Save your location to remember where you found this"
- ❌ "Allow location access"

### Handling Denial

**Graceful fallback**:
- Don't block the entire feature if possible
- Provide alternative workflows
- Only show Settings path if user might want to change their mind

**Examples**:
- Location denied → Manual address entry
- Notifications denied → In-app badge/indicator
- Camera denied → Photo library picker

### Privacy Best Practices

**Data minimization**:
- Only request what you actually need
- Don't log sensitive data (passwords, tokens, personal info)
- Don't display sensitive data in UI unless necessary
- Clear sensitive data when no longer needed

**User control**:
- Provide clear settings to manage data
- Allow users to delete their data
- Respect system privacy settings

## Common Permissions

### Notifications

```swift
// Request with UNUserNotificationCenter
let granted = try await UNUserNotificationCenter.current()
    .requestAuthorization(options: [.alert, .sound, .badge])
```

**When to ask**: Before subscribing to notification topics or when user enables a notification-dependent feature

### Location

```swift
// Request with CLLocationManager
locationManager.requestWhenInUseAuthorization()
```

**When to ask**: Right before adding a location-based item or enabling location features

### Photos

```swift
// Request with PHPhotoLibrary
let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
```

**When to ask**: When user taps "Add photo" or similar action

### Camera

```swift
// Request with AVCaptureDevice
let granted = await AVCaptureDevice.requestAccess(for: .video)
```

**When to ask**: Right before showing camera interface

## Summary

**Key Principles**:
1. Request permissions in context, never at app launch
2. Explain the benefit in user terms
3. Handle denial gracefully with fallbacks
4. Provide path to Settings when appropriate
5. Minimize data collection and logging
6. Respect system privacy settings
7. Give users control over their data
