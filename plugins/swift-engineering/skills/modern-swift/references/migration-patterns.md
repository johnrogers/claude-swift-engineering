# Migration Patterns

Common patterns for migrating legacy Swift code to modern best practices.

## Delegate → AsyncStream

### ✅ Modern Pattern

```swift
// Before: Delegate pattern
protocol LocationManagerDelegate: AnyObject {
    func locationManager(_ manager: LocationManager, didUpdateLocation: Location)
}

class LocationManager {
    weak var delegate: LocationManagerDelegate?
}

// After: AsyncStream
class LocationManager {
    var locations: AsyncStream<Location> {
        AsyncStream { continuation in
            // Setup location updates
            self.onLocationUpdate = { location in
                continuation.yield(location)
            }
            continuation.onTermination = { _ in
                // Cleanup
            }
        }
    }
}

// Usage
for await location in locationManager.locations {
    updateUI(with: location)
}
```

**Effort:** ~3 hours per delegate
**Risk:** Medium - changes API surface

---

## UIKit → SwiftUI

### ✅ Modern Pattern

```swift
// Before: UIKit
class ProfileViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = user.name
        avatarImageView.load(url: user.avatarURL)
    }
}

// After: SwiftUI
struct ProfileView: View {
    let user: User

    var body: some View {
        VStack {
            AsyncImage(url: user.avatarURL) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())

            Text(user.name)
                .font(.headline)
        }
    }
}
```

**Effort:** ~8 hours per view controller
**Risk:** High - requires understanding of both frameworks

### Common UIKit → SwiftUI Mappings

| UIKit | SwiftUI |
|-------|---------|
| `UILabel` | `Text()` |
| `UIImageView` | `Image()` or `AsyncImage()` |
| `UIButton` | `Button()` |
| `UITextField` | `TextField()` |
| `UIStackView` | `VStack`, `HStack`, `ZStack` |
| `UIScrollView` | `ScrollView` |
| `UITableView` | `List` |
| `UINavigationController` | `NavigationStack` |

---

## Migration Workflow

### 1. Analyze

- Identify all occurrences of the pattern using Grep
- Map dependencies and call sites
- Estimate effort and risk

### 2. Plan

- Create migration checklist with TodoWrite
- Identify test points
- Plan rollback strategy if needed

### 3. Execute

- Migrate one component at a time
- Add compatibility shims if needed
- Update call sites progressively

### 4. Verify

- Run existing tests after each change
- Test edge cases
- Check performance impact

---

## Effort & Risk Table

| Migration Type | Typical Effort | Risk Level | Notes |
|---------------|----------------|------------|-------|
| Completion → async/await | ~2 hours/file | Low | Well-supported by compiler |
| DispatchQueue → Actor | ~4 hours/class | Medium | Requires understanding concurrency boundaries |
| Delegate → AsyncStream | ~3 hours/delegate | Medium | Changes API surface |
| UIKit → SwiftUI | ~8 hours/view controller | High | Requires both framework knowledge |
| Add Sendable | ~1 hour/type | Low | Compile-time verification |

---

## Deprecated API Replacements

Always check Sosumi MCP server for current API status and replacements:

| Deprecated | Modern Replacement |
|-----------|-------------------|
| `UIApplication.shared.keyWindow` | `UIApplication.shared.connectedScenes` |
| `UIDevice.current.name` | Privacy manifest required |
| `URLSession.dataTask` | `URLSession.data(from:)` |

Use Sosumi to verify deprecation status and find migration guides for 2025.
