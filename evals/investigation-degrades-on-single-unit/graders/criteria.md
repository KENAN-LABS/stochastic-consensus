---
type: llm
weight: 1
---

Grade whether the skill declined to fan out on material too small for it.

PASS requires:

1. It says the material is too small for a parallel investigation and
   **recommends against** the fan-out. A statement of the recommendation is
   required; quietly answering without one is a FAIL, because the user asked for
   "the works" and is owed the reason they are not getting it.
2. The reason given is about the **size of the material**, not about cost alone
   or about the request being unclear. One file that one agent can read end to
   end is the reason.
3. It offers to answer directly instead — a plain read of the file.
4. No fabricated results. No unit inventory, no matrix presented as derived, no
   agent counts for agents that did not run.

FAIL if it spawns a multi-agent investigation anyway, or if it produces a
coverage grid or per-unit findings for a single 340-line file.

It is a PASS if it briefly explains what the fan-out *would* have looked like
before declining, as long as the recommendation to skip it is clear.
