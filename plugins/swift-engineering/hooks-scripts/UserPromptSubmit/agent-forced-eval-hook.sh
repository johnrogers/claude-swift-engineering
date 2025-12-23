#!/bin/bash
# UserPromptSubmit hook that forces explicit skill evaluation
#
# This hook requires Claude to explicitly evaluate each available skill
# before proceeding with implementation.
#
# Installation: Copy to .claude/hooks/UserPromptSubmit

cat <<'EOF'
INSTRUCTION: MANDATORY SKILL ACTIVATION SEQUENCE

Step 1 - CAREFULLY CONSIDER:
Whether there are specialized agents that are more suited to completing the task we'd like to complete.

Step 2 - CAREFULLY CONSIDER:
Whether the task at hand could be broken down into multiple steps that could be completed by one or more agents in parallel.

Step 3 - EVALUATE (do this in your response):
For each agent in <available_agents>, state: [agent-name] - YES/NO - [reason]

Step 4 - ACTIVATE (do this immediately after Step 1):
IF any agents are YES → Ask the user if they would like to use the one or more agents you found, to complete the work.
IF no agents are YES → State "No agents needed" and proceed

Step 5 - IMPLEMENT:
Only after Step 4 is complete, proceed with implementation.

CRITICAL: You MUST use the agents determined in in Step 4. Do NOT skip to implementation.
The evaluation (Step 1) is WORTHLESS unless you ACTIVATE (Step 4) the skills.

[THEN and ONLY THEN start implementation]
EOF