description: Asks Claude to generate a handoff summary for a future session. Writes it to file. It can then be read by the `resume` command.
disable-model-invocation: true
---

Generate a handoff summary and write it to `.claude/handoff.md`.

## Include:

1. **Summary** - What was accomplished (2-4 bullets)
2. **State** - Branch, uncommitted changes, open beads/tasks with IDs, any claude-mem references (if known)
3. **Decisions** - Any choices made or pending
4. **Next** - Clear starting point.

Keep under 250 words. Use IDs and file paths for quick lookup.

## Output:

Write the summary to `.claude/handoff.md` (create directory if needed).