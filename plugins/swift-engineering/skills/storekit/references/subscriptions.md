# Subscriptions

Auto-renewable subscription management with StoreKit 2.

## Subscription Properties

```swift
if let info = product.subscription {
    let groupID = info.subscriptionGroupID
    let period = info.subscriptionPeriod  // .day, .week, .month, .year
}
```

## Subscription Status

```swift
let statuses = try await Product.SubscriptionInfo.status(for: groupID)

for status in statuses {
    switch status.state {
    case .subscribed:        // Active - full access
    case .expired:           // Show resubscribe/win-back
    case .inGracePeriod:     // Billing issue, access maintained
    case .inBillingRetryPeriod:  // Apple retrying payment
    case .revoked:           // Family Sharing removed
    @unknown default: break
    }
}
```

### Listen for Status Updates

```swift
for await statuses in Product.SubscriptionInfo.Status.updates(for: groupID) {
    for status in statuses { updateUI(for: status.state) }
}
```

## Renewal Info

```swift
switch status.renewalInfo {
case .verified(let renewalInfo):
    renewalInfo.willAutoRenew       // Will subscription renew?
    renewalInfo.autoRenewPreference // Product ID for next renewal
    renewalInfo.expirationReason    // Why expired?
case .unverified: break
}
```

### Expiration Reasons

| Reason | Action |
|--------|--------|
| `.autoRenewDisabled` | User turned off renewal |
| `.billingError` | Payment issue |
| `.didNotConsentToPriceIncrease` | Show win-back offer |
| `.productUnavailable` | Product discontinued |

### Grace Period

```swift
if let expiration = renewalInfo.gracePeriodExpirationDate {
    // Show update payment method UI
}
```

## Offers

### Introductory Offer

```swift
if let intro = product.subscription?.introductoryOffer {
    intro.period       // Duration
    intro.displayPrice // Price
    intro.paymentMode  // .freeTrial, .payAsYouGo, .payUpFront
}
```

### Promotional Offers

```swift
for offer in product.subscription?.promotionalOffers ?? [] {
    offer.id, offer.displayPrice, offer.period
}

// Apply with server-signed JWS
let result = try await product.purchase(
    confirmIn: scene,
    options: [.promotionalOffer(offerID: offer.id, signature: jwsSignature)]
)
```

## Subscription Groups

Users have one active subscription per group. Use for tier levels (Basic/Pro/Premium) or billing periods (Monthly/Annual).

```swift
let activeStatus = statuses.filter { $0.state == .subscribed }.first
```

## Family Sharing

Family Sharing transactions have `appAccountToken == nil`. Each family member has unique `appTransactionID`.

Enable: **App Store Connect > Subscriptions > Enable Family Sharing**

## Tracking Status

```swift
extension StoreManager {
    var isSubscribed: Bool {
        get async {
            let state = try? await Product.SubscriptionInfo.status(for: "pro_tier").first?.state
            return state == .subscribed || state == .inGracePeriod || state == .inBillingRetryPeriod
        }
    }
}
```

## Win-Back Offers

```swift
if renewalInfo.expirationReason == .didNotConsentToPriceIncrease {
    showWinBackOffer()
}
```
