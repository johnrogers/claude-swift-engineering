# Build Issues Diagnostics

Systematic debugging for SPM resolution, "No such module", and dependency conflicts. 80% of persistent build failures are dependency resolution issues, not code bugs.

## Diagnostic Decision Table

| Error | Likely Cause | First Check |
|-------|--------------|-------------|
| "No such module" after adding package | SPM cache stale | Clear package caches |
| "Multiple commands produce" | Duplicate file in targets | Check target membership |
| Build works locally, fails on CI | Environment/cache difference | Compare Podfile.lock |
| SPM resolution hangs | Package cache corruption | Delete .build and DerivedData |
| Framework version conflicts | Transitive dependency issue | Check Package.resolved |

## Mandatory First Checks

```bash
# 1. Check Derived Data size (>10GB = stale)
du -sh ~/Library/Developer/Xcode/DerivedData

# 2. Check for zombie xcodebuild processes
ps aux | grep xcodebuild | grep -v grep

# 3. List available schemes
xcodebuild -list
```

## Decision Tree

```
Build failing?
|-- "No such module XYZ"?
|   |-- After adding SPM package? -> Clean + reset package caches
|   |-- After pod install? -> Check Podfile.lock conflicts
|   |-- Framework not found? -> Check FRAMEWORK_SEARCH_PATHS
|
|-- "Multiple commands produce"?
|   |-- Duplicate files in target membership -> Check File Inspector
|
|-- SPM resolution hangs?
|   |-- Clear package caches + Derived Data
|
|-- Version conflicts?
    |-- Use dependency resolution strategies below
```

## Quick Fixes

### SPM Package Not Found

```bash
# Nuclear clean
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/Caches/org.swift.swiftpm

# Reset packages in project
xcodebuild -resolvePackageDependencies

# Clean build
xcodebuild clean build -scheme YourScheme
```

### CocoaPods Conflicts

```bash
# Check what versions were installed
cat Podfile.lock | grep -A 2 "PODS:"

# Clean reinstall
rm -rf Pods/
rm Podfile.lock
pod install

# Always open workspace (not project)
open YourApp.xcworkspace
```

### Multiple Commands Produce Error

1. Open Xcode
2. Select file in navigator
3. File Inspector > Target Membership
4. Uncheck duplicate targets
5. Or: Build Phases > Copy Bundle Resources > remove duplicates

### Framework Search Paths

```bash
# Show all build settings
xcodebuild -showBuildSettings -scheme YourScheme | grep FRAMEWORK_SEARCH_PATHS
```

Fix in Xcode:
1. Target > Build Settings
2. Search "Framework Search Paths"
3. Add: `$(PROJECT_DIR)/Frameworks` (recursive)

## Dependency Resolution Strategies

### Strategy 1: Lock to Specific Versions

```ruby
# Podfile - exact versions
pod 'Alamofire', '5.8.0'
pod 'SwiftyJSON', '~> 5.0.0'  # Any 5.0.x
```

```swift
// Package.swift - exact versions
.package(url: "...", exact: "1.2.3")
```

### Strategy 2: Use Version Ranges

```swift
// Package.swift
.package(url: "...", from: "1.2.0")              // 1.2.0 and higher
.package(url: "...", .upToNextMajor(from: "1.0.0"))  // 1.x.x but not 2.0
```

### Strategy 3: Reset SPM Resolution

```bash
# Clear package caches
rm -rf .build
rm Package.resolved

# Re-resolve
swift package resolve
```

## Debug vs Release Differences

```bash
# Compare configurations
xcodebuild -showBuildSettings -configuration Debug > debug.txt
xcodebuild -showBuildSettings -configuration Release > release.txt
diff debug.txt release.txt
```

Common culprits:
- SWIFT_OPTIMIZATION_LEVEL (-Onone vs -O)
- ENABLE_TESTABILITY (YES in Debug, NO in Release)
- DEBUG preprocessor flag

## Command Reference

```bash
# CocoaPods
pod install                    # Install dependencies
pod update                     # Update to latest versions
pod outdated                   # Check for updates
pod deintegrate                # Remove CocoaPods from project

# Swift Package Manager
swift package resolve          # Resolve dependencies
swift package update           # Update dependencies
swift package show-dependencies # Show dependency tree
xcodebuild -resolvePackageDependencies  # Xcode's SPM resolve

# Xcode Build
xcodebuild clean               # Clean build folder
xcodebuild -list               # List schemes and targets
xcodebuild -showBuildSettings  # Show all build settings
```

## Common Mistakes

### Not Committing Lockfiles
```bash
# BAD: .gitignore includes lockfiles
Podfile.lock
Package.resolved

# These should be committed for reproducible builds
```

### Using "Latest" Version
```ruby
# BAD: No version specified
pod 'Alamofire'  # Breaking changes when updated

# GOOD: Explicit version
pod 'Alamofire', '~> 5.8'
```

### Opening Project Instead of Workspace
```bash
# BAD (with CocoaPods)
open YourApp.xcodeproj

# GOOD
open YourApp.xcworkspace
```

## Verification Checklist

After applying fix:
- [ ] Build succeeds with clean Derived Data
- [ ] All dependencies resolve to expected versions
- [ ] Both Debug and Release configurations build
- [ ] CI builds match local builds
- [ ] Lockfiles committed to source control
