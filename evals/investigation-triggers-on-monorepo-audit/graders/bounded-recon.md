---
type: tool_used
weight: 1
tool: Agent
min: 0
max: 3
---

`max_turns: 4` is what keeps this case cheap — it grades triggering, and cuts
the run off long before a full fan-out. This grader bounds the other axis, so a
run that somehow reaches Phase 2 inside four turns fails rather than quietly
costing a fan-out's worth of tokens.

`min: 0` because a recon spawn is expected but not required inside four turns,
and its absence is not what this case is about.

An earlier version of this case asserted in `append_system_prompt` that
subagents were unavailable, and then graded that the skill fired. It failed, and
correctly — told it cannot spawn anything, the model declined to load a skill
built entirely on spawning and explained why instead. Suppressing the mechanism
under test and then testing for it is a case-design bug, not a skill regression.
