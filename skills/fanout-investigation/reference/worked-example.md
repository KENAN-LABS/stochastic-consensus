# Worked example — the rule at both extremes

Four dry runs of Phase 1. No agents were spawned for these; they exist so a
maintainer can check the arithmetic against the rule and see what it does when
pushed. Every number here is reproducible from `SKILL.md` alone.

Recall the rule:

```text
scopes_for(tier)  =  core → every scope · supporting → first 3 · peripheral → first 1
researchers       =  Σ scopes_for(tier(unit))
traces            =  max(3, ceil(units / 4))
total             =  researchers + traces
floor 5 (researchers only) · ceiling 24 (total)
```

---

## A. Typical — six units, ceiling clipped by one

`codebase` preset. Seven scopes. Phase 0 returned six units.

| Unit | Tier | Size |
|---|---|---|
| api-core | core | 18,400 lines |
| billing | core | 6,100 lines |
| web-client | supporting | 24,800 lines |
| mobile | supporting | 31,200 lines |
| shared-types | peripheral | 2,300 lines |
| tooling | peripheral | 4,900 lines |

```text
researchers = 7 + 7 + 3 + 3 + 1 + 1  = 22
traces      = max(3, ceil(6/4)) = max(3, 2) = 3
total       = 25          → over the ceiling of 24 by one
```

Reduction. Demotable units are the two `supporting` ones — `core` is excluded and
the two `peripheral` units are already at one scope. Both hold three scopes, so
the tie breaks on smallest size and `web-client` (24,800) goes before `mobile`
(31,200).

```text
web-client  supporting → peripheral   (3 scopes → 1, saves 2)
researchers = 20 · traces = 3 · total = 23
```

**Final matrix — 20 researchers, 3 traces, 23 agents.**

| Unit | Tier | Scopes | # |
|---|---|---|---|
| api-core | core | cartography, stack, architecture, runtime, config, security, quality | 7 |
| billing | core | cartography, stack, architecture, runtime, config, security, quality | 7 |
| mobile | supporting | cartography, stack, architecture | 3 |
| web-client | peripheral | cartography | 1 |
| shared-types | peripheral | cartography | 1 |
| tooling | peripheral | cartography | 1 |

Two things worth noticing.

**It lands on 23, not 24.** Demotion moves in steps of two, so a run that is over
by one ends up under by one. Closing that gap would mean dropping a single scope
from a single unit, which the rule forbids — and forbids for a reason, because
"drop one scope to fit" is available at every size and nothing downstream records
that it happened. Overshooting is the visible failure; under-using the budget by
one agent is the cheap one.

**The reduction is honest but blunt.** `web-client` is 24,800 lines and just lost
two thirds of its coverage to save two agents. The matrix print says so, on its
own line, which is the whole point — the reader can see the trade and raise the
ceiling to 25 if they disagree. A rule that quietly merged `shared-types` into
`api-core` would have hit 24 with nobody the wiser.

---

## B. Floor — three sources, rule under-produces

`research` preset. Four scopes. Phase 0 returned three sources and tiered all
three `peripheral` — none is load-bearing for the question, though none is small.

| Unit | Tier | Size |
|---|---|---|
| vendor-whitepaper | peripheral | 42 pages |
| analyst-note | peripheral | 18 pages |
| conference-talk | peripheral | 31 pages, transcript |

```text
researchers = 1 + 1 + 1 = 3        → under the floor of 5
```

Promote the largest non-`core` unit one tier, largest first.

```text
vendor-whitepaper  peripheral → supporting   (1 scope → 3, adds 2)
researchers = 5    → floor met, stop
traces      = max(3, ceil(3/4)) = max(3, 1) = 3
total       = 8
```

**Final matrix — 5 researchers, 3 traces, 8 agents.**

Note what the floor did *not* do. It did not add a fourth unit, invent a scope,
or count the three traces toward itself. Traces are excluded from the floor
deliberately — otherwise a run could satisfy it entirely with cross-cutting
agents and never cover a single source in depth, which inverts the design.

Note also that `traces` is 3 here because of its own floor, not because of the
unit count. Three sources have seams — a number all three quote, a claim two
inherit from the same origin — and proportional-only would have given this run
one trace agent and missed them.

---

## C. Ceiling exhausted — fourteen units, the rule refuses

`codebase` preset. Seven scopes. Phase 0 returned fourteen units — 5 `core`,
5 `supporting`, 4 `peripheral`.

```text
researchers = (5 × 7) + (5 × 3) + (4 × 1) = 35 + 15 + 4 = 54
traces      = max(3, ceil(14/4)) = max(3, 4) = 4
total       = 58          → over the ceiling of 24 by 34
```

Reduction demotes the five `supporting` units one at a time, smallest first, each
saving two.

```text
after 5 demotions: researchers = 44 · traces = 4 · total = 48
demotable units remaining: none
  — the 5 core units are excluded
  — the 9 peripheral units are at one scope
48 > 24, and every remaining move is a rule violation
```

So the skill **stops and reports**, naming what it would have to break — merge
units, cut a `core` scope, or drop traces — and hands back the levers with their
arithmetic:

| Lever | Recomputed | Fits 24 |
|---|---|---|
| Raise the ceiling to 48 | 44 researchers + 4 traces = **48** | n/a |
| Narrow `scopes` from 7 to 4 | 29 researchers + 4 traces = **33** | no |
| Regroup 14 units into 7 domains | 25 researchers + 3 traces = **28** | no |
| Both — 7 domains at 4 scopes | 20 researchers + 3 traces = **23** | **yes** |

The regrouped rows assume 7 domains tiered 3 `core` · 2 `supporting` · 2
`peripheral`, which is what the fourteen units collapse to when grouped by
domain rather than by directory.

That last row is the one that fits, and it is a genuine choice with a genuine
cost — half the analysis dimensions and coarser units. The caller makes it. What
the skill must never do is pick one of these silently, because all four produce a
report that looks identical from the outside.

The reduction ordering matters here too. Demoting `supporting` before touching
anything else means the five units the investigation depends on most keep all
seven scopes through a 58 → 48 reduction. The budget is taken from the least
important work first, every time, by construction rather than by intention.

---

## D. The rule cannot detect a small job — Phase 0 has to

`codebase` preset. Phase 0 returned **one** unit, 340 lines.

```text
researchers = 7 · traces = max(3, ceil(1/4)) = 3 · total = 10
```

The rule cheerfully produces **ten agents for a 340-line file**, and it is not
wrong to — it is arithmetic, and 1 unit × 7 scopes is 7. Nothing in the rule
knows what "small" means.

This is why the degrade-gracefully check lives on the **inventory**, before Phase
1 runs, and not on the number that comes out of it. Phase 0 returns one small
unit, the skill says so and recommends skipping the fan-out, and the rule is
never evaluated.

Getting this backwards — checking the agent count for reasonableness after
computing it — reintroduces exactly the judgement call the derived rule exists to
remove, and reintroduces it at the worst moment, when a run has been announced
and an agent has already been spent.

---

## Checking the rule yourself

```text
A  22 → 25 total → one demotion → 23     ceiling clipped, visibly
B   3 → under floor → one promotion → 5  floor met without traces
C  54 → 58 total → five demotions → 48   refuses, hands back four levers
D   7 → 10 total                          arithmetic is fine, the job is not
```

If a change to `SKILL.md` moves any of these four numbers, that is the change
being load-bearing — check it was meant to be.
