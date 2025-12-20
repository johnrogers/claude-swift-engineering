---
name: generating-swift-package-docs
description: Use when encountering unfamiliar import statements; when exploring a dependency's API; when user asks "what's import X?", "what does import X do?", or about package documentation. - Generates comprehensive API documentation for Swift package dependencies on-demand. This skill helps you quickly obtain documentation for packages used in Xcode projects when you encounter unfamiliar module imports. Automatically resolves modules to packages and caches documentation for reuse. This is the primary tool for understanding individual `import` statements.
---

# Swift Package Documentation Generator

When asked about an unfamiliar Swift module import:

1. Run: `./scripts/generate_docs.py "<module_name>" "<path_to.xcodeproj>"`
2. Script outputs path to cached documentation file
3. Read the file and provide relevant information

Prerequisites: Project must be built once (DerivedData exists), `interfazzle` CLI installed.

See [reference.md](reference.md) for error handling and details.
