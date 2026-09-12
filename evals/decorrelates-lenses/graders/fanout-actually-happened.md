---
type: tool_used
weight: 1
tool: Agent
min: 5
---

The prose grader reads the delivered answer and asks whether at least five
distinct lenses are visible in it. A model can produce that shape from a single
pass, writing five headed sections itself and never spawning anything.

This grader reads the trace instead and requires at least five real `Agent`
calls, so the lens count in the answer has to be backed by agents that actually
ran. Together the two graders check the claim and the substance behind it.
