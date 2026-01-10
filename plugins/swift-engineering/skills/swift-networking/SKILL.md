---
name: swift-networking
description: Use when implementing Network.framework connections (NWConnection, NetworkConnection), debugging connection failures, migrating from sockets/URLSession streams, or handling network transitions. Covers UDP/TCP patterns, structured concurrency networking (iOS 26+), and common anti-patterns.
---

# Swift Networking

Network.framework is Apple's modern networking API for TCP/UDP connections, replacing BSD sockets with smart connection establishment, user-space networking, and seamless mobility handling.

## Reference Loading Guide

**ALWAYS load reference files if there is even a small chance the content may be required.** It's better to have the context than to miss a pattern or make a mistake.

| Reference | Load When |
|-----------|-----------|
| **[Getting Started](references/getting-started.md)** | Setting up NWConnection for TCP/UDP, choosing between APIs |
| **[Connection States](references/connection-states.md)** | Handling `.waiting`, `.ready`, `.failed` transitions |
| **[iOS 26+ Networking](references/ios26-networking.md)** | Using NetworkConnection with async/await, TLV framing, Coder protocol |
| **[Migration Guide](references/migration.md)** | Moving from sockets, CFSocket, SCNetworkReachability, URLSession |
| **[Troubleshooting](references/troubleshooting.md)** | Debugging timeouts, TLS failures, connection issues |

## Core Workflow

1. Choose transport (TCP/UDP/QUIC) based on use case
2. Create NWConnection (iOS 12+) or NetworkConnection (iOS 26+)
3. Set up state handler for connection lifecycle
4. Start connection on appropriate queue
5. Send/receive data with proper error handling
6. Handle network transitions (WiFi to cellular)

## When to Use Network.framework vs URLSession

- **URLSession**: HTTP, HTTPS, WebSocket, simple TCP/TLS streams
- **Network.framework**: UDP, custom protocols, low-level control, peer-to-peer, gaming

## Common Mistakes

1. **Ignoring state handlers** — Creating an NWConnection without a state change handler means you never learn when it's ready or failed. Always implement the state handler first.

2. **Blocking the main thread** — Never call `receive()` on the main queue. Use a background DispatchQueue or Task for all network operations.

3. **Wrong queue selection** — Using the wrong queue (UI queue for network work, or serial queue for concurrent reads) causes deadlocks or silent failures. Always explicit your queue choice.

4. **Not handling network transitions** — WiFi/cellular switches or network loss aren't always detected automatically. Implement viability checks and state monitoring for robust apps.

5. **Improper error recovery** — Network errors need retry logic with backoff. Immediately failing on transient errors (timeouts, temporary loss) creates poor UX.
