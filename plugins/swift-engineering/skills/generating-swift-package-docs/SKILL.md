---
name: generating-swift-package-docs
description: Use when encountering unfamiliar import statements, exploring dependency APIs, or when user asks "what's import X" or "what does X do". Generates on-demand API documentation for Swift package dependencies in Xcode projects.
---

# Swift Package Documentation Generator

When asked about an unfamiliar Swift module import:

1. Run: `./scripts/generate_docs.py "<module_name>" "<path_to.xcodeproj>"`
2. Script outputs path to cached documentation file
3. Read the file and provide relevant information

Prerequisites: Project must be built once (DerivedData exists), `interfazzle` CLI installed.

See [reference.md](reference.md) for error handling and details.
