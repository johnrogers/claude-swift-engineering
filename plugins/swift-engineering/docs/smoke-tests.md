# Smoke Tests for Swift Engineering Plugin

This document outlines smoke tests to validate the plugin configuration and agent behavior.

## Test Structure

Each test validates a specific aspect of the plugin configuration:
- Agent metadata (tools, model, skills)
- Agent handoff chains (completeness and consistency)
- Command workflows (phase sequences)
- Skill availability

## Automated Validation Tests

### 1. Agent Configuration Tests

**Test: Validate all agents have required metadata**

```bash
#!/bin/bash
# test-agent-metadata.sh

AGENT_DIR="plugins/swift-engineering/agents"
FAILED=0

for agent_file in "$AGENT_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)
    echo "Testing: $agent_name"

    # Check for required frontmatter fields
    if ! grep -q "^name:" "$agent_file"; then
        echo "  ✗ Missing 'name' field"
        FAILED=1
    fi

    if ! grep -q "^description:" "$agent_file"; then
        echo "  ✗ Missing 'description' field"
        FAILED=1
    fi

    if ! grep -q "^tools:" "$agent_file"; then
        echo "  ✗ Missing 'tools' field"
        FAILED=1
    fi

    if ! grep -q "^model:" "$agent_file"; then
        echo "  ✗ Missing 'model' field"
        FAILED=1
    fi

    # Check for required sections
    if ! grep -q "## Identity" "$agent_file"; then
        echo "  ✗ Missing 'Identity' section"
        FAILED=1
    fi

    if ! grep -q "## When to Hand Off" "$agent_file"; then
        echo "  ✗ Missing 'When to Hand Off' section"
        FAILED=1
    fi

    if [ $FAILED -eq 0 ]; then
        echo "  ✓ Passed"
    fi
done

exit $FAILED
```

**Expected result:** All agents pass validation

---

### 2. Model Assignment Tests

**Test: Verify model assignments match design**

```bash
#!/bin/bash
# test-model-assignments.sh

# Planning agents should use Opus
OPUS_AGENTS=("swift-architect" "tca-architect" "swift-ui-design")
for agent in "${OPUS_AGENTS[@]}"; do
    model=$(grep "^model:" "plugins/swift-engineering/agents/$agent.md" | awk '{print $2}')
    if [ "$model" != "opus" ]; then
        echo "✗ $agent should use opus, but uses $model"
        exit 1
    fi
    echo "✓ $agent uses opus"
done

# Builder should use Haiku
model=$(grep "^model:" "plugins/swift-engineering/agents/swift-builder.md" | awk '{print $2}')
if [ "$model" != "haiku" ]; then
    echo "✗ swift-builder should use haiku, but uses $model"
    exit 1
fi
echo "✓ swift-builder uses haiku"

# Implementation agents should use Sonnet
SONNET_AGENTS=("swift-engineer" "tca-engineer" "swiftui-specialist" "swift-test-creator" "swift-code-reviewer" "swift-modernizer" "swift-documenter")
for agent in "${SONNET_AGENTS[@]}"; do
    model=$(grep "^model:" "plugins/swift-engineering/agents/$agent.md" | awk '{print $2}')
    if [ "$model" != "sonnet" ]; then
        echo "✗ $agent should use sonnet, but uses $model"
        exit 1
    fi
    echo "✓ $agent uses sonnet"
done

echo "All model assignments correct"
```

**Expected result:** All model assignments match specification

---

### 3. Read-Only Agent Tests

**Test: Verify planning agents are read-only**

```bash
#!/bin/bash
# test-read-only-agents.sh

# Planning agents should NOT have Write or Edit in tools
READONLY_AGENTS=("swift-architect" "tca-architect" "swift-ui-design")
FAILED=0

for agent in "${READONLY_AGENTS[@]}"; do
    tools=$(grep "^tools:" "plugins/swift-engineering/agents/$agent.md")

    # Note: After addressing code comments, swift-architect and tca-architect
    # DO need Write/Edit to update plan files. Only swift-ui-design is purely read-only.
    if [ "$agent" = "swift-ui-design" ]; then
        if echo "$tools" | grep -qE "(Write|Edit)"; then
            echo "✗ $agent should be read-only but has Write/Edit tools"
            FAILED=1
        else
            echo "✓ $agent is read-only"
        fi
    else
        # swift-architect and tca-architect need Write/Edit for plan files
        if ! echo "$tools" | grep -q "Write"; then
            echo "✗ $agent should have Write tool for plan file updates"
            FAILED=1
        else
            echo "✓ $agent has Write tool for plan file updates"
        fi
    fi

    # All planning agents should have READ-ONLY MODE section
    if ! grep -q "## CRITICAL: READ-ONLY MODE" "plugins/swift-engineering/agents/$agent.md"; then
        echo "✗ $agent missing READ-ONLY MODE section"
        FAILED=1
    fi
done

exit $FAILED
```

**Expected result:** Planning agents enforce read-only constraints

---

### 4. Handoff Chain Completeness

**Test: Verify all referenced agents exist**

```python
#!/usr/bin/env python3
# test-handoff-references.py

import re
import os
from pathlib import Path

AGENT_DIR = Path("plugins/swift-engineering/agents")
agent_files = list(AGENT_DIR.glob("*.md"))
agent_names = {f.stem for f in agent_files}

# Pattern to match @agent-name references
AGENT_PATTERN = re.compile(r'@([a-z-]+)')

failed = False
for agent_file in agent_files:
    content = agent_file.read_text()

    # Find all @agent references
    references = set(AGENT_PATTERN.findall(content))

    # Remove self-references
    references.discard(agent_file.stem)

    # Check if all referenced agents exist
    for ref in references:
        if ref not in agent_names and ref not in ['agent-name']:  # 'agent-name' is a placeholder
            print(f"✗ {agent_file.name}: references non-existent agent @{ref}")
            failed = True

if not failed:
    print("✓ All agent references valid")
    exit(0)
else:
    exit(1)
```

**Expected result:** All agent references are valid

---

### 5. Skill Availability Test

**Test: Verify all referenced skills exist**

```bash
#!/bin/bash
# test-skill-references.sh

SKILL_DIR="plugins/swift-engineering/skills"
AGENT_DIR="plugins/swift-engineering/agents"
FAILED=0

# Get list of available skills
AVAILABLE_SKILLS=()
for skill in "$SKILL_DIR"/*/SKILL.md; do
    skill_name=$(basename "$(dirname "$skill")")
    AVAILABLE_SKILLS+=("$skill_name")
done

# Check each agent's skill references
for agent_file in "$AGENT_DIR"/*.md; do
    agent_name=$(basename "$agent_file" .md)

    # Extract skills from frontmatter
    skills_line=$(grep "^skills:" "$agent_file")
    if [ -n "$skills_line" ]; then
        # Parse comma-separated skills
        IFS=',' read -ra SKILLS <<< "${skills_line#skills:}"

        for skill in "${SKILLS[@]}"; do
            # Trim whitespace
            skill=$(echo "$skill" | xargs)

            # Check if skill exists
            found=0
            for available in "${AVAILABLE_SKILLS[@]}"; do
                if [ "$skill" = "$available" ]; then
                    found=1
                    break
                fi
            done

            if [ $found -eq 0 ]; then
                echo "✗ $agent_name references non-existent skill: $skill"
                FAILED=1
            fi
        done
    fi
done

if [ $FAILED -eq 0 ]; then
    echo "✓ All skill references valid"
fi

exit $FAILED
```

**Expected result:** All skill references are valid

---

## Manual Integration Tests

These tests require manual execution and observation:

### Test 1: Full Feature Workflow (TCA)

```bash
# In Claude Code, run:
/feature Build a counter feature with increment/decrement buttons using TCA

# Expected flow:
# 1. @swift-architect creates plan (TCA chosen)
# 2. @tca-architect designs TCA architecture
# 3. @tca-engineer implements reducer/state/actions
# 4. @swiftui-specialist creates view
# 5. (optional) @swift-code-reviewer reviews
# 6. @swift-test-creator writes tests
# 7. @swift-builder verifies build
# 8. (optional) @swift-documenter updates docs

# Verify:
# - Plan file created at docs/plans/counter.md
# - All status items checked off
# - Handoff log complete
# - Build passes
```

### Test 2: Full Feature Workflow (Vanilla Swift)

```bash
# In Claude Code, run:
/feature Build a simple calculator utility (no UI) using vanilla Swift

# Expected flow:
# 1. @swift-architect creates plan (vanilla chosen)
# 2. @swift-engineer implements core logic
# 3. @swift-test-creator writes tests
# 4. @swift-builder verifies build

# Verify:
# - Plan file created
# - TCA phases skipped
# - SwiftUI phases skipped (no UI)
# - Correct agent sequence
```

### Test 3: Planning Agent Read-Only Enforcement

```bash
# In Claude Code, run:
/plan Design a user authentication feature

# Expected behavior:
# - @swift-architect creates/updates plan file ONLY
# - NO Swift implementation files created
# - Plan file contains architecture decisions
# - Agent stops after planning (doesn't implement)

# Verify:
# - No .swift files created in Features/ directory
# - Only docs/plans/<feature>.md modified
```

### Test 4: Error Triage Handoff

```bash
# Introduce a deliberate TCA error in a feature, then:
/build

# Expected behavior:
# - @swift-builder attempts fix (up to 3 times)
# - After 3 failures, uses Error Triage table
# - Hands off to @tca-engineer (if TCA error)
# - Updates plan file with handoff notes

# Verify:
# - Handoff log shows error category
# - Correct specialist called
```

### Test 5: Opus Agent Context Budget

```bash
# Create a very large feature description, then:
/plan <large-feature-description>

# Expected behavior:
# - @swift-architect stays under 100K tokens if possible
# - If unavoidable to exceed, prioritizes critical decisions
# - Plan is concise and focused

# Verify:
# - Check token usage in logs
# - Plan doesn't include unnecessary detail
```

---

## Running the Tests

### Automated Tests

```bash
# Run all automated tests
cd plugins/swift-engineering

./docs/smoke-tests/test-agent-metadata.sh
./docs/smoke-tests/test-model-assignments.sh
./docs/smoke-tests/test-read-only-agents.sh
python3 ./docs/smoke-tests/test-handoff-references.py
./docs/smoke-tests/test-skill-references.sh
```

### Manual Tests

Follow the manual test procedures above and document results.

---

## Test Maintenance

Update these tests when:
- New agents are added
- Agent configurations change
- New skills are added
- Workflow phases are modified
- Handoff patterns change

---

## CI Integration (Optional)

To run automated tests in CI:

```yaml
# .github/workflows/plugin-validation.yml
name: Plugin Validation

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run agent metadata tests
        run: bash plugins/swift-engineering/docs/smoke-tests/test-agent-metadata.sh

      - name: Run model assignment tests
        run: bash plugins/swift-engineering/docs/smoke-tests/test-model-assignments.sh

      - name: Run read-only agent tests
        run: bash plugins/swift-engineering/docs/smoke-tests/test-read-only-agents.sh

      - name: Run handoff reference tests
        run: python3 plugins/swift-engineering/docs/smoke-tests/test-handoff-references.py

      - name: Run skill reference tests
        run: bash plugins/swift-engineering/docs/smoke-tests/test-skill-references.sh
```

---

This smoke test suite provides both automated and manual validation to ensure the plugin configuration is correct and agent behavior follows the design specification.
