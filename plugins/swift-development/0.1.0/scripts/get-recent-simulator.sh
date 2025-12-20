#!/bin/bash
# Get the most recently used iOS Simulator
# Returns the UDID of the simulator to use for builds

set -e

# Option 1: Get currently booted simulator
BOOTED=$(xcrun simctl list devices booted --json 2>/dev/null | jq -r '[.devices | to_entries | .[].value | .[]] | map(select(.state == "Booted")) | .[0].udid // empty' 2>/dev/null || echo "")

if [ -n "$BOOTED" ]; then
    echo "$BOOTED"
    exit 0
fi

# Option 2: Get Xcode's last used simulator
LAST_USED=$(defaults read com.apple.iphonesimulator CurrentDeviceUDID 2>/dev/null || echo "")

if [ -n "$LAST_USED" ]; then
    if xcrun simctl list devices --json | jq -e ".devices[][] | select(.udid == \"$LAST_USED\")" > /dev/null 2>&1; then
        echo "$LAST_USED"
        exit 0
    fi
fi

# Option 3: Fallback to latest available iPhone simulator
FALLBACK=$(xcrun simctl list devices available --json 2>/dev/null | jq -r '[.devices | to_entries | .[] | select(.key | contains("iOS")) | .value | .[]] | map(select(.name | contains("iPhone"))) | .[-1].udid // empty' 2>/dev/null || echo "")

if [ -n "$FALLBACK" ]; then
    echo "$FALLBACK"
    exit 0
fi

# Last resort: any available simulator
ANY=$(xcrun simctl list devices available --json 2>/dev/null | jq -r '[.devices | to_entries | .[].value | .[]] | .[0].udid // empty' 2>/dev/null || echo "")

if [ -n "$ANY" ]; then
    echo "$ANY"
    exit 0
fi

echo "ERROR: No simulator found" >&2
exit 1
