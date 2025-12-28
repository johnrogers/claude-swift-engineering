# Environment (iOS 17+)

## environment(_:) — NOT environmentObject(_:)

### ✅ Modern Pattern
```swift
@Observable
class AppSettings {
    var isDarkMode: Bool = false
}

// Inject into environment
struct MyApp: App {
    @State private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(settings)
        }
    }
}

// Access in child view
struct SettingsView: View {
    @Environment(AppSettings.self) private var settings

    var body: some View {
        Toggle("Dark Mode", isOn: $settings.isDarkMode)
    }
}
```

### ❌ Deprecated Pattern
```swift
// NEVER use .environmentObject(_:) with @Observable
.environmentObject(settings)

// NEVER use @EnvironmentObject with @Observable
@EnvironmentObject var settings: AppSettings
```
