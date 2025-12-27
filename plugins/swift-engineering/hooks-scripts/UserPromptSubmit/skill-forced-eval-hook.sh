#!/bin/bash
cat <<'EOF'
INSTRUCTION: MANDATORY SKILL ACTIVATION SEQUENCE

Step 1 - EVALUATE (do this in your response):
For each skill in <available_skills>, state: [skill-name] - YES/NO - [reason]

Step 2 - ACTIVATE (do this immediately after Step 1):
IF any skills are YES → Use Skill(skill-name) tool for EACH relevant skill NOW
IF no skills are YES → State "No skills needed" and proceed

Step 3 - IMPLEMENT:
Only after Step 2 is complete, proceed with implementation.

CRITICAL: You MUST call Skill() tool in Step 2. Do NOT skip to implementation.
The evaluation (Step 1) is WORTHLESS unless you ACTIVATE (Step 2) the skills.

CRITICAL: You MUST perform the above steps. Do not try to talk yourself out of it or convince yourself otherwise. The
human has requested that you MUST perform the above steps, make sure that you do.

EXAMPLES OF WHEN TO USE SKILLS:
- "Implement SwiftUI view" → swift-engineering:swiftui-common-patterns
- "Create TCA feature" → swift-engineering:composable-architecture
- "Use @Observable" → swift-engineering:modern-swiftui
- "Fix animation/motion" → swift-engineering:ios-hig
- "Write tests" → swift-engineering:swift-testing
- "Work with SQLiteData" → swift-engineering:sqlite-data

Example of correct sequence:
- programming-swift-skill:programming-swift: NO - not looking up Swift syntax
- swift-engineering:modern-swiftui: YES - using @Observable pattern
- swift-engineering:swiftui-common-patterns: YES - building SwiftUI views
- swift-engineering:ios-hig: YES - need animation/accessibility guidance

[Then IMMEDIATELY use Skill() tool for EACH YES:]
> Skill(swift-engineering:modern-swiftui)
> Skill(swift-engineering:swiftui-common-patterns)
> Skill(swift-engineering:ios-hig)

[THEN and ONLY THEN start implementation]
EOF