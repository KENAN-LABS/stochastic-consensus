---
type: tool_used
weight: 1
tool: Skill
input_match: fanout-investigation
min: 0
max: 0
---

The negative case. This is nine lines of code with one answer, visible in the
snippet — a bare `return` with no value.

A skill that spawns a recon agent and a matrix for this is worse than a skill
that never fires at all, because it costs real money and minutes to arrive
somewhere a single sentence reaches. Firing here is a triggering regression of
the most expensive kind.

**`min: 0` is not redundant.** A `tool_used` grader given only `max` defaults its
`min` to 1, so `max: 0` alone evaluates as "expected 1..0" and can never pass —
it fails identically whether the tool was used or not. Observed on Claude Code
2.1.270. Every "must not happen" grader in this suite states both bounds.
