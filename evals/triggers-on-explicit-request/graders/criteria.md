---
type: llm
weight: 1
---

Grade the final delivered answer from a real fan-out run.

PASS requires all of:

1. **Divergent/union output**, not a ranked top-N or a single recommendation.
2. A run-statistics line reporting agents × candidates → pool → distinct count,
   and a list of the lenses used.
3. At least 5 lenses, drawn from the CI/build domain (caching, parallelization,
   test selection/splitting, runner hardware, dependency install, container
   images, flaky-test triage, pipeline structure). Near-synonym lenses
   ("performance", "speed", "efficiency") are a FAIL.
4. **Recurrence counts on candidates** (e.g. `×4`), not bare bullets.
5. Singletons preserved and marked uncorroborated — the long tail is not
   deleted.
6. Candidates are concrete and actionable (specific caches, specific
   parallelization strategies), not category labels.

FAIL if the answer is a short generic list of CI tips with no run statistics,
no lenses, and no recurrence counts.
