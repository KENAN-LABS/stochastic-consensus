---
type: regex
weight: 1
target: last_message
pattern: "\\|\\s*mobile\\s*\\|\\s*supporting"
flags: "i"
---

One demotion is all the ceiling needs, so `mobile` must still be `supporting` in
the committed matrix. Catches an over-reduction that happens to reach a total at
or under 24 by demoting more than the rule calls for.
