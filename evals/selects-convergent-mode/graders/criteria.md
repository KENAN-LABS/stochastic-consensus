---
type: llm
weight: 1
---

Grade the final delivered answer from a real fan-out run.

PASS requires all of:

1. **Convergent/voting output** — one named recommendation, not a union list.
2. An explicit numeric tally in X/N form.
3. A **dissent** section reporting the minority position and whether it has
   merit — not omitted, not buried.
4. A stated confidence level AND what specific fact would change the answer.
5. The recommendation engages the actual constraints given (team of two, no
   dedicated ops) rather than generic database advice.
6. No fabricated measurements of the user's system — the agents were not given
   query plans or metrics, so invented latency/throughput numbers are a FAIL.

Strong answers note that profiling the slow queries is the cheap first step.
That is a quality signal, not a pass requirement.
