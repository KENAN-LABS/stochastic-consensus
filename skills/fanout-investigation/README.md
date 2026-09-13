# fanout-investigation

Orchestration for investigations too large for one agent to hold. It surveys the
material before deciding how to split it, computes the agent count from the
survey instead of guessing, runs researchers in parallel, keeps their findings on
disk rather than in context, and reduces the result through three layers of
synthesis with a coverage audit at the end.

It governs **process only**. It does not assume the material is code, does not
assume the work is read-only, and does not prescribe what the deliverable says.
The caller specifies all three.

## What it prevents

Two failure modes, both invisible in the output:

**Under-decomposition.** Asked how many agents a job needs, a model answers from
the framing rather than the material and reliably lowballs — two or three where
twenty were needed. The resulting report is well-organised and silent about
everything nobody was assigned to. Fixed by a blocking recon phase and an
arithmetic rule, so the count is derived from an enumeration made *after* reading.

**Synthesis collapse.** Many researchers reporting into one context fills it, and
the synthesizer starts summarising summaries. Specific, citable detail is the
first thing compression discards, and the output reads better afterwards. Fixed
by routing paths instead of prose — full findings go to `_raw/`, researchers
return 120-word abstracts, and the global synthesizer is fenced off from `_raw/`
entirely.

Both mechanisms are argued at length in `reference/rationale.md`. Read it before
simplifying either.

## When it fires

On large, multi-part investigations — auditing or mapping a whole codebase or
monorepo, reviewing a document or contract set, surveying many competitors or
sources — and on requests phrased as *go deep on everything*, *full audit*, *map
the entire system*, *leave nothing out*. Also when a first pass has already shown
the material is bigger than expected.

## When it must not fire

A single file or function. A small diff. A bug with a known reproduction.
Anything one grep or one test settles. Any question whose answer fits in one
agent's context. This skill spends many agents and many minutes, so firing it on
a small question is a worse failure than not firing at all.

It is also not the tool for sampling **one** question many times to see how often
answers recur — that is `stochastic-consensus`, the sibling skill in this plugin.
The split is clean:

| | Agents differ by | Merged by |
|---|---|---|
| `fanout-investigation` | slice of the material | coverage |
| `stochastic-consensus` | lens on one question | recurrence |

## Invoking it

Plain language is enough; the skill triggers on shape, not on keywords.

```text
Audit this monorepo end to end — every package, and I want the seams between
them covered too.

Review this contract pack in full. Fourteen documents, and I care most about
anything that creates an obligation we can't get out of.

Survey the competitive landscape for X. Nine vendors, and I want to know which
claims they're all copying from each other.
```

### With a preset

```text
Investigate this repo using the codebase preset, but skip the security scope —
we did that separately last month.

Use the research preset over the sources in ./sources. Tier by how much the
pricing question depends on each one, not by length.

Document-review preset over ./contracts, with a ceiling of 16 — I don't want to
spend more than that today.
```

Presets are starting points, not menus. Every field is overridable and a preset
that does not fit the material should be changed rather than followed.

| Preset | Units | Scopes |
|---|---|---|
| `presets/codebase.md` | packages, workspaces, services | cartography, stack, architecture, runtime, config, security, quality |
| `presets/research.md` | sources or subjects | claims, evidence, contradictions, gaps |
| `presets/document-review.md` | sections or documents | content, consistency, risk, open-questions |

### Overriding parameters

State them in the request. Anything unstated takes the default.

| Parameter | Default | Say something like |
|---|---|---|
| `units` | from the preset | *split by domain, not by directory* |
| `scopes` | from the preset | *just architecture and security* |
| `tiers` | core 7 · supporting 3 · peripheral 1 | *give supporting units 5 scopes* |
| `floor` | 5 researchers | *at least 8 researchers* |
| `ceiling` | 24 agents | *cap it at 12* |
| `traces` | `max(3, ceil(units / 4))` | *trace 5 threads, here they are* |
| `approval_gate` | on above 12 agents | *don't stop to ask, just run it* |
| `output_dir` | `.investigation/` | *write to ./audit-2026-09/* |

Two things the skill never infers, so say them when they matter — whether
researchers may **write** anything outside `output_dir`, and what the material
**is** if it is not obvious from the path.

## What you get

```text
<output_dir>/
  _meta/inventory.md       what Phase 0 found
  _meta/matrix.md          the derived matrix, with every reduction shown
  _raw/<unit>--<scope>.md  full findings, one per matrix cell
  _raw/trace--<thread>.md  full findings, one per cross-cutting thread
  _meta/<unit>.md          per-unit synthesis
  _meta/integration.md     the seams
  _meta/coverage.md        unit × scope grid, every cell accounted for
  <deliverables>           whatever you asked for
```

The report names five numbers — agents launched, agents **returned**, cells
covered, cells `N/A`, threads traced — and includes the coverage grid. An empty
cell in that grid is a gap, and gaps get filled or justified, never shipped blank.

## If the material turns out to be small

Phase 0 is allowed to cancel the run, and should. One unit, or a handful a single
agent could read end to end, and the skill says so and recommends skipping the
fan-out rather than spawning agents to justify having started. That costs one
agent and saves twenty.

## Files

```text
SKILL.md                      the procedure — loaded whenever the skill triggers
presets/*.md                  three starting configurations
templates/recon.md            Phase 0 prompt and the inventory schema
templates/researcher.md       unit-scoped and cross-cutting prompts
templates/synthesizer.md      tier-1, integration, and global prompts
templates/coverage.md         the audit grid and its rules
reference/rationale.md        why the rule is arithmetic, why disk is not optional
reference/worked-example.md   the rule dry-run at four sizes, with the numbers
```
