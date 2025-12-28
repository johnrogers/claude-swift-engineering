# Troubleshooting Network.framework

## Critical Anti-Patterns

### 1. SCNetworkReachability Before Connecting
```swift
// WRONG - Race condition
if SCNetworkReachabilityGetFlags(reachability, &flags).contains(.reachable) {
    connection.start()
}
```
**Fix**: Use `.waiting` state instead.

### 2. Blocking Socket on Main Thread
```swift
// WRONG - ANR (App Not Responding)
connect(socket, &addr, addrlen)
```
**Fix**: Use NWConnection (non-blocking).

### 3. Manual DNS with getaddrinfo
```swift
// WRONG - Misses Happy Eyeballs, proxies
getaddrinfo("example.com", "443", &hints, &results)
```
**Fix**: Use hostname in `NWEndpoint.Host()`.

### 4. Hardcoded IP Addresses
```swift
// WRONG - Breaks proxy/VPN
let host = "192.168.1.1"
```
**Fix**: Use hostnames.

### 5. Ignoring Waiting State
```swift
// WRONG - Poor UX
case .waiting: showError("Failed")
```
**Fix**: Show "Waiting for network..."

### 6. Missing [weak self]
```swift
// WRONG - Memory leak
connection.send(content: data) { error in self.handle(error) }
```
**Fix**: Use `[weak self]` or NetworkConnection (iOS 26+).

## Diagnostic Decision Tree

```
Not reaching .ready?
  Stuck in .preparing -> DNS failure (nslookup hostname)
  .waiting immediately -> No connectivity
  .failed POSIX 61 -> Connection refused (server down)
  .failed POSIX 50 -> Network interface down

TLS errors?
  -9806 -> Certificate invalid
  -9807 -> Certificate expired
  -9801 -> Protocol version

Data issues?
  Send OK, receive empty -> Framing (use TLV)
  Partial data -> Wrong byte count

Works WiFi, fails cellular?
  -> IPv6-only network, use hostname not IP
```

## Enable Logging

```
-NWLoggingEnabled 1
-NWConnectionLoggingEnabled 1
```

## Common POSIX Errors

| Code | Meaning |
|------|---------|
| 50 | Network down |
| 54 | Connection reset |
| 60 | Timeout |
| 61 | Connection refused |
| 65 | Host unreachable |

## TLS Certificate Issues

```bash
# Check certificate
openssl s_client -connect example.com:443 -showcerts
openssl s_client -connect example.com:443 | openssl x509 -noout -dates
```

**Development only** (never in production):
```swift
#if DEBUG
sec_protocol_options_set_verify_block(tlsOptions.securityProtocolOptions,
    { _, _, complete in complete(true) }, .main)
#endif
```

## Message Framing

TCP doesn't preserve boundaries:
```swift
send("A"); send("B"); send("C")
receive() -> "ABC"  // All at once
```

**Fix (iOS 26+)**: Use TLV
```swift
NetworkConnection(to: endpoint) { TLV { TLS() } }
```

**Fix (iOS 12+)**: Length prefix
```swift
var length = UInt32(data.count).bigEndian
connection.send(content: Data(bytes: &length, count: 4) + data, ...)
```

## Testing Checklist

- [ ] Real device (not simulator)
- [ ] WiFi and cellular
- [ ] Airplane Mode toggle
- [ ] WiFi to cellular transition
- [ ] IPv6-only network
- [ ] VPN active
- [ ] Weak signal

## Quick Reference

| Symptom | Check |
|---------|-------|
| Stuck in .preparing | `nslookup hostname` |
| .waiting immediately | Airplane Mode? |
| POSIX 61 | Server running? |
| TLS -9806 | `openssl s_client` |
| Data not received | Use TLV framing |
| Memory growing | Check [weak self] |
| Fails on cellular | Use hostname, not IP |
