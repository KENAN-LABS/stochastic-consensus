---
type: llm
weight: 1
---

"Make the app feel faster" is a prompt where lazy lenses collapse into synonyms.
This grades decorrelation quality specifically.

PASS requires:
1. The answer names at least 5 lenses, each along a genuinely different
   dimension. Strong examples: real latency (network/render), *perceived*
   performance (skeletons, optimistic UI), startup/cold-boot, data and caching
   strategy, asset and bundle weight, interaction and animation responsiveness,
   offline behavior.
2. The resulting candidate groups are substantially non-overlapping — evidence
   the lenses actually decorrelated the sample. Heavy repetition of the same
   ideas across groups is a FAIL.
3. The real-vs-perceived performance distinction appears somewhere. It is the
   highest-value axis for this question and a strong signal the lenses were
   derived from the domain rather than pulled from a stock list.
4. A visible long tail: some candidates marked as uncorroborated singletons.

FAIL if the lenses are near-synonyms ("speed", "performance", "responsiveness",
"optimization") or if fewer than 5 are used.
