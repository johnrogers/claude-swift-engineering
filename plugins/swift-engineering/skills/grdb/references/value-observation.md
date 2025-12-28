# ValueObservation - Reactive Queries

ValueObservation automatically re-executes queries when database changes occur.

## Basic Observation

```swift
import GRDB
import Combine

let observation = ValueObservation.tracking { db in
    try Track.fetchAll(db)
}

let cancellable = observation.publisher(in: dbQueue)
    .sink(
        receiveCompletion: { _ in },
        receiveValue: { tracks in
            print("Tracks updated: \(tracks.count)")
        }
    )
```

## Filtered Observation

```swift
func observeGenre(_ genre: String) -> ValueObservation<[Track]> {
    ValueObservation.tracking { db in
        try Track.filter(Column("genre") == genre).fetchAll(db)
    }
}
```

## SwiftUI Integration (GRDBQuery)

```swift
import GRDBQuery

struct TracksRequest: Queryable {
    static var defaultValue: [Track] { [] }

    func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[Track], Error> {
        ValueObservation
            .tracking { db in try Track.fetchAll(db) }
            .publisher(in: dbQueue)
            .eraseToAnyPublisher()
    }
}

struct TrackListView: View {
    @Query(TracksRequest())
    var tracks: [Track]

    var body: some View {
        List(tracks) { track in Text(track.title) }
    }
}
```

## Manual Observation (Non-Combine)

```swift
let observer = observation.start(
    in: dbQueue,
    onError: { error in print("Error: \(error)") },
    onChange: { tracks in print("Changed: \(tracks.count)") }
)

observer.cancel()  // When done
```

## Performance Optimization

### Problem: Re-evaluates on ANY write

```swift
ValueObservation.tracking { db in
    try Track.fetchAll(db)  // CPU spike on unrelated changes
}
```

### Solution 1: Remove Duplicates

```swift
observation.removeDuplicates().publisher(in: dbQueue)
```

### Solution 2: Debounce

```swift
observation.removeDuplicates()
    .publisher(in: dbQueue)
    .debounce(for: 0.5, scheduler: DispatchQueue.main)
```

### Solution 3: Region Tracking

```swift
ValueObservation.tracking(region: Track.all()) { db in
    try Track.fetchAll(db)  // Only Track changes trigger
}
```

## Decision Framework

| Dataset Size | Optimization |
|-------------|--------------|
| Small (<1k) | Plain `.tracking` |
| Medium (1-10k) | `.removeDuplicates()` + `.debounce()` |
| Large (10k+) | Region tracking |

## Async/Await

```swift
for try await tracks in ValueObservation
    .tracking { db in try Track.fetchAll(db) }
    .values(in: dbQueue) {
    print("Updated: \(tracks.count)")
}
```
