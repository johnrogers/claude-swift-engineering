# Claude Code Hooks

This directory contains hook scripts that enhance Claude Code's behavior.

## Quick Setup

### Step 1: Symlink hooks-scripts to your .claude directory

```bash
# From the swift-engineering plugin directory
ln -s $(pwd)/hooks-scripts ~/.claude/hooks-scripts
```

Or if you know the full path:

```bash
ln -s /path/to/claude-swift-engineering/plugins/swift-engineering/hooks-scripts ~/.claude/hooks-scripts
```

### Step 2: Add hooks to ~/.claude/settings.json

Edit your `~/.claude/settings.json` and add the UserPromptSubmit hook to the `hooks` section:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "cat ~/.claude/hooks-scripts/UserPromptSubmit/skill-forced-eval-hook.sh"
          }
        ]
      }
    ]
  }
}
```

If you already have other hooks defined, just add the `UserPromptSubmit` entry alongside them.

## Available Hooks

### UserPromptSubmit: skill-forced-eval-hook.sh

**Purpose:** Forces explicit skill evaluation before implementation.

**What it does:**
- Requires you to evaluate each available skill (YES/NO)
- Ensures you activate relevant skills via the Skill tool
- Prevents skipping directly to implementation

**Activation sequence (enforced by hook):**
1. **EVALUATE** — For each skill: `[skill-name] - YES/NO - [reason]`
2. **ACTIVATE** — Use `Skill(skill-name)` for each YES
3. **IMPLEMENT** — Only after activation is complete

## How Hooks Work

When a hook is configured:
1. Claude Code executes the hook command before processing user input
2. The command output is displayed as instructions
3. You must follow the instructions before proceeding

The hook ensures discipline around skill selection and prevents jumping to implementation without evaluating available tools.
