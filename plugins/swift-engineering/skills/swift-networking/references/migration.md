# Migration Guide

## API Mapping

| Legacy API | Network.framework |
|------------|-------------------|
| `socket() + connect()` | `NWConnection` |
| `send() / recv()` | `connection.send() / receive()` |
| `bind() + listen()` | `NWListener` |
| `getaddrinfo()` | Use hostname in `NWEndpoint.Host()` |
| `SCNetworkReachability` | `.waiting` state |
| `CFSocket / NSStream` | `NWConnection` |
| `NSNetService` | `NWBrowser` |

## From BSD Sockets

```c
// WRONG - Blocks main thread
int sock = socket(AF_INET, SOCK_STREAM, 0);
connect(sock, &addr, addrlen);  // BLOCKS
```

```swift
// CORRECT
let connection = NWConnection(host: "example.com", port: 443, using: .tls)
connection.stateUpdateHandler = { [weak self] state in
    if case .ready = state { self?.sendData() }
}
connection.start(queue: .main)  // Non-blocking
```

## From SCNetworkReachability

```swift
// WRONG - Race condition
if SCNetworkReachabilityGetFlags(reachability, &flags) {
    if flags.contains(.reachable) {
        connection.start()  // Network may change!
    }
}

// CORRECT - Use waiting state
connection.stateUpdateHandler = { state in
    switch state {
    case .waiting: showStatus("Waiting for network...")
    case .ready: startCommunication()
    case .failed: showError("Failed")
    default: break
    }
}
```

## From getaddrinfo

```c
// WRONG - Misses Happy Eyeballs, proxies
getaddrinfo("example.com", "443", &hints, &results);
```

```swift
// CORRECT - Framework handles DNS, IPv4/IPv6 racing
let connection = NWConnection(
    host: NWEndpoint.Host("example.com"),  // Hostname, not IP
    port: 443, using: .tls
)
```

## From URLSession StreamTask

```swift
// Before
let task = URLSession.shared.streamTask(withHostName: "example.com", port: 443)
task.write(data, timeout: 10) { _ in }

// After (iOS 26+)
let connection = NetworkConnection(to: .hostPort(host: "example.com", port: 443)) { TLS() }
try await connection.send(data)
```

## From NWConnection to NetworkConnection

| NWConnection | NetworkConnection |
|--------------|-------------------|
| `stateUpdateHandler = {}` | `for await state in states` |
| `send(content:completion:)` | `try await send()` |
| `receive(min:max:completion:)` | `try await receive()` |
| `[weak self]` everywhere | No weak self needed |
| Manual JSON | `Coder(Type.self, using: .json)` |

```swift
// Before
connection.stateUpdateHandler = { [weak self] state in
    if case .ready = state { self?.sendData() }
}

// After
Task {
    for await state in connection.states {
        if case .ready = state {
            try await connection.send(data)
        }
    }
}
```

## Migration Checklist

- [ ] Removed SCNetworkReachability
- [ ] Removed getaddrinfo / manual DNS
- [ ] Removed CFSocket / NSStream
- [ ] Using hostnames, not IPs
- [ ] Handling `.waiting` state
- [ ] Using `[weak self]` in NWConnection handlers
- [ ] Tested on real device
- [ ] Tested WiFi/cellular transitions
