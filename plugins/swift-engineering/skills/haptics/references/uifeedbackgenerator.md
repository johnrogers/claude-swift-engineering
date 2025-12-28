# UIFeedbackGenerator

Simple haptic feedback API for most common use cases. Available iOS 10+.

## Three Generator Types

### UIImpactFeedbackGenerator

Physical collision or impact sensation.

**Styles**: `.light`, `.medium` (most common), `.heavy`, `.rigid`, `.soft`

```swift
class MyViewController: UIViewController {
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        impactGenerator.prepare() // Reduces latency
    }

    @objc func buttonTapped() {
        impactGenerator.impactOccurred()
    }
}

// Intensity variation (iOS 13+): 0.0 to 1.0
impactGenerator.impactOccurred(intensity: 0.5)
```

### UISelectionFeedbackGenerator

Discrete selection changes. Feels like clicking a physical wheel.

```swift
private let selectionGenerator = UISelectionFeedbackGenerator()

func pickerView(_ picker: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    selectionGenerator.selectionChanged()
}
```

**Use cases**: Picker wheels, segmented controls, page indicators

### UINotificationFeedbackGenerator

System-level success/warning/error feedback.

```swift
let notificationGenerator = UINotificationFeedbackGenerator()

func submitForm() {
    if isValid {
        notificationGenerator.notificationOccurred(.success)
    } else {
        notificationGenerator.notificationOccurred(.error)
    }
}
```

**Types**: `.success`, `.warning`, `.error`

## Performance: prepare()

Call `prepare()` before the haptic to reduce latency (~1 second window).

```swift
// Good: Prepare on touch down, fire on touch up
@IBAction func buttonTouchDown(_ sender: UIButton) {
    impactGenerator.prepare()
}

@IBAction func buttonTouchUpInside(_ sender: UIButton) {
    impactGenerator.impactOccurred() // Immediate
}
```

## Common Patterns

### HapticButton

```swift
class HapticButton: UIButton {
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        impactGenerator.prepare()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        impactGenerator.impactOccurred()
    }
}
```

### Slider Scrubbing

```swift
class HapticSlider: UISlider {
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private var lastValue: Float = 0

    @objc func valueChanged() {
        if abs(value - lastValue) >= 0.1 {
            selectionGenerator.selectionChanged()
            lastValue = value
        }
    }
}
```

### Pull-to-Refresh

```swift
func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y <= -100 && !isRefreshing {
        impactGenerator.impactOccurred()
        isRefreshing = true
        beginRefresh()
    }
}
```

### Success/Error Feedback

```swift
func handleServerResponse(_ result: Result<Data, Error>) {
    let generator = UINotificationFeedbackGenerator()
    switch result {
    case .success: generator.notificationOccurred(.success)
    case .failure: generator.notificationOccurred(.error)
    }
}
```
