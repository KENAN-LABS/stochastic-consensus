---
type: regex
weight: 1
target: last_message
pattern: "api-core[^\\n]*\\|\\s*7\\s*\\|"
flags: "i"
---

`core` is never demotable and never loses a scope, so `api-core` ends on 7
whatever the ceiling did. Cutting a scope from a core unit is the reduction the
rule forbids most firmly — it is the cheapest way to hit a budget and the one
nobody downstream can see.
