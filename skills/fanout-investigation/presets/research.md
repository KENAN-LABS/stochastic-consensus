# Preset — research

For surveying many sources or subjects — a literature pass, a competitive
landscape, a due-diligence read across many documents from many origins.

```yaml
units:  sources, or subjects (one competitor, one paper, one vendor, one market)
scopes: [claims, evidence, contradictions, gaps]
tiers:  core 4 · supporting 3 · peripheral 1
floor:  5
ceiling: 24
traces: max(3, ceil(units / 4))
output_dir: .investigation/
```

Note `core` is 4, not 7 — it is *every scope in the list*, and this list has four.

| Scope | What the researcher covers |
|---|---|
| `claims` | what this source actually asserts, stated precisely enough to check, each with its exact location |
| `evidence` | what backs each claim — data, method, sample, citation — and how far it actually carries. Grade it, do not restate it |
| `contradictions` | where this source disagrees with itself, or with a source it cites |
| `gaps` | what it conspicuously does not address, and whether the omission looks deliberate |

`claims` first for a reason. A demoted source still gets its claims extracted,
which is the minimum needed for the cross-source traces to have anything to work
with.

## Tiering in Phase 0

By how load-bearing the source is for the question — a primary source the others
cite is `core` even when short; a blog post summarising it is `peripheral` even
when long.

## Threads worth tracing

A claim that several sources all rest on, traced back to whoever first made it ·
a number that appears in many places, traced to its origin · a disagreement
between two camps, traced through everyone who takes a side · a method reused
across studies.

Provenance is the whole game in this preset. Unit-scoped researchers read one
source each and cannot see that four sources trace to one unverified origin —
that is a trace agent's finding, every time.

## Overrides that come up

- A survey of one subject across many sources inverts the axes — make `units` the
  sub-questions and have each researcher sweep all sources for one of them.
- Add `methodology` as a fifth scope for empirical material.
- Say explicitly whether researchers may fetch. "Sources" often means URLs, and
  reaching the network is a decision the caller makes, not the skill.
