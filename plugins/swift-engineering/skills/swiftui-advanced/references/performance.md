# SwiftUI Performance

## Core Principle

Ensure view bodies update quickly and only when needed.

## Two Problems

1. **Long View Body Updates** - Body takes too long
2. **Unnecessary Updates** - Views update when data hasn't changed

## SwiftUI Instrument (Instruments 26)

1. Press **Cmd-I** in Xcode
2. Choose **SwiftUI template**
3. Check **Long View Body Updates** lane (red = priority)

## Problem 1: Long Updates

### Formatter Creation

```swift
// WRONG - creates every render
var body: some View {
    let formatter = NumberFormatter()
    Text(formatter.string(from: price)!)
}

// CORRECT - cache formatters
class Formatters {
    static let currency: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        return f
    }()
}
```

### Complex Calculations

```swift
// WRONG
var body: some View {
    Text("\(data.sorted().last ?? 0)")
}

// CORRECT - compute in model
@Observable class ViewModel {
    var data: [Int] { didSet { maxValue = data.max() ?? 0 } }
    private(set) var maxValue = 0
}
```

### Synchronous I/O

```swift
// NEVER
var body: some View {
    let data = try? Data(contentsOf: url)
}

// CORRECT
.task { data = try? await loadData() }
```

## Problem 2: Unnecessary Updates

Many small updates add up to miss frame deadline.

### Shared Dependencies

```swift
// WRONG - all views depend on whole array
func isFavorite(_ item: Item) -> Bool {
    favorites.contains(item)  // Depends on entire array
}

// CORRECT - per-item view models
@Observable class ItemViewModel { var isFavorite = false }

class ModelData {
    var itemViewModels: [ID: ItemViewModel] = [:]
}
```

### Environment Values

```swift
// WRONG - updates 60x/second
.environment(\.scrollOffset, offset)

// CORRECT - pass directly
ChildView(scrollOffset: offset)
```

## iOS 26 Automatic Wins

Rebuild with iOS 26 SDK:
- 6x faster list loading (100k+ items)
- 16x faster list updates
- Reduced dropped frames
- Nested ScrollView lazy loading

## 30-Minute Diagnostic Protocol

| Step | Time |
|------|------|
| Build Release | 5 min |
| Trigger issue | 3 min |
| Record trace | 5 min |
| Review Long Updates | 5 min |
| Check Cause & Effect | 5 min |
| Identify view | 2 min |

## Before Shipping a Fix

- [ ] Ran SwiftUI Instrument?
- [ ] Know which view is expensive?
- [ ] Can explain why fix helps?
- [ ] Verified in Instruments?

## Key Patterns

**Per-item dependencies:**
```swift
// Each view depends only on its model
@Observable class ItemViewModel { var item: Item }
```

**Formatter reuse:**
```swift
static let dateFormatter: DateFormatter = { ... }()
```

**Cached computations:**
```swift
var data: [Int] { didSet { cached = compute(data) } }
```
