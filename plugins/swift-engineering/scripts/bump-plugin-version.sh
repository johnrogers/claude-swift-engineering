#!/bin/bash
# .claude/hooks/bump-plugin-version.sh

# Find the plugin.json file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_FILE="$SCRIPT_DIR/../.claude-plugin/plugin.json"

# Fallback to environment variable if relative path doesn't work
if [ ! -f "$PLUGIN_FILE" ]; then
  PLUGIN_FILE="$CLAUDE_PROJECT_DIR/plugins/swift-engineering/.claude-plugin/plugin.json"
fi

BUMP_TYPE=${1:-patch}  # patch, minor, major

# Get current version
CURRENT_VERSION=$(jq -r '.version' "$PLUGIN_FILE")

# Parse version
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Bump based on type
case "$BUMP_TYPE" in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

# Update the file
jq --arg version "$NEW_VERSION" '.version = $version' "$PLUGIN_FILE" > "$PLUGIN_FILE.tmp"
mv "$PLUGIN_FILE.tmp" "$PLUGIN_FILE"

# Update plugin README with new version
PLUGIN_README="$SCRIPT_DIR/../README.md"

if [ -f "$PLUGIN_README" ]; then
  sed -i.bak -E "s/\*\*Version:\*\* [0-9]+\.[0-9]+\.[0-9]+/**Version:** ${NEW_VERSION}/g" "$PLUGIN_README"
  rm -f "$PLUGIN_README.bak"
  echo "Updated plugin README to version $NEW_VERSION"
fi

echo "Bumped version from $CURRENT_VERSION to $NEW_VERSION"
exit 0