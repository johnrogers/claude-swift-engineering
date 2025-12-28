# SwiftUI 26 New APIs

**iOS 26+, iPadOS 26+, macOS Tahoe+**

## WebView & WebPage

### Basic WebView
```swift
import WebKit

struct ArticleView: View {
    let articleURL: URL

    var body: some View {
        WebView(url: articleURL)
    }
}
```

### WebPage (Observable Model)
```swift
import WebKit

struct BrowserView: View {
    @State private var webPage = WebPage()

    var body: some View {
        VStack {
            Text(webPage.title ?? "Loading...")

            WebView(page: webPage)

            HStack {
                Button("Back") { webPage.goBack() }
                    .disabled(!webPage.canGoBack)

                Button("Forward") { webPage.goForward() }
                    .disabled(!webPage.canGoForward)
            }
        }
    }
}
```

## @Animatable Macro

### Before (Manual animatableData)
```swift
struct HikingRouteShape: Shape {
    var startPoint: CGPoint
    var endPoint: CGPoint
    var elevation: Double

    // Tedious manual declaration
    var animatableData: AnimatablePair<CGPoint.AnimatableData,
                        AnimatablePair<Double, CGPoint.AnimatableData>> {
        get {
            AnimatablePair(startPoint.animatableData,
                          AnimatablePair(elevation, endPoint.animatableData))
        }
        set {
            startPoint.animatableData = newValue.first
            elevation = newValue.second.first
            endPoint.animatableData = newValue.second.second
        }
    }
}
```

### After (@Animatable Macro)
```swift
@Animatable
struct HikingRouteShape: Shape {
    var startPoint: CGPoint
    var endPoint: CGPoint
    var elevation: Double

    @AnimatableIgnored
    var fillColor: Color // Excluded from animation

    // animatableData automatically synthesized!
}
```

**Requirements**:
- Properties must be VectorArithmetic (Double, CGFloat, CGPoint)
- Use `@AnimatableIgnored` for non-animatable properties

## Chart3D

```swift
import Charts

struct ElevationChart: View {
    let hikingData: [HikeDataPoint]

    var body: some View {
        Chart3D {
            ForEach(hikingData) { point in
                LineMark3D(
                    x: .value("Distance", point.distance),
                    y: .value("Elevation", point.elevation),
                    z: .value("Time", point.timestamp)
                )
            }
        }
        .chartXScale(domain: 0...10)
        .chartYScale(domain: 0...3000)
        .chartZScale(domain: startTime...endTime)
    }
}
```

## TextEditor with AttributedString

```swift
struct CommentView: View {
    @State private var comment = AttributedString("Enter your comment")

    var body: some View {
        TextEditor(text: $comment)
        // Built-in formatting controls (bold, italic, etc.)
    }
}
```

**Features**:
- Binding to `AttributedString` preserves formatting
- Automatic toolbar with formatting options
- Customizable paragraph styles and attribute constraints

## New View Modifiers

### sliderThumbVisibility
```swift
Slider(value: $progress)
    .sliderThumbVisibility(.hidden)
// For media players, progress indicators
```

### safeAreaBar
```swift
List { ... }
    .safeAreaBar(edge: .bottom) {
        Text("Bottom Action Bar")
            .padding(.vertical, 15)
    }
    .scrollEdgeEffectStyle(.soft, for: .bottom)
// Sticky bars with progressive blur
```

### In-App URL Opening
```swift
@Environment(\.openURL) var openURL

Button("Open In-App") {
    openURL(website, prefersInApp: true) // SFSafariViewController style
}
// Default Link opens in Safari app
```

### Button Roles
```swift
Button(role: .close) {
    showSheet = false
}
// Renders as X icon with glass effect in toolbars

Button(role: .confirm) {
    confirmAction()
}
// System-styled confirmation button
```

### GlassButtonStyle (iOS 26.1+)
```swift
Button("Clear Glass") { }
    .buttonStyle(GlassButtonStyle(.clear))

Button("Regular Glass") { }
    .buttonStyle(GlassButtonStyle(.glass))

Button("Tinted Glass") { }
    .buttonStyle(GlassButtonStyle(.tint))
    .tint(.blue)
```

### buttonSizing
```swift
Button("Fit") { }
    .buttonSizing(.fit)      // Shrinks to label

Button("Stretch") { }
    .buttonSizing(.stretch)  // Fills available width

Button("Flexible") { }
    .buttonSizing(.flexible) // Balanced
```

## Drag and Drop Enhancements

```swift
struct PhotoGrid: View {
    @State private var selection: Set<Photo.ID> = []
    let photos: [Photo]

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(photos) { photo in
                PhotoCell(photo: photo)
                    .draggable(photo)
            }
        }
        .dragContainer {
            // Return selected items
            selection.compactMap { id in
                photos.first { $0.id == id }
            }
        }
        .dragConfiguration(.init(supportedOperations: [.copy, .delete]))
        .dragPreviewFormation(.stack)
        .onDragSessionUpdated { session in
            if case .ended(.delete) = session.phase {
                deleteSelectedPhotos()
            }
        }
    }
}
```

## visionOS Spatial Layout

### Alignment3D
```swift
HikingRouteView()
    .overlay(alignment: sunAlignment) {
        SunView()
    }

var sunAlignment: Alignment3D {
    Alignment3D(horizontal: .center, vertical: .top, depth: .back)
}
```

### Manipulable Objects
```swift
Model3D(named: "WaterBottle")
    .manipulable() // Users can pick up and move
```

### Scene Snapping
```swift
@Environment(\.sceneSnapping) var sceneSnapping

var body: some View {
    Model3D(named: item.modelName)
        .overlay(alignment: .bottom) {
            if sceneSnapping.isSnapped {
                Pedestal()
            }
        }
}
```

## GlassEffectContainer

```swift
// Optimize multiple glass effects
GlassEffectContainer {
    HStack {
        Button("Action 1") { }.glassEffect()
        Button("Action 2") { }.glassEffect()
        Button("Action 3") { }.glassEffect()
    }
}
// Benefits: Performance optimization, fluid morphing between shapes
```
