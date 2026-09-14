---
type: tool_used
weight: 1
tool: Agent
min: 0
max: 0
---

The prompt supplies the inventory and asks for the numbers before anything runs,
so a spawn here is a violation of the matrix-print gate rather than a cost
problem. Checked from the trace, because `allowed_tools` does not reliably gate
the `Agent` tool on this harness.

This grader is load-bearing only because the case no longer suppresses the thing
it is testing. It used to assert in `append_system_prompt` that subagents were
unavailable, and then check that none were spawned — which cannot fail for any
reason to do with the skill, and is the same case-design bug
`bounded-recon.md` documents in `investigation-triggers-on-monorepo-audit`.
Worse here: the case also requires the skill to FIRE, and a model told it cannot
spawn has good reason to decline a skill built entirely on spawning.

With the constraint gone, the model can spawn, and choosing not to is a real
decision about the matrix-print gate and about the caller's explicit "don't
spawn anything yet". `max_turns: 10` is the cost bound.
