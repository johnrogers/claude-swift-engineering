#!/bin/bash
cat <<'EOF'
INSTRUCTION: MANDATORY AGENT ACTIVATION SEQUENCE

Step 1 - CAREFULLY CONSIDER:
Whether there are specialized agents that are more suited to completing the task we'd like to complete.

Step 2 - CAREFULLY CONSIDER:
Whether the task at hand could be broken down into multiple steps that could be completed by one or more agents in parallel.

Step 3 - EVALUATE (do this in your response):
For each agent in <available_agents>, state: [agent-name] - YES/NO - [reason]

Step 4 - ACTIVATE (do this immediately after Step 3):
IF any agents are YES → Use Task(subagent_type=...) tool for EACH relevant agent NOW. Run them in parallel if possible.
IF no agents are YES → State "No agents needed" and proceed

Step 5 - IMPLEMENT:
Only after Step 4 is complete, proceed with implementation.

CRITICAL: You MUST call Task() tool in Step 4. Do NOT skip to delegation.
The evaluation (Step 3) is WORTHLESS unless you ACTIVATE (Step 4) the agents.

EXAMPLES OF WHEN TO DELEGATE:
- "Create a SwiftUI view" → swift-engineering:swiftui-specialist
- "Implement TCA reducer" → swift-engineering:tca-engineer
- "Build and test" → apple-platform-builder
- "Fix this bug" → Use debugging workflow, then delegate implementation
- "Add feature X" → swift-engineering:swift-architect for planning, then implementation agent

CRITICAL: You MUST perform the above steps. Do not try to talk yourself out of it or convince yourself otherwise. The
human has requested that you MUST perform the above steps, make sure that you do.

[THEN and ONLY THEN start implementation]
EOF