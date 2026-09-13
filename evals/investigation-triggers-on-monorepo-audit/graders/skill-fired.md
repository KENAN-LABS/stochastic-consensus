---
type: tool_used
weight: 1
tool: Skill
input_match: fanout-investigation
min: 1
---

The plugin-fired indicator for this skill. An eleven-package audit with an
explicit "nothing skipped" is the centre of this skill's target, so failing to
fire here is a triggering regression.

`input_match` matters. Both skills in this plugin fan out subagents, and a bare
`tool_used: Skill` would pass if the sibling skill fired instead — which is the
specific confusion this case and `consensus-not-investigation` bracket.
