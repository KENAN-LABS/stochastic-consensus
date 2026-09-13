---
type: regex
weight: 1
target: last_message
pattern: "traces?[^\\n]{0,30}\\b3\\b"
flags: "i"
---

`traces` is `max(3, ceil(6/4))` = 3, and it is never reduced to fit a ceiling.
Cutting traces is the most tempting reduction — they look like overhead next to
unit coverage — and the worst one, because the seams are where unit-scoped
researchers were already structurally blind.
