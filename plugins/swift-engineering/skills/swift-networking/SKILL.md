---
name: swift-networking
description: Use when implementing Network.framework connections (NWConnection, NetworkConnection), debugging connection failures, migrating from sockets/URLSession streams, or handling network transitions. Covers UDP/TCP patterns, structured concurrency networking (iOS 26+), and common anti-patterns.
---

# Swift Networking

Network.framework is Apple's modern networking API for TCP/UDP connections, replacing BSD sockets with smart connection establishment, user-space networking, and seamless mobility handling.

## Quick Reference

| Reference | Load When |
|-----------|-----------|
| **[Getting Started](references/getting-started.md)** | Setting up NWConnection for TCP/UDP, choosing between APIs |
| **[Connection States](references/connection-states.md)** | Handling .waiting, .ready, .failed transitions |
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
