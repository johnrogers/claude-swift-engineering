# Swift Package Documentation Generator - Reference

Automatically generates comprehensive API documentation for Swift package dependencies using [`interfazzle`](https://github.com/czottmann/interfazzle).

## Contents

- [Features](#features)
- [Command-Line Usage](#command-line-usage)
- [How It Works](#how-it-works)
- [When to Use](#when-to-use)
- [Requirements](#requirements)
- [Output Format](#output-format)
- [Implementation](#implementation)
- [Testing](#testing)

## Features

- **Automatic package resolution**: Maps module names to package names using dependency information
- **Smart caching**: Checks for existing documentation before generating
- **Clean integration**: Uses OS temporary directories for generation with automatic cleanup
- **Comprehensive output**: Combines all generated markdown with package README files
- **Version-aware**: Generates docs with version-specific filenames (major.minor format)

## Command-Line Usage

```bash
python3 ./scripts/generate_docs.py <module_or_package_name> <xcodeproj_path>
```

### Arguments

- `module_or_package_name`: The Swift module or package name (e.g., `ButtonKit`, `Defaults`)
- `xcodeproj_path`: Path to the Xcode project file (e.g., `/path/to/MyApp.xcodeproj`)

### Example

```bash
python3 ./scripts/generate_docs.py ButtonKit /Users/yourname/Code/MyProject/MyProject.xcodeproj
```

Output:

```
/Users/yourname/Code/MyProject/dependency-docs/ButtonKit-0.6.md
```

## How It Works

From within Claude Code, this skill automatically:

1. **Resolves module to package** using shared Swift package utilities
2. **Checks for existing documentation** in `dependency-docs/`
3. **If docs don't exist:**
   - Locates the package in DerivedData
   - Extracts version from git tags (major.minor only)
   - Runs `interfazzle generate` with OS temporary directory
   - Concatenates all generated `.md` files
   - Appends the package's README if it exists
   - Saves to `dependency-docs/<package-name>-<major.minor>.md`
   - Temporary directory is automatically cleaned up
4. **Returns the documentation file path**

## When to Use

Use this skill when:

- You encounter an unfamiliar module import and need its API documentation
- You want to explore a dependency's API surface
- You need to reference package documentation while coding
- Working with Swift packages and need quick access to their public interfaces

### Example Scenario

When you encounter an unfamiliar import:

```swift
import ButtonKit
```

The skill generates (or retrieves) documentation at:

```
<project>/dependency-docs/ButtonKit-0.6.md
```

## Requirements

- Python 3.6+
- `interfazzle` CLI tool installed and in PATH (https://github.com/czottmann/interfazzle)
- Shared Swift package utilities (`_shared/swift_packages.py`)
- Project must be built at least once (DerivedData must exist)

## Output Format

Documentation files are saved as:

```
<project>/dependency-docs/<PackageName>-<major.minor>.md
```

This means:

- Documentation is generated once per major.minor version
- Subsequent requests for the same package version use the cached file
- Patch version updates don't trigger regeneration
- Major or minor version updates will generate new documentation

## Implementation

The skill consists of:

- `SKILL.md` - Skill definition with YAML frontmatter
- `reference.md` - This detailed reference documentation
- `scripts/generate_docs.py` - Main implementation script (relative to skill directory)
- `../_shared/swift_packages.py` - Shared Swift package utilities (used by multiple skills)

## Testing

Verified working with:

- ButtonKit 0.6.1 → `ButtonKit-0.6.md` (21KB)
- Defaults 8.2.0 → `Defaults-8.2.md` (47KB)
- Diagnostics 5.1.0 → `Diagnostics-5.1.md` (comprehensive API docs)

All successfully generated, cached on subsequent runs, with automatic temp directory cleanup.
