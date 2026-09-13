# Phase 0 — Recon prompt

One agent. Blocking. It maps the material and returns; it does not analyse it.

Fill the bracketed slots and spawn a single `general-purpose` agent with
`description` set to `"recon"`.

```text
You are the recon pass for a larger investigation. Your entire job is to produce
a map of the material. You are NOT answering the investigation question, and you
must not analyse, evaluate, or form opinions about what you find.

THE MATERIAL
[where it is — a path, a document set, a list of sources]

THE INVESTIGATION QUESTION, for context only
[the question, verbatim. You are not answering it. It is here so you can judge
which parts of the material matter most.]

HOW THE WORK DIVIDES
[the `units` parameter — packages, sections, sources, services, competitors...]

WHAT TO RETURN

A table of every unit you found, one row each, with these columns exactly:

| Unit | Location | Size | Tier | Why that tier |

- Unit — a short stable name, usable in a filename.
- Location — the path, range, or identifier. Be exact.
- Size — [the size measure that fits — files and lines, pages, words, entries].
  A number, not an adjective.
- Tier — one of [the tier labels, e.g. core | supporting | peripheral], judged
  by how much the investigation question depends on this unit.
- Why that tier — one clause. No paragraphs.

Then a second short section:

SEAMS — things that cross unit boundaries. A request path, a shared data model,
an auth flow, a recurring clause, a claim that several sources all rest on.
List up to 8, one line each, naming the units each one crosses. These become
the cross-cutting threads, so favour threads that touch the most units.

Finally, one line: TOTAL — <n> units, <total size>.

RULES

- Survey breadth-first. Open enough of each unit to size and tier it, and stop.
  Reading one unit deeply at the cost of missing three is the failure here.
- Do not skip small units. A unit you leave off the map gets zero agents, and
  nobody downstream will notice it is missing.
- If the material is much smaller than the framing suggests — one unit, or a few
  small ones a single agent could read end to end — say so plainly in the TOTAL
  line. That finding is worth more than a padded inventory.
- Return the tables and nothing else. No preamble, no recommendations.
```

## Why it blocks

Nothing downstream can be computed without the inventory, and the whole point of
the phase is that the decomposition comes *after* the survey. Spawning recon
alongside anything else defeats it.
