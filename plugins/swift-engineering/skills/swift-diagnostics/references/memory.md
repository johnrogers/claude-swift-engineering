# Memory Diagnostics

Systematic debugging for retain cycles, memory leaks, and deallocation issues. 90% of memory leaks follow 3 patterns: timer leaks, observer leaks, and closure captures.

## Diagnostic Decision Table

| Symptom | Likely Cause | Diagnostic Tool |
|---------|--------------|-----------------|
| Memory grows 50MB -> 100MB -> 200MB | Retain cycle or timer leak | Memory Graph Debugger |
| App crashes after 10-15 minutes | Progressive memory leak | Instruments Allocations |
| deinit never called | Strong reference cycle | Memory Graph Debugger |
| Memory spike on specific action | Collection/closure leak | Allocations + filtering |
| Memory stays high after dismissing view | ViewController not deallocating | Add deinit logging |

## Mandatory First Checks

```swift
// 1. Add deinit logging to suspected class
class PlayerViewModel: ObservableObject {
    deinit {
        print("PlayerViewModel deallocated")
    }
}

// 2. Test deallocation
var vm: PlayerViewModel? = PlayerViewModel()
vm = nil  // Should print "deallocated"
```

```bash
# 3. Check device logs for memory warnings
# Connect device, open Xcode Console (Cmd+Shift+2)
# Look for: "Memory pressure critical", "Jetsam killed"

# 4. Check memory baseline
# Xcode > Product > Profile > Memory
# Perform action 5 times, check if memory keeps growing
```

## Decision Tree

```
Memory growing?
|-- Progressive growth every minute?
|   |-- Timer or notification leak -> Check Pattern 1 & 2
|
|-- Spike when action performed?
|   |-- Check if operation runs multiple times
|   |-- Spike then flat? -> Probably normal caching
|
|-- deinit not called?
|   |-- Use Memory Graph Debugger
|   |-- Look for purple/red circles with warning badge
|
|-- Can't tell from inspection?
    |-- Use Instruments > Allocations
    |-- Track object counts over time
```

## Common Leak Patterns

### Pattern 1: Timer Leaks (Most Common)

```swift
// WRONG - Timer never invalidated
class PlayerViewModel: ObservableObject {
    private var timer: Timer?

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.update()
        }
        // Timer never stopped -> keeps firing forever
    }
}

// CORRECT - Invalidate in deinit
class PlayerViewModel: ObservableObject {
    private var timer: Timer?

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.update()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }
}
```

### Pattern 2: Observer Leaks

```swift
// WRONG - Observer never removed
class PlayerViewModel: ObservableObject {
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleChange),
            name: .audioRouteChanged,
            object: nil
        )
    }
}

// CORRECT - Use Combine (auto-cleanup)
class PlayerViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: .audioRouteChanged)
            .sink { [weak self] _ in
                self?.handleChange()
            }
            .store(in: &cancellables)
    }
}
```

### Pattern 3: Closure Capture Leaks

```swift
// WRONG - Closure captures self strongly
class ViewController: UIViewController {
    var callbacks: [() -> Void] = []

    func addCallback() {
        callbacks.append {
            self.refresh()  // Strong capture
        }
    }
}

// CORRECT - Use weak self
class ViewController: UIViewController {
    var callbacks: [() -> Void] = []

    func addCallback() {
        callbacks.append { [weak self] in
            self?.refresh()
        }
    }

    deinit {
        callbacks.removeAll()
    }
}
```

### Pattern 4: Delegate Cycles

```swift
// WRONG - Strong delegate reference
class Player {
    var delegate: PlayerDelegate?  // Strong reference
}

class Controller: PlayerDelegate {
    var player: Player?

    init() {
        player = Player()
        player?.delegate = self  // Creates cycle
    }
}

// CORRECT - Weak delegate
class Player {
    weak var delegate: PlayerDelegate?
}
```

## Using Memory Graph Debugger

1. Run app in Xcode simulator
2. Debug > Memory Graph Debugger (or toolbar icon)
3. Wait for graph to generate (5-10 seconds)
4. Look for purple/red circles with warning badge
5. Click to see retain cycle chain

Example output:
```
PlayerViewModel
  ^ strongRef from: progressTimer
    ^ strongRef from: TimerClosure
      ^ CYCLE DETECTED
```

## Using Instruments Allocations

1. Product > Profile (Cmd+I)
2. Select "Allocations" template
3. Perform action 5-10 times
4. Check: Does memory line keep going UP?
   - YES -> Leak confirmed
   - NO -> Probably not a leak

```
Time -->
Memory
   |     -------- <- Memory keeps growing (LEAK)
   |    /
   |   /
   |  /
   +----------

vs normal:

   |  -------- <- Memory plateaus (OK)
   | /
   |/
   +----------
```

## PhotoKit Request Leaks

```swift
// WRONG - Requests accumulate without cancellation
func loadImage(asset: PHAsset) {
    imageManager.requestImage(for: asset, ...) { image, _ in
        self.imageView.image = image
    }
}

// CORRECT - Cancel in prepareForReuse
class PhotoCell: UICollectionViewCell {
    private var requestID: PHImageRequestID = PHInvalidImageRequestID

    func configure(asset: PHAsset) {
        if requestID != PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(requestID)
        }

        requestID = imageManager.requestImage(for: asset, ...) { [weak self] image, _ in
            self?.imageView.image = image
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        if requestID != PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(requestID)
            requestID = PHInvalidImageRequestID
        }
    }
}
```

## Quick Reference

| Leak Type | Detection | Fix |
|-----------|-----------|-----|
| Timer | deinit not called | invalidate() in deinit |
| Observer | Memory grows steadily | Use Combine + cancellables |
| Closure | Memory Graph shows cycle | [weak self] capture |
| Delegate | Both objects stay alive | weak var delegate |
| Image requests | Memory spikes on scroll | Cancel in prepareForReuse |

## Verification Checklist

After applying fix:
- [ ] deinit prints when expected
- [ ] Memory stays flat in Instruments
- [ ] No purple/red warnings in Memory Graph
- [ ] App doesn't crash after extended use
- [ ] Memory drops under simulated pressure (Xcode > Debug > Simulate Memory Warning)
