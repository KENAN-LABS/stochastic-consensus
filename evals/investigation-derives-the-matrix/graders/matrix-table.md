---
type: regex
weight: 1
target: last_message
pattern: "\\|[^\\n|]*unit[^\\n|]*\\|[^\\n|]*tier[^\\n|]*\\|"
flags: "i"
---

The matrix print is mandatory before any researcher spawns, and it is specified
as a table. This checks a table with Unit and Tier columns was actually
rendered, rather than the counts being described in a sentence.

Free and mechanical, so it cannot return a split verdict on something this
structural.
