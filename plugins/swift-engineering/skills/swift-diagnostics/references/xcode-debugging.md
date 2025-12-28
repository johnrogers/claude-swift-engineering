# Xcode Debugging Reference

LLDB commands, breakpoints, and view debugging techniques for iOS/macOS development.

## LLDB Quick Reference

### Basic Commands

```lldb
# Print variable
po myVariable
p myVariable

# Print with format
p/x myInt          # Hexadecimal
p/t myInt          # Binary
p/d myInt          # Decimal

# Print object description
po self
po myArray

# Expression evaluation
expr myVariable = 5
expr self.isLoading = true
```

### Inspecting Objects

```lldb
# Print all properties
po self.debugDescription

# Print specific property
po self.viewModel.state

# Print array contents
po myArray.map { $0.name }

# Print dictionary
po myDict.keys
po myDict["key"]
```

### SwiftUI Debugging

```lldb
# Print view hierarchy (from any breakpoint in a View)
po Self._printChanges()

# Check @State value
po _myStateVariable.wrappedValue

# Check @Binding
po _myBinding.wrappedValue
```

### Memory Inspection

```lldb
# Check memory address
p unsafeBitCast(myObject, to: Int.self)

# Check reference count
po CFGetRetainCount(myObject as CFTypeRef)

# Print type
po type(of: myObject)
```

## Breakpoint Techniques

### Conditional Breakpoints

1. Set breakpoint (click line number gutter)
2. Right-click breakpoint > Edit Breakpoint
3. Add condition:
   - `myVariable == 5`
   - `myArray.count > 10`
   - `self.state == .loading`

### Action Breakpoints

Execute code without stopping:

1. Edit Breakpoint
2. Add Action > Debugger Command
3. Enter: `po "Value is: \(myVariable)"`
4. Check "Automatically continue"

### Exception Breakpoints

Catch crashes before they happen:

1. Debug Navigator > + button
2. Add Exception Breakpoint
3. Choose: All Exceptions or Objective-C only

### Symbolic Breakpoints

Break on any method call:

1. Debug Navigator > + button
2. Add Symbolic Breakpoint
3. Symbol: `-[UIViewController viewDidLoad]`
4. Or: `UIApplication.shared`

## View Debugging

### Debug View Hierarchy

1. Run app
2. Debug > View Debugging > Capture View Hierarchy
3. Or click cube icon in debug toolbar

### What to Look For

- **Overlapping views** - Views stacked unexpectedly
- **Constraint issues** - Ambiguous layout warnings
- **Hidden views** - Views with alpha 0 or isHidden true
- **Off-screen content** - Views positioned outside bounds

### Runtime Attribute Inspection

In the view debugger:
1. Select view in 3D hierarchy
2. Object Inspector shows all properties
3. Check frame, bounds, constraints

### View Debugging Commands

```lldb
# Print view hierarchy
po self.view.recursiveDescription()

# Print responder chain
po self.responderChain()

# Highlight view (in simulator)
expr self.view.layer.borderWidth = 2
expr self.view.layer.borderColor = UIColor.red.cgColor
```

## Network Debugging

### Print Network Requests

```swift
// Add to URLSession configuration
#if DEBUG
URLSession.shared.configuration.protocolClasses?.insert(NetworkLogger.self, at: 0)
#endif
```

### LLDB Network Inspection

```lldb
# Print URL request
po request.url
po request.httpMethod
po String(data: request.httpBody ?? Data(), encoding: .utf8)

# Print response
po response.statusCode
po String(data: responseData, encoding: .utf8)
```

## Thread Debugging

### Check Current Thread

```lldb
# Print current thread
thread info

# Print all threads
thread list

# Print backtrace
bt
bt all
```

### Main Thread Checker

Enable in scheme:
1. Edit Scheme > Run > Diagnostics
2. Check "Main Thread Checker"

Catches UI updates from background threads.

## Performance Debugging

### Time Profiler in LLDB

```lldb
# Measure execution time
expr let start = CFAbsoluteTimeGetCurrent()
# ... execute code ...
expr print("Time: \(CFAbsoluteTimeGetCurrent() - start)")
```

### Memory Debugging

Enable in scheme:
1. Edit Scheme > Run > Diagnostics
2. Check "Malloc Stack Logging"
3. Check "Zombie Objects" (for EXC_BAD_ACCESS)

## Common Debugging Scenarios

### Scenario: View Not Appearing

```lldb
# Check if view is in hierarchy
po self.view.superview

# Check frame
po self.view.frame

# Check if hidden
po self.view.isHidden
po self.view.alpha

# Check constraints
po self.view.constraints
```

### Scenario: Button Not Responding

```lldb
# Check if user interaction enabled
po button.isUserInteractionEnabled

# Check if enabled
po button.isEnabled

# Check gesture recognizers
po button.gestureRecognizers

# Check if obscured
po self.view.hitTest(touchPoint, with: nil)
```

### Scenario: Data Not Loading

```lldb
# Check network reachability
po NetworkMonitor.shared.isConnected

# Check API response
po lastResponse?.statusCode
po String(data: lastResponseData, encoding: .utf8)

# Check decoding
expr try JSONDecoder().decode(MyModel.self, from: data)
```

## Useful Xcode Shortcuts

| Action | Shortcut |
|--------|----------|
| Toggle breakpoint | Cmd + \ |
| Step over | F6 |
| Step into | F7 |
| Step out | F8 |
| Continue | Cmd + Ctrl + Y |
| View debugger | Cmd + Shift + D |
| Memory graph | Cmd + Shift + M |
| Debug navigator | Cmd + 7 |

## Debug Console Tips

```lldb
# Clear console
Cmd + K

# Search console output
Cmd + F

# Copy console selection
Cmd + C

# Increase console font
Cmd + + (plus)
```

## Verification Checklist

After debugging session:
- [ ] Remove debug print statements
- [ ] Disable unnecessary breakpoints
- [ ] Turn off diagnostic options in scheme (for production)
- [ ] Remove any `expr` modifications made during debugging
