# Getting Started

Testing-first workflow for StoreKit 2 implementation.

## Why .storekit-First

Create StoreKit configuration BEFORE writing any purchase code:

- **Immediate validation**: Product ID typos caught in Xcode, not at runtime
- **Faster iteration**: Test purchases in simulator without network requests
- **Team benefits**: Anyone can test purchase flows locally
- **Documentation**: Product catalog visible in project

## Create Configuration File

1. **Xcode > File > New > File > StoreKit Configuration File**
2. Save as `Products.storekit`
3. Add to target for testing

### Add Products

Click "+" and configure each product:

**Consumable:**
```
Product ID: com.yourapp.coins_100
Reference Name: 100 Coins
Price: $0.99
```

**Non-Consumable:**
```
Product ID: com.yourapp.premium
Reference Name: Premium Upgrade
Price: $4.99
```

**Auto-Renewable Subscription:**
```
Product ID: com.yourapp.pro_monthly
Reference Name: Pro Monthly
Price: $9.99/month
Subscription Group ID: pro_tier
```

## Enable in Scheme

1. **Scheme > Edit Scheme > Run > Options**
2. **StoreKit Configuration**: Select `Products.storekit`
3. Run app in simulator to test

## Product Types

| Type | Description | Restores? |
|------|-------------|-----------|
| Consumable | Coins, hints, boosts | No |
| Non-Consumable | Premium features, level packs | Yes |
| Auto-Renewable | Monthly/annual subscriptions | Yes |
| Non-Renewing | Seasonal passes | Yes |

## Testing Scenarios

Test these in StoreKit configuration before production code:

- [ ] Successful purchase for each product type
- [ ] Cancelled purchase (state remains consistent)
- [ ] Subscription renewal (accelerated time)
- [ ] Subscription expiration
- [ ] Upgrade/downgrade between tiers
- [ ] Restore purchases flow
- [ ] Family Sharing (enable in config)

## Already Wrote Code First?

If you wrote purchase code before creating `.storekit` config:

**Option A: Start Over (Recommended)**
Delete IAP code and follow testing-first workflow. Reinforces correct habits.

**Option B: Create Config Now (Acceptable)**
Create `.storekit` with existing product IDs, test locally, document in PR.

**Option C: Skip Config (Not Recommended)**
Misses local testing benefits, harder for teammates.

## Sandbox Testing

After local testing passes:

1. **App Store Connect > Users and Access > Sandbox Testers**
2. Create test Apple ID
3. Sign in on device: **Settings > App Store > Sandbox Account**
4. Test purchases on physical device

Clear purchase history: **Settings > App Store > Sandbox Account > Clear Purchase History**

## Checklist Before Production

### Testing Foundation
- [ ] Created `.storekit` configuration with all products
- [ ] Verified each product renders in StoreKit preview
- [ ] Tested successful purchase for each product
- [ ] Tested purchase failure scenarios
- [ ] Tested restore purchases flow
- [ ] For subscriptions: tested renewal, expiration, upgrade/downgrade

### Architecture
- [ ] Centralized StoreManager class exists
- [ ] StoreManager is `@MainActor` and `ObservableObject`
- [ ] Transaction listener via `Transaction.updates`
- [ ] All transactions call `.finish()` after entitlement granted
