# Gesture Composition

## Decision Tree

```
What interaction do you need?
- Single tap/click? -> Button (preferred) or TapGesture
- Drag/pan? -> DragGesture
- Hold before action? -> LongPressGesture
- Pinch to zoom? -> MagnificationGesture
- Two-finger rotate? -> RotationGesture

Multiple gestures together?
- Both at same time? -> .simultaneously
- One after another? -> .sequenced
- One OR the other? -> .exclusively
```

## GestureState vs State

| Use Case | Type | Why |
|----------|------|-----|
| Temporary feedback | `@GestureState` | Auto-resets when gesture ends |
| Final committed value | `@State` | Persists after gesture |

## Pattern 1: Draggable View

```swift
struct DraggableCard: View {
    @GestureState private var dragOffset = CGSize.zero  // Temporary
    @State private var position = CGSize.zero           // Permanent

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .offset(x: position.width + dragOffset.width,
                    y: position.height + dragOffset.height)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        withAnimation(.spring()) {
                            position.width += value.translation.width
                            position.height += value.translation.height
                        }
                    }
            )
    }
}
```

## Pattern 2: Simultaneous Gestures

```swift
// Drag AND pinch-zoom at the same time
.gesture(
    DragGesture()
        .updating($dragOffset) { value, state, _ in state = value.translation }
        .simultaneously(with:
            MagnificationGesture()
                .updating($scale) { value, state, _ in state = value.magnification }
        )
)
```

## Pattern 3: Sequenced Gestures

```swift
// Long press THEN drag (like iOS Home Screen reordering)
LongPressGesture(minimumDuration: 0.5)
    .onEnded { _ in isEditing = true }
    .sequenced(before:
        DragGesture()
            .updating($dragOffset) { value, state, _ in state = value.translation }
    )
```

## Pattern 4: Exclusive Gestures

```swift
// Double-tap OR single-tap (not both)
TapGesture(count: 2)
    .onEnded { zoom() }
    .exclusively(before:
        TapGesture(count: 1)
            .onEnded { select() }
    )
```

## Common Pitfalls

**Using @State instead of @GestureState:**
```swift
// WRONG - offset stays at last value
@State private var offset = CGSize.zero

// CORRECT - auto-resets when gesture ends
@GestureState private var offset = CGSize.zero
```

**Gesture blocks ScrollView:**
```swift
// WRONG - blocks scrolling
.gesture(DragGesture())

// CORRECT - allows both
.simultaneousGesture(DragGesture())
```

**Using TapGesture instead of Button:**
```swift
// WRONG - no accessibility
Text("Submit").onTapGesture { }

// CORRECT - proper semantics
Button("Submit") { }
```

## Accessibility

```swift
Image("slider")
    .gesture(DragGesture().onChanged { ... })
    .accessibilityAdjustableAction { direction in
        switch direction {
        case .increment: volume += 5
        case .decrement: volume -= 5
        @unknown default: break
        }
    }
```
