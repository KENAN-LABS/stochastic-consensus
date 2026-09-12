# Failure modes

Six ways a consensus run goes wrong. The first three produce output that looks
correct, which is what makes them worth memorizing.

## 1. Correlated agents ("five copies of one opinion")

**Symptom.** The merged pool is barely larger than one agent's list. Almost
everything has a high recurrence count and there is no long tail.

**Cause.** Every agent got the same prompt, or lenses that overlap heavily
("performance" and "speed" and "efficiency" are one lens with three names).

**Fix.** Before spawning, read the lens list and ask: *would two agents holding
these produce nearly disjoint lists?* If not, rebuild the lenses along a
different dimension (see SKILL.md Step 3). High uniform recurrence is not a
strong consensus — it is usually evidence the run was redundant.

## 2. Topical lenses in convergent mode

**Symptom.** You cannot compute a tally. Each agent returned a thoughtful
analysis of a different aspect, and none of them actually answered the question.

**Cause.** Convergent mode was run with divergent-style lenses. "Look at this
from a security angle" does not produce a vote; it produces an essay.

**Fix.** Rotate *stance*, not topic: for, against, failure-hunter,
premise-checker. Every agent must answer the same question and commit to one
answer, or there is nothing to count.

## 3. Context starvation

**Symptom.** Agents disagree confidently, and the disagreements turn out to be
about facts that were settled in your conversation — they invented different
versions of the user's stack, scale, or constraints.

**Cause.** Subagents inherit no conversation history. Each one filled the gaps
differently, so they answered different questions and you tallied the result
anyway.

**Fix.** Paste the relevant context into every generator prompt verbatim and
identically. This is the most damaging failure mode because the output still
looks like a clean vote — the corruption is invisible in the result.

## 4. Synthesis flattening

**Symptom.** The final list is shorter and blander than the raw pool. The
interesting outliers are gone.

**Cause.** Over-aggressive merging, or an instinct to present only well-supported
ideas. In divergent mode this deletes exactly what the run was for: singletons
are the tail you paid N × M samples to reach.

**Fix.** Keep singletons, mark them uncorroborated. Merge only when two items are
genuinely the same idea, not merely adjacent. If the distinct count is close to M
(one agent's worth), you over-merged.

## 5. Fabricated counts

**Symptom.** Recurrence numbers that were never computed, agent counts that never
ran, or "most agents agreed" standing in for a tally.

**Cause.** The format invites numbers, and producing them is easier than earning
them.

**Fix.** Report only what ran. If the fan-out failed, say so and answer directly.
If 3 of 8 agents returned nothing, N is 5 and you say 3 failed. A single-pass
answer honestly labeled is fine; a single-pass answer wearing consensus clothing
is not, because the reader cannot tell the difference and will decide on it.

## 6. Using it at all

**Symptom.** 200k tokens spent to answer something a grep, a test run, or one
paragraph would have settled.

**Cause.** The technique is satisfying to run.

**Fix.** Ask whether the question has a checkable answer. If it does, check it —
one test run outranks ten confident agents. Consensus earns its cost only when
the answer space is genuinely open (divergent) or genuinely uncertain
(convergent).
