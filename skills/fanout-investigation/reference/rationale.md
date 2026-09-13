# Rationale

Why the count is arithmetic and why disk is not optional. Both look like
overhead. Both are the skill. If a future maintainer removes either, the skill
still runs, still produces a confident report, and quietly stops working — which
is why this file exists.

## Why the agent count is derived rather than chosen

Ask a model how many agents a job needs and it answers before it has read the
job. The estimate is made from the *framing* of the request, and framings are
short, so the estimate is small. Two or three agents is the reliable answer to
almost any question, including questions that need twenty.

That would be survivable if the error were visible. It is not. An
under-decomposed run returns a well-organised report about the parts it looked
at, and says nothing at all about the parts it did not — because no agent was
assigned to them, so nothing came back empty, so nothing signalled a gap. The
reader sees a complete-looking document. The only artefact that would reveal the
hole is the coverage grid, and the grid can only be built if the units were
enumerated first.

So the skill removes the judgement call. Phase 0 enumerates and tiers; the rule
multiplies. The model's judgement is spent where judgement is actually good —
deciding *which* units are `core` — and not on an effort estimate, which is where
it is reliably bad.

A derived number also makes the run auditable. `6 units, 2 core at 7 scopes, 2
supporting at 3, 2 peripheral at 1, plus 3 traces` can be checked by anyone. "I
think about five agents should do it" cannot be checked at all, including by the
model that said it.

**If you are tempted to simplify this**, the thing to preserve is that the number
is *computed from an enumeration made after reading*. The specific scope counts
are tunable. The order — survey, enumerate, tier, multiply — is not.

## Why the floor exists

The rule can produce a number too small to be worth the machinery. Three
researchers on a real investigation is not a fan-out; it is three agents. The
floor keeps the method honest about its own shape — either the material deserves
a real fan-out, or Phase 0 should have cancelled the run.

Traces are excluded from the floor deliberately. Otherwise a run could satisfy
the floor entirely with cross-cutting agents and cover no unit in depth, which
inverts the design.

## Why the ceiling refuses rather than trims

Every reduction strategy that silently fits the budget is a strategy for hiding
scope loss. Merging two units into one produces a researcher with twice the
material and the same context — the report gets thinner in a way that looks like
brevity. Dropping a scope from every unit is invisible unless the grid is read
carefully. Cutting traces is the worst of the three, because the seams are where
unit-scoped researchers were already blind.

So the ceiling degrades along exactly one axis — tier, lowest first — and when
that axis is exhausted it stops and hands the decision back with numbers
attached. The caller can raise the ceiling, narrow the scopes, or regroup the
units. All three are fine. All three are *chosen*, which is the point.

## Why cross-cutting agents are mandatory in every preset

A unit-scoped researcher has exactly one blind spot, and it is structural rather
than a matter of diligence — it cannot see what happens on the other side of its
boundary, because that is another agent's cell and it was told not to widen. Ask
twenty such researchers and you get twenty good accounts and zero coverage of the
places they connect, which in most material is where the defects are. A term
redefined three sections later, a claim four sources all inherit from one
unverified origin, an API whose caller and callee disagree about whether a field
is optional — none of these appear in any single unit's findings, and all of them
appear in a trace.

This is why `traces` has a floor of three rather than being proportional. Even a
four-unit investigation has seams, and proportional-only would have given it one.

## Why full findings never travel through context

This is the constraint that makes the fan-out scale, and it is the one most
likely to be "simplified" away, because returning findings directly is obviously
simpler and works fine at four agents.

At twenty it does not work at all. Twenty researchers returning real findings is
a payload that fills the orchestrator's context, and the orchestrator is also the
thing that has to reason about the result. What happens next is well documented
and hard to see from the outside — the model starts compressing. It summarises
the summaries. The first thing compression discards is exactly what the
investigation was for — the specific path, the line number, the exact quote —
because specifics are long and themes are short. The output reads *better* after
this happens. It is fluent, well-organised, and unusable, because nothing in it
can be located.

Writing to disk breaks the coupling between how much was found and how much is in
context. Twenty researchers produce twenty files of any size and twenty abstracts
of 120 words. The abstracts route; the files hold. A tier-1 synthesizer opens the
four files for its unit and has room to think about them. The global synthesizer
reads `_meta/` only — a dozen short files — and has room to write.

The 120-word abstract is a hard number for a reason. "Keep it brief" is not a
constraint, it is a preference, and twenty agents interpreting a preference
produces an unbounded payload. A stated limit is checkable and produces a
predictable total.

**The global synthesizer's exclusion from `_raw/` is part of the same mechanism.**
It could open those files. If it may, it will, and the collapse happens in the
last phase where nothing downstream can catch it.

## Why synthesis is layered rather than single

One synthesizer over twenty researchers hits the same wall from the other side.
Three levels each read a bounded amount — one unit's files, the traces plus the
unit summaries, the `_meta/` directory — and each produces something the next
level can hold. The tree is what keeps every reader inside its budget.

The integration level is separate from the global level on purpose. Seam analysis
needs the traces *and* the unit summaries together, which is the largest read on
the run. Folding it into the global synthesizer would force the one agent writing
the deliverables to also do the heaviest reading.

## Why contradictions are resolved at the source

A synthesizer holding two conflicting findings has three options — check, pick, or
blend. Picking and blending both produce clean prose, and both are guesses
presented as conclusions. Blending is worse, because the result is a sentence
nobody wrote and no source supports.

So the instruction is to reopen the primary source and name the file opened, and
to mark what cannot be settled as OPEN with both sides intact. An open
contradiction carried into the deliverable is a real finding. Two researchers
disagreeing about a shared thing usually means the thing genuinely is ambiguous,
which is often the most valuable output of the entire run.

## Why Phase 0 is allowed to cancel the run

A method that never declines is a method with no information in its acceptance. If
the survey finds one small unit, the fan-out cannot beat reading the material —
every synthesis layer can only lose detail the raw files already had. Cancelling
costs one agent and saves twenty, and the recommendation to skip is the highest
value-per-token output this skill produces.

Sunk cost is the pressure to resist. By the time Phase 0 returns, the run has been
announced and an agent has been spent. Spawning twenty more to justify one is the
failure mode, and it produces a worse answer than stopping.
