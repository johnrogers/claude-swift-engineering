# Build Performance Diagnostics

Systematic debugging for slow builds, Derived Data issues, and Xcode hangs. 80% of "mysterious" build issues are environment problems, not code bugs.

## Diagnostic Decision Table

| Symptom | Likely Cause | First Check |
|---------|--------------|-------------|
| Build takes 10+ minutes | Stale Derived Data | Check DerivedData size |
| "Build succeeded" but old code runs | Cached build artifact | Delete Derived Data |
| Xcode beach balls during build | Zombie xcodebuild processes | Check process list |
| Simulator stuck at splash | Simulator in bad state | simctl list devices |
| Intermittent build failures | Environment corruption | Full clean rebuild |

## Mandatory First Checks

```bash
# 1. Check for zombie processes
ps aux | grep -E "xcodebuild|Simulator" | grep -v grep

# 2. Check Derived Data size (>10GB = stale)
du -sh ~/Library/Developer/Xcode/DerivedData

# 3. Check simulator states
xcrun simctl list devices | grep -E "Booted|Booting|Shutting Down"
```

What these tell you:
- **0 processes + small DerivedData + no stuck sims** -> Environment clean
- **10+ processes OR >10GB DerivedData OR simulators stuck** -> Clean first

## Decision Tree

```
Build/performance problem?
|-- BUILD FAILED with no details?
|   |-- Clean Derived Data -> rebuild
|
|-- Build succeeds but old code executes?
|   |-- Delete Derived Data -> rebuild (2-5 min fix)
|
|-- Build intermittent (sometimes succeeds/fails)?
|   |-- Clean Derived Data -> rebuild
|
|-- Xcode hangs during build?
|   |-- Check for zombie xcodebuild processes
|   |-- killall -9 xcodebuild
|
|-- "Unable to boot simulator"?
|   |-- xcrun simctl shutdown all
|   |-- xcrun simctl erase <device-uuid>
|
|-- Tests hang indefinitely?
    |-- Check simctl list -> reboot simulator
```

## Quick Fixes

### Clean Derived Data

```bash
# Delete all Derived Data
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Also clean project-specific build folders
rm -rf .build/ build/

# Clean and rebuild
xcodebuild clean -scheme YourScheme
xcodebuild build -scheme YourScheme \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

### Kill Zombie Processes

```bash
# Kill all xcodebuild processes
killall -9 xcodebuild

# Verify they're gone
ps aux | grep xcodebuild | grep -v grep

# Kill Simulator if stuck
killall -9 Simulator
```

### Fix Simulator Issues

```bash
# Shutdown all simulators
xcrun simctl shutdown all

# If simctl fails, force quit first
killall -9 Simulator
xcrun simctl shutdown all

# List simulators to find problematic one
xcrun simctl list devices

# Erase specific simulator
xcrun simctl erase <device-uuid>

# Boot fresh simulator
xcrun simctl boot "iPhone 16 Pro"
```

### Reset SPM Caches

```bash
# Clear SPM caches
rm -rf ~/Library/Caches/org.swift.swiftpm

# Reset package dependencies
xcodebuild -resolvePackageDependencies

# Full clean rebuild
rm -rf ~/Library/Developer/Xcode/DerivedData/*
xcodebuild clean build -scheme YourScheme
```

## Identifying Build Time Hotspots

```bash
# Enable build timing
defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool YES

# Restart Xcode, build, check activity log
# Xcode > Report Navigator > Build log
```

## Xcode Build Commands

```bash
# List available schemes
xcodebuild -list

# Show build settings
xcodebuild -showBuildSettings -scheme YourScheme

# Verbose build (more diagnostics)
xcodebuild -verbose build -scheme YourScheme

# Build for testing only (faster iteration)
xcodebuild build-for-testing -scheme YourScheme

# Run tests without rebuilding
xcodebuild test-without-building -scheme YourScheme \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Run specific test only
xcodebuild test -scheme YourScheme \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:YourTests/SpecificTestClass
```

## Crash Log Analysis

```bash
# Find recent crashes
ls -lt ~/Library/Logs/DiagnosticReports/*.crash | head -5

# View crash log
cat ~/Library/Logs/DiagnosticReports/YourApp-*.crash | head -100

# Symbolicate address (if you have .dSYM)
atos -o YourApp.app.dSYM/Contents/Resources/DWARF/YourApp \
  -arch arm64 0x<address>
```

## Environment Reset (Nuclear Option)

When nothing else works:

```bash
# 1. Quit Xcode
osascript -e 'quit app "Xcode"'

# 2. Kill all related processes
killall -9 xcodebuild Simulator

# 3. Clean all caches
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf .build/ build/

# 4. Reset simulators
xcrun simctl shutdown all
xcrun simctl erase all

# 5. Reopen Xcode
open -a Xcode YourProject.xcodeproj
```

## Common Error Patterns

| Error | Fix |
|-------|-----|
| BUILD FAILED (no details) | Delete Derived Data |
| Unable to boot simulator | `xcrun simctl erase <uuid>` |
| No such module | Clean + delete Derived Data |
| Tests hang | Check simctl list, reboot simulator |
| Stale code executing | Delete Derived Data |

## Common Mistakes

- **Debugging code before checking environment** - Always run mandatory steps first
- **Ignoring simulator states** - "Booting" can hang 10+ minutes
- **Assuming git changes caused problem** - Derived Data caches old builds
- **Running full test suite when one test fails** - Use `-only-testing`

## Verification Checklist

After applying fix:
- [ ] No zombie xcodebuild processes
- [ ] Derived Data under 5GB
- [ ] Simulators all in Shutdown state
- [ ] Clean build succeeds
- [ ] Correct code executes (not cached)
- [ ] Tests pass consistently
