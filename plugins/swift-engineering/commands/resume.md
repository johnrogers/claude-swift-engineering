description: Resume work from a previous session handoff. Reads the handoff file and then deletes it when done.
disable-model-invocation: true
---

Read `.claude/handoff.md` and use it to orient this session.

1. Read the handoff file
2. If older than 24 hours, warn the user before proceeding
3. Briefly summarize where we left off
4. Delete the handoff file
5. Ask the user what they want to focus on from the "Next" items

If no handoff file exists, say so and offer to check git log, claude-mem, and open beads instead.