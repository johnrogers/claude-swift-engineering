# Connection State Handling

## State Machine

```
setup -> preparing -> waiting <-> ready -> failed/cancelled
```

| State | Meaning | Action |
|-------|---------|--------|
| `.preparing` | DNS, TCP, TLS handshake | Show "Connecting..." |
| `.waiting(error)` | No network, retrying automatically | Show "Waiting for network..." |
| `.ready` | Connected | Begin send/receive |
| `.failed(error)` | Unrecoverable | Show error, offer retry |
| `.cancelled` | `cancel()` called | Clean up |

## State Handling (iOS 12+)

```swift
connection.stateUpdateHandler = { [weak self] state in
    switch state {
    case .preparing:
        self?.updateUI(.connecting)
    case .waiting(let error):
        // DON'T fail here - framework retries when network returns
        self?.updateUI(.waiting)
    case .ready:
        self?.startCommunication()
    case .failed(let error):
        self?.showError(error)
    case .cancelled:
        self?.cleanup()
    @unknown default: break
    }
}
```

## State Handling (iOS 26+)

```swift
Task {
    for await state in connection.states {
        switch state {
        case .preparing: print("Connecting...")
        case .waiting(let error): print("Waiting: \(error)")
        case .ready: await startCommunication()
        case .failed(let error): print("Failed: \(error)")
        case .cancelled: print("Cancelled")
        @unknown default: break
        }
    }
}
```

## The Waiting State (Critical)

`.waiting` means network unavailable but framework **retries automatically**.

```swift
// WRONG - Poor UX
case .waiting:
    showError("Connection failed")

// CORRECT
case .waiting:
    showStatus("Waiting for network...")
```

## Viability Updates

```swift
connection.viabilityUpdateHandler = { isViable in
    if !isViable {
        // Don't tear down! May recover when network returns
        showStatus("Connection interrupted...")
    }
}
```

## Better Path Available

```swift
connection.betterPathUpdateHandler = { betterPathAvailable in
    if betterPathAvailable {
        migrateToNewConnection()
    }
}
```

## Multipath TCP

```swift
let parameters = NWParameters.tcp
parameters.multipathServiceType = .handover  // Seamless WiFi/cellular transition
```

## Common POSIX Errors

| Code | Meaning |
|------|---------|
| 50 | Network interface down |
| 54 | Connection reset by peer |
| 60 | Connection timed out |
| 61 | Connection refused (server not listening) |
| 65 | Host unreachable |

## NWPathMonitor

```swift
let monitor = NWPathMonitor()
monitor.pathUpdateHandler = { path in
    if path.status == .satisfied {
        if path.usesInterfaceType(.wifi) { print("WiFi") }
        if path.isExpensive { print("Cellular/hotspot") }
    }
}
monitor.start(queue: .main)
```

Use for global UI updates, **not** pre-connection checks.
