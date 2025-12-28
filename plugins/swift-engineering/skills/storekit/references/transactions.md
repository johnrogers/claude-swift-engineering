# Transactions

Transaction handling, verification, and restore purchases.

## Transaction Listener (REQUIRED)

Set up at app launch to catch all transaction sources:

```swift
func listenForTransactions() -> Task<Void, Never> {
    Task.detached { [weak self] in
        for await verificationResult in Transaction.updates {
            await self?.handleTransaction(verificationResult)
        }
    }
}
```

**Transaction sources**: In-app purchases, App Store purchases, offer codes, renewals, Family Sharing, Ask to Buy completions, refunds.

## Transaction Verification

Always verify before granting entitlements:

```swift
private func handleTransaction(_ result: VerificationResult<Transaction>) async {
    switch result {
    case .verified(let transaction):
        await grantEntitlement(for: transaction)
        await transaction.finish()

    case .unverified(let transaction, let error):
        print("Unverified: \(error)")
        await transaction.finish()  // Still finish to clear queue
    }
}
```

## Transaction Properties

```swift
// Basic
transaction.id, transaction.originalID, transaction.productID
transaction.productType, transaction.purchaseDate, transaction.appAccountToken

// Subscription
transaction.expirationDate, transaction.isUpgraded
transaction.revocationDate, transaction.revocationReason

// Offer (iOS 18.4+)
transaction.offer?.type, transaction.offer?.id, transaction.offer?.paymentMode
```

## Grant Entitlements

```swift
func grantEntitlement(for transaction: Transaction) async {
    guard transaction.revocationDate == nil else {
        await revokeEntitlement(for: transaction.productID)
        return
    }

    switch transaction.productType {
    case .consumable:     await addConsumable(productID: transaction.productID)
    case .nonConsumable:  await unlockFeature(productID: transaction.productID)
    case .autoRenewable:  await activateSubscription(productID: transaction.productID)
    default: break
    }
}
```

## Finishing Transactions (CRITICAL)

```swift
await transaction.finish()
```

**When to finish**: After granting entitlement, after storing receipt, even for unverified/refunded transactions.

**If you don't finish**: Transaction redelivered on next app launch, queue builds up.

## Current Entitlements

```swift
for await result in Transaction.currentEntitlements {
    guard let transaction = try? result.payloadValue,
          transaction.revocationDate == nil else { continue }
    purchased.insert(transaction.productID)
}

// Check specific product (iOS 18.4+)
for await result in Transaction.currentEntitlements(for: productID) {
    if let transaction = try? result.payloadValue,
       transaction.revocationDate == nil { return true }
}
```

**Note**: `currentEntitlement(for:)` (singular) deprecated in iOS 18.4. Use `currentEntitlements(for:)`.

## Restore Purchases (REQUIRED)

```swift
func restorePurchases() async {
    try? await AppStore.sync()
    await updatePurchasedProducts()
}
```

App Store requires restore functionality for non-consumables and subscriptions.

## Handle Refunds

```swift
if let revocationDate = transaction.revocationDate {
    switch transaction.revocationReason {
    case .developerIssue: // App issue
    case .other:          // Other reason
    @unknown default: break
    }
    await revokeEntitlement(for: transaction.productID)
}
```

## Anti-Patterns

| Pattern | Problem | Solution |
|---------|---------|----------|
| Only handle in `purchase()` | Misses pending, family sharing, restore | Use `Transaction.updates` |
| No restore button | App Store rejection | Provide restore in settings |
| Not finishing | Queue builds up | Always call `finish()` |
