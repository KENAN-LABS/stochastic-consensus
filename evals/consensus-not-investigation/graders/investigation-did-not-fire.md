---
type: tool_used
weight: 1
tool: Skill
input_match: fanout-investigation
min: 0
max: 0
---

The other half of the boundary check.

"Every way", "wide sweep", "as many independent angles as you can get" are all
breadth cues, and the investigation skill also fires on breadth cues. What
separates them is what the agents differ by — lens on one question here, slice
of the material there. Firing the investigation skill on a churn brainstorm
would mean the boundary clause in its description is not doing its job.

`min: 0` is required alongside `max: 0`. Without it the harness defaults `min` to
1 and the grader reads "expected 1..0", which fails in every case including the
one it is meant to pass.
