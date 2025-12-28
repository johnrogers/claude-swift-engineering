# Streaming Responses

## Why Stream

Without streaming, users wait 3-5 seconds seeing nothing. With streaming, first content appears in 0.2s.

## PartiallyGenerated Type

@Generable auto-generates a streaming type with optional properties:

```swift
@Generable
struct Itinerary {
    var name: String
    var days: [DayPlan]
}

// Generated automatically:
// Itinerary.PartiallyGenerated {
//     var name: String?
//     var days: [DayPlan]?
// }
```

## Basic Streaming

```swift
let stream = session.streamResponse(
    to: "Generate 3-day itinerary",
    generating: Itinerary.self
)

for try await partial in stream {
    print(partial.name)  // Fills in progressively
    print(partial.days)
}
```

## SwiftUI Integration

```swift
struct ItineraryView: View {
    @State private var itinerary: Itinerary.PartiallyGenerated?

    var body: some View {
        VStack {
            if let name = itinerary?.name {
                Text(name).font(.title)
            }

            if let days = itinerary?.days {
                ForEach(days, id: \.self) { day in
                    DayView(day: day)
                }
            }

            Button("Generate") {
                Task {
                    let stream = session.streamResponse(
                        to: "Generate itinerary",
                        generating: Itinerary.self
                    )
                    for try await partial in stream {
                        self.itinerary = partial
                    }
                }
            }
        }
    }
}
```

## Animations

```swift
if let name = itinerary?.name {
    Text(name)
        .transition(.opacity)
}

if let days = itinerary?.days {
    ForEach(days, id: \.id) { day in  // Use stable ID, not indices
        DayView(day: day)
            .transition(.slide)
    }
}
.animation(.default, value: itinerary)
```

## Property Order for UX

Properties generate in declaration order. Put quick/important ones first:

```swift
@Generable
struct Article {
    var title: String      // Shows in 0.2s
    var summary: String    // Shows in 0.8s
    var fullText: String   // Shows in 2.5s (user already engaged)
}
```

Summaries should be last - they reference earlier content.

## When to Stream

**Stream:** Itineraries, stories, long descriptions, any >1 second generation
**Skip:** Quick classification, content tagging, short responses
