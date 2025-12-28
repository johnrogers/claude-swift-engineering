# Locale-Aware Formatting

Proper formatting of dates, numbers, and currencies adapts automatically to the user's locale. Never hardcode format patterns.

## Date Formatting

### DateFormatter (Foundation)

```swift
let formatter = DateFormatter()
formatter.locale = Locale.current  // Always use current locale
formatter.dateStyle = .long
formatter.timeStyle = .short

let dateString = formatter.string(from: Date())

// US: "January 15, 2024 at 3:30 PM"
// France: "15 janvier 2024 a 15:30"
// Japan: "2024/1/15 15:30"
// Germany: "15. Januar 2024 um 15:30"
```

### FormatStyle (iOS 15+)

Modern, type-safe formatting:

```swift
let date = Date()

// Date styles
date.formatted(date: .long, time: .shortened)
// US: "January 15, 2024 at 3:30 PM"

date.formatted(date: .abbreviated, time: .omitted)
// US: "Jan 15, 2024"

// Custom components
date.formatted(.dateTime.month().day().year())
// US: "Jan 15, 2024"

// Relative dates
date.formatted(.relative(presentation: .named))
// "yesterday", "tomorrow", "in 2 days"
```

### Common Mistakes

```swift
// WRONG - US-only format, breaks in other locales
let formatter = DateFormatter()
formatter.dateFormat = "MM/dd/yyyy"

// CORRECT - adapts to locale
formatter.dateStyle = .short

// WRONG - hardcoded separator
let dateStr = "\(month)/\(day)/\(year)"

// CORRECT - use formatter
let dateStr = date.formatted(date: .numeric, time: .omitted)
```

## Number Formatting

### NumberFormatter

```swift
let formatter = NumberFormatter()
formatter.locale = Locale.current
formatter.numberStyle = .decimal

let number = 1234567.89
formatter.string(from: NSNumber(value: number))

// US: "1,234,567.89"
// Germany: "1.234.567,89"
// France: "1 234 567,89"
```

### FormatStyle (iOS 15+)

```swift
let value = 1234567.89

// Decimal
value.formatted(.number)
// US: "1,234,567.89"

// With precision
value.formatted(.number.precision(.fractionLength(0...2)))

// Percentage
0.856.formatted(.percent)
// US: "85.6%"
// Arabic: "86%"
```

## Currency Formatting

### NumberFormatter

```swift
let formatter = NumberFormatter()
formatter.locale = Locale.current
formatter.numberStyle = .currency

let price = 29.99
formatter.string(from: NSNumber(value: price))

// US: "$29.99"
// UK: "GBP29.99" or "PS29.99"
// Japan: "JPY30" (rounded, no decimals)
// France: "29,99 EUR" (comma decimal, space before symbol)
```

### FormatStyle (iOS 15+)

```swift
let price = 29.99

// User's currency
price.formatted(.currency(code: "USD"))
// US: "$29.99"

// Specific currency
price.formatted(.currency(code: "EUR"))
// "$29.99" displayed as "EUR29.99"

// Narrow symbol
price.formatted(.currency(code: "USD").presentation(.narrow))
// "$29.99" instead of "US$29.99"
```

### Decimal vs Currency

```swift
// Currency amounts should use Decimal, not Double
let price = Decimal(string: "29.99")!

let formatter = NumberFormatter()
formatter.numberStyle = .currency
formatter.string(from: price as NSDecimalNumber)
```

## Measurement Formatting

### MeasurementFormatter

```swift
let distance = Measurement(value: 100, unit: UnitLength.meters)

let formatter = MeasurementFormatter()
formatter.locale = Locale.current

formatter.string(from: distance)

// US: "328 ft" (converts to imperial)
// Metric countries: "100 m"
```

### FormatStyle (iOS 15+)

```swift
let distance = Measurement(value: 5, unit: UnitLength.kilometers)

// Natural units for locale
distance.formatted(.measurement(width: .abbreviated))
// US: "3.1 mi"
// Metric: "5 km"

// Force specific unit
distance.formatted(.measurement(width: .abbreviated, usage: .asProvided))
// Always: "5 km"
```

## List Formatting

### ListFormatter

```swift
let items = ["apples", "oranges", "bananas"]

let formatter = ListFormatter()
formatter.locale = Locale.current
formatter.string(from: items)

// English: "apples, oranges, and bananas"
// Spanish: "manzanas, naranjas y platanos"
// Chinese: "apples, oranges and bananas"
```

### FormatStyle (iOS 15+)

```swift
let names = ["Alice", "Bob", "Charlie"]

names.formatted(.list(type: .and))
// "Alice, Bob, and Charlie"

names.formatted(.list(type: .or))
// "Alice, Bob, or Charlie"
```

## Person Name Formatting

```swift
var components = PersonNameComponents()
components.givenName = "John"
components.familyName = "Smith"

let formatter = PersonNameComponentsFormatter()
formatter.style = .default
formatter.string(from: components)

// Western: "John Smith"
// Chinese/Japanese/Korean: "Smith John" (family name first)
```

## Locale-Specific Sorting

```swift
let names = ["Angstrom", "Zebra", "Apple", "aardvark"]

// Locale-aware sort
let sorted = names.sorted { (lhs, rhs) in
    lhs.localizedStandardCompare(rhs) == .orderedAscending
}

// Case-insensitive, locale-aware
let sorted2 = names.sorted {
    $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
}
```

## SwiftUI Integration

### Text with Formatting

```swift
struct PriceView: View {
    let price: Decimal

    var body: some View {
        Text(price, format: .currency(code: "USD"))
    }
}

struct DateView: View {
    let date: Date

    var body: some View {
        Text(date, format: .dateTime.month().day().year())
    }
}

struct CountView: View {
    let count: Int

    var body: some View {
        Text(count, format: .number)
    }
}
```

### Environment Locale

```swift
struct FormattedView: View {
    @Environment(\.locale) var locale

    var body: some View {
        // Format using environment locale
        Text(Date(), format: .dateTime.locale(locale))
    }
}

// Preview with specific locale
struct FormattedView_Previews: PreviewProvider {
    static var previews: some View {
        FormattedView()
            .environment(\.locale, Locale(identifier: "fr_FR"))
    }
}
```

## Best Practices

1. **Never hardcode format strings** - Use style-based formatting
2. **Always use Locale.current** - Unless explicitly overriding
3. **Use Decimal for money** - Avoids floating-point errors
4. **Test multiple locales** - US, Germany, Japan, Arabic cover most edge cases
5. **Prefer FormatStyle** - Modern, type-safe, SwiftUI-friendly

## Testing Locales

```swift
// Unit test with specific locale
func testGermanCurrency() {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "de_DE")
    formatter.numberStyle = .currency

    let result = formatter.string(from: 1234.56)
    XCTAssertEqual(result, "1.234,56 EUR")
}
```

**Scheme testing**:
1. Edit Scheme > Run > Options
2. Application Region > Choose region
3. Run and verify formatting
