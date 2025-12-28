# StoreKit Views

SwiftUI components for displaying products and subscriptions.

## ProductView (iOS 17+)

```swift
import StoreKit

// By product ID
ProductView(id: "com.app.premium")

// With loaded product
ProductView(for: product)

// Custom icon
ProductView(id: productID) {
    Image(systemName: "star.fill")
}

// Styles
ProductView(id: productID).productViewStyle(.regular)   // Default
ProductView(id: productID).productViewStyle(.compact)   // Smaller
ProductView(id: productID).productViewStyle(.large)     // Prominent
```

## StoreView (iOS 17+)

Display multiple products:

```swift
StoreView(ids: ["com.app.coins_100", "com.app.coins_500"])

// With loaded products
StoreView(products: products)
```

## SubscriptionStoreView (iOS 17+)

```swift
SubscriptionStoreView(groupID: "pro_tier") {
    VStack {
        Image("app-icon")
        Text("Go Pro").font(.largeTitle.bold())
    }
}

// Control styles
.subscriptionStoreControlStyle(.automatic)       // Default
.subscriptionStoreControlStyle(.picker)          // Horizontal
.subscriptionStoreControlStyle(.buttons)         // Stacked
.subscriptionStoreControlStyle(.prominentPicker) // Large (iOS 18.4+)
```

## SubscriptionOfferView (iOS 18.4+)

```swift
SubscriptionOfferView(id: "com.app.pro_monthly")

// With promotional icon
SubscriptionOfferView(id: productID, prefersPromotionalIcon: true)

// Custom icon
SubscriptionOfferView(id: productID) {
    Image("custom-icon").resizable().frame(width: 60, height: 60)
}

// Detail action
SubscriptionOfferView(id: productID)
    .subscriptionOfferViewDetailAction { showStore = true }
```

### Visible Relationship

```swift
SubscriptionOfferView(groupID: "pro_tier", visibleRelationship: .upgrade)
SubscriptionOfferView(groupID: "pro_tier", visibleRelationship: .downgrade)
SubscriptionOfferView(groupID: "pro_tier", visibleRelationship: .crossgrade)
SubscriptionOfferView(groupID: "pro_tier", visibleRelationship: .current)
SubscriptionOfferView(groupID: "pro_tier", visibleRelationship: .all)
```

## Promotional Offers

```swift
SubscriptionStoreView(groupID: groupID)
    .subscriptionPromotionalOffer(
        for: { $0.promotionalOffers.first },
        signature: { subscription, offer in
            try await server.signOffer(productID: subscription.id, offerID: offer.id)
        }
    )
```

## Offer Code Redemption

```swift
// SwiftUI
Button("Redeem") { showRedeemSheet = true }
    .offerCodeRedemption(isPresented: $showRedeemSheet)

// UIKit
AppStore.presentOfferCodeRedeemSheet(in: scene)
```

## Manage Subscriptions

```swift
try? await AppStore.showManageSubscriptions(in: scene)
```

## Custom Purchase UI

```swift
struct CustomProductCard: View {
    let product: Product
    @Environment(\.purchase) private var purchase
    @State private var isPurchasing = false

    var body: some View {
        VStack {
            Text(product.displayName)
            Button {
                Task {
                    isPurchasing = true
                    defer { isPurchasing = false }
                    _ = try? await purchase(product)
                }
            } label: {
                isPurchasing ? AnyView(ProgressView()) : AnyView(Text("Buy \(product.displayPrice)"))
            }
        }
    }
}
```

## Best Practices

1. Use StoreKit Views when possible (pre-built, accessible)
2. Provide marketing content in content closures
3. Handle loading states with placeholders
4. Always provide restore functionality
