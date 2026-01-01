---
name: generating-swift-package-docs
description: Use when encountering unfamiliar import statements, exploring dependency APIs, or when user asks "what's import X" or "what does X do". Generates on-demand API documentation for Swift package dependencies.
---

# Swift Package Documentation Generator

Generates API documentation for Swift package dependencies on-demand, extracting symbol information from Xcode's DerivedData to answer "what does this library do?"

## Overview

When exploring unfamiliar dependencies, generate their documentation automatically instead of guessing from code. This tool uses `interfazzle` to extract symbol information from compiled modules.

## How to Use

When asked about an unfamiliar Swift module import:

1. Run: `./scripts/generate_docs.py "<module_name>" "<path_to.xcodeproj>"`
2. Script outputs path to cached documentation file
3. Read the file and provide relevant information

Prerequisites: Project must be built once (DerivedData exists), `interfazzle` CLI installed.

See [reference.md](reference.md) for error handling and details.
