# Getting Started with Network.framework

## API Selection

| iOS Version | API | Async Model |
|-------------|-----|-------------|
| iOS 12-25 | NWConnection | Completion handlers |
| iOS 26+ | NetworkConnection | async/await |

## Basic TLS Connection (iOS 12+)

```swift
import Network

let connection = NWConnection(
    host: NWEndpoint.Host("api.example.com"),
    port: NWEndpoint.Port(integerLiteral: 443),
    using: .tls
)

connection.stateUpdateHandler = { [weak self] state in
    switch state {
    case .ready:
        self?.sendRequest()
    case .waiting(let error):
        print("Waiting: \(error)")
    case .failed(let error):
        print("Failed: \(error)")
    default: break
    }
}

connection.start(queue: .main)
```

**Critical**: Always use `[weak self]` in NWConnection handlers.

## Basic TLS Connection (iOS 26+)

```swift
let connection = NetworkConnection(
    to: .hostPort(host: "api.example.com", port: 443)
) {
    TLS()  // TCP and IP inferred
}

func communicate() async throws {
    try await connection.send(Data("Hello".utf8))
    let response = try await connection.receive(exactly: 100).content
}
```

## UDP Connection

```swift
// iOS 12+
let udp = NWConnection(host: "game.example.com", port: 9000, using: .udp)

// iOS 26+
let udp = NetworkConnection(to: .hostPort(host: "game.example.com", port: 9000)) { UDP() }
```

## Custom Parameters

```swift
let parameters = NWParameters.tls
parameters.prohibitConstrainedPaths = true  // Respect Low Data Mode
parameters.prohibitExpensivePaths = true    // Don't use cellular
```

## Send with Pacing

```swift
connection.send(content: data, completion: .contentProcessed { [weak self] error in
    // contentProcessed = network consumed data, NOW send next chunk
    self?.sendNextChunk()
})
```

## Receive Data

```swift
connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) {
    [weak self] data, context, isComplete, error in
    if let data = data {
        self?.processData(data)
        self?.receiveMore()
    }
}
```

## UDP Batching (30% CPU Reduction)

```swift
connection.batch {
    for frame in frames {
        connection.send(content: frame, completion: .contentProcessed { _ in })
    }
}  // 100 datagrams = ~1 syscall
```

## Debugging

Add to Xcode scheme arguments:
```
-NWLoggingEnabled 1
-NWConnectionLoggingEnabled 1
```
