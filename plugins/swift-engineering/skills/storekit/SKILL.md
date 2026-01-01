---
name: storekit
description: Use when implementing in-app purchases, StoreKit 2 subscriptions, consumables, non-consumables, or transaction handling. Covers testing-first workflow with .storekit configuration, StoreManager architecture, and transaction verification.
---

# StoreKit

StoreKit 2 patterns for implementing in-app purchases with async/await APIs, automatic verification, and SwiftUI integration.

## Quick Reference

| Reference | Load When |
|-----------|-----------|
| **[Getting Started](references/getting-started.md)** | Setting up .storekit configuration file, testing-first workflow |
| **[Products](references/products.md)** | Loading products, product types, purchasing with Product.purchase() |
| **[Subscriptions](references/subscriptions.md)** | Auto-renewable subscriptions, subscription groups, offers, renewal tracking |
| **[Transactions](references/transactions.md)** | Transaction listener, verification, finishing transactions, restore purchases |
| **[StoreKit Views](references/storekit-views.md)** | ProductView, SubscriptionStoreView, SubscriptionOfferView in SwiftUI |

## Core Workflow

1. Create `.storekit` configuration file first (before any code)
2. Test purchases locally in Xcode simulator
3. Implement centralized `StoreManager` with `@MainActor`
4. Set up `Transaction.updates` listener at app launch
5. Display products with `ProductView` or custom UI
6. Always call `transaction.finish()` after granting entitlements

## Essential Architecture

```swift
@MainActor
final class StoreManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    private var transactionListener: Task<Void, Never>?

    init() {
        transactionListener = listenForTransactions()
        Task { await loadProducts() }
    }
}
```

## Common Mistakes

1. **Missing `.finish()` calls on transactions** — Forgetting to call `transaction.finish()` after granting entitlements causes transactions to never complete. The user won't see their purchase reflected. Always call `finish()`.

2. **Unsafe StoreManager state** — Shared `StoreManager` without `@MainActor` can have race conditions. Multiple async tasks can update `@Published` properties concurrently, corrupting state. Use `@MainActor` for thread safety.

3. **No transaction listener at app launch** — Not setting up `Transaction.updates` listener means app crashes or misses refunded/canceled purchases. Listen for transactions immediately in `@main`, not when user taps purchase button.

4. **Hardcoded product IDs** — Hardcoded IDs make testing and localization hard. Use configuration files or environment variables for product IDs. Same applies to prices (fetch from App Store, don't hardcode).

5. **Ignoring verification failures** — App Store verification fails silently sometimes. Not checking verification status means accepting unverified transactions (security risk). Always verify before granting entitlements.
