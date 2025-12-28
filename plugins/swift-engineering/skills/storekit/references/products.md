# Products

Loading, displaying, and purchasing products with StoreKit 2.

## Loading Products

```swift
import StoreKit

let productIDs = ["com.app.coins_100", "com.app.premium", "com.app.pro_monthly"]
let products = try await Product.products(for: productIDs)
```

### Handle Missing Products

```swift
let loadedIDs = Set(products.map { $0.id })
let missingIDs = Set(productIDs).subtracting(loadedIDs)
if !missingIDs.isEmpty {
    print("Missing products: \(missingIDs)")
}
```

## Product Properties

```swift
product.id            // "com.app.premium"
product.displayName   // "Premium Upgrade"
product.description   // "Unlock all features"
product.displayPrice  // "$4.99"
product.price         // Decimal(4.99)
product.type          // .nonConsumable
```

### Product Types

| Type | Description | Restores? |
|------|-------------|-----------|
| `.consumable` | Coins, hints, boosts | No |
| `.nonConsumable` | Premium features | Yes |
| `.autoRenewable` | Subscriptions | Yes |
| `.nonRenewing` | Seasonal passes | Yes |

## Purchasing

### Purchase with UI Context (iOS 18.2+)

```swift
let result = try await product.purchase(confirmIn: scene)

switch result {
case .success(let verificationResult):
    guard let transaction = try? verificationResult.payloadValue else { return }
    await grantEntitlement(for: transaction)
    await transaction.finish()  // CRITICAL

case .userCancelled:
    print("User cancelled")

case .pending:
    // Ask to Buy - arrives via Transaction.updates
    print("Pending approval")

@unknown default: break
}
```

### SwiftUI Purchase

```swift
struct ProductRow: View {
    let product: Product
    @Environment(\.purchase) private var purchase

    var body: some View {
        Button("Buy \(product.displayPrice)") {
            Task {
                let result = try await purchase(product)
            }
        }
    }
}
```

### Purchase Options

```swift
// With account token (for server association)
let result = try await product.purchase(
    confirmIn: scene,
    options: [.appAccountToken(UUID())]
)

// With promotional offer
let result = try await product.purchase(
    confirmIn: scene,
    options: [.promotionalOffer(offerID: "promo", signature: jwsSignature)]
)
```

## StoreManager Integration

```swift
@MainActor
final class StoreManager: ObservableObject {
    @Published private(set) var products: [Product] = []

    func loadProducts() async {
        products = try? await Product.products(for: productIDs) ?? []
    }

    func purchase(_ product: Product, in scene: UIWindowScene) async throws -> Bool {
        let result = try await product.purchase(confirmIn: scene)
        guard case .success(let verification) = result,
              let transaction = try? verification.payloadValue else { return false }
        await grantEntitlement(for: transaction)
        await transaction.finish()
        return true
    }
}
```

## Anti-Patterns

| Pattern | Problem | Solution |
|---------|---------|----------|
| Scattered `purchase()` calls | Inconsistent handling | Centralize in StoreManager |
| No verification | Security risk | Check `VerificationResult` |
| Missing `finish()` | Transaction redelivery | Always call `finish()` |
