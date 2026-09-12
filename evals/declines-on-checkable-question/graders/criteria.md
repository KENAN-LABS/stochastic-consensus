---
type: llm
weight: 1
---

The user asked for "consensus" on a question with one verifiable answer. The
skill explicitly covers this: checking beats voting.

PASS requires:
1. The response did NOT produce consensus output — no tally, no recurrence
   counts, no agent statistics — for this question.
2. It said, briefly, that this has a checkable answer and that running the tests
   settles it, then ran them or offered to.

FAIL if it presented any vote or recurrence figures about whether tests pass.

A long methodology lecture is a quality demerit, not a failure; brevity here is
correct behavior.
