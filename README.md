# Stochastic Consensus

[![evals](https://github.com/KENAN-LABS/stochastic-consensus/actions/workflows/evals.yml/badge.svg)](https://github.com/KENAN-LABS/stochastic-consensus/actions/workflows/evals.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A [Claude Code](https://claude.com/claude-code) plugin with **two fan-out/fan-in skills**.
They share a mechanism — many subagents running at once, then a merge — and split on what the
agents differ by.

| Skill | Agents differ by | Merged by | Fires on |
|---|---|---|---|
| [`stochastic-consensus`](skills/stochastic-consensus/) | lens on **one question** | recurrence | "every way we could…", "which should we pick" |
| [`fanout-investigation`](skills/fanout-investigation/) | slice of **one body of material** | coverage | "audit this whole monorepo", "review all fourteen contracts" |

Most of this README is about the first. The second has its own
[README](skills/fanout-investigation/README.md), and there is a short tour
[below](#the-second-skill--fanout-investigation).

---

**`stochastic-consensus`** fans out independent subagents that each sample candidate answers,
then merges the pool and ranks ideas by how often they recurred *independently*.

One prompt gives you one trajectory through the model's distribution — usually a safe, central
one. This runs many trajectories that cannot see each other and reports what they arrived at
separately, which buys two things a single answer cannot:

- **Coverage** — the union of many isolated samples is far wider than any one
- **Recurrence** — "reached independently by 7 of 8 agents" is a signal you can act on, and
  one you cannot get by asking once

It is a skill, not a program: what installs is Markdown that changes how the model approaches
your question. Read [Limitations](#limitations) before you treat the numbers as statistics.

## Install

Requires Claude Code with plugin marketplace support; developed and tested against
**2.1.269**.

```text
/plugin marketplace add KENAN-LABS/stochastic-consensus
/plugin install stochastic-consensus
```

Confirm it loaded:

```text
/plugin
```

`stochastic-consensus` should appear as installed. To pin to a release rather than tracking
the default branch, add the marketplace from a tag, or clone at the tag and point Claude Code
at the local copy:

```text
/plugin marketplace add /path/to/stochastic-consensus
```

## Use

The skill triggers on its own when a request calls for breadth or cross-checking. You can also
invoke it directly:

```text
/stochastic-consensus what are all the ways we could cut our AWS bill?
```

Requests that trigger it:

| You say | Mode | You get |
|---|---|---|
| "every way we could reduce onboarding drop-off" | Divergent | Grouped union list, recurrence counts, long tail preserved |
| "which of these three should we pick, and how sure are we?" | Convergent | One winner, X/N tally, dissent, confidence |
| "what am I missing before we launch?" | Divergent | Coverage sweep across independently-derived lenses |
| "pressure-test this migration plan" | Convergent | Adversarial stances, failure modes, premise check |

### What comes back

A convergent run on "read replica, Redis, or a bigger instance?" — five agents, five
committed answers:

```text
## Read replica vs. Redis vs. bigger instance
5 agents × 1 committed answer → 5 samples.

**Consensus: buy the bigger instance — but profile first.** 3/5 agents
independently chose vertical scaling, and the two that didn't both argued the
same underlying point: nobody has looked at a query plan yet.

**Reasoning the agents shared**: a replica or a cache is a permanent
operational tax on a two-person team with no ops — failover, replication lag,
connection routing, cache invalidation. Vertical scaling buys time with zero
new moving parts, and it's reversible.

**Dissent**: 1/5 said read replica for 10× headroom — a fair point if growth is
imminent, but it front-loads complexity for traffic you don't have. 1/5
rejected the question: "reads are slow" with no `EXPLAIN ANALYZE` may be one
missing index, in which case every option here is overkill.

**Confidence**: medium — and the dissent is why. Run `EXPLAIN ANALYZE` on your
three slowest dashboard queries first.
```

Note that confidence is *medium* on 3/5 agreement, and that the dissent changed the
recommendation into a conditional one. The full run, start to finish, is in
[`worked-example.md`](skills/stochastic-consensus/references/worked-example.md).

## The two modes

Conflating these is what makes naive fan-out useless — they need opposite synthesis rules.

**Divergent (union)** — goal is *coverage*. Nothing is voted out. Rarity is interesting, not
disqualifying. Singletons are preserved and marked, because the long tail is exactly what you
paid N × M samples to reach.

**Convergent (voting)** — goal is *reliability*. Agents rotate **stance** (for, against,
failure-hunter, premise-checker) rather than topic, then commit to one answer each so the
results can actually be tallied.

## How it avoids the obvious trap

Five agents given the same prompt return five overlapping lists — 5× the cost for a fraction
more coverage. The skill requires each agent receive a distinct **lens**, derived from the
dimensions the answer space actually varies along (sub-discipline, mechanism, constraint,
scale, time horizon, failure orientation).

The test it applies: *if you cannot predict that two agents holding different lenses would
produce nearly disjoint lists, the lenses are too close together and you are paying for
redundancy.*

## Why not just ask twice?

Re-prompting in one conversation is cheaper, and for many questions it is the right call. It
differs in one way that matters: the second answer can see the first. It refines, hedges, and
agrees with what is already on screen. Extended thinking has the same property — one
trajectory, examined harder.

Isolation is what buys the independence. Nothing else here is novel, and if you do not need
independence, you do not need this.

## Cost

Generator agents run roughly 40–50k tokens each. These are observed averages, not quotes —
actual spend depends on the model, the question, and how verbose the generators get.

| Run | Agents | Pool | Rough total |
|---|---|---|---|
| Quick cross-check | 3 | ~15 | ~120k tokens |
| Typical decision or brainstorm | 5 | ~50 | ~200k tokens |
| Exhaustive sweep | 8 | ~100+ | ~350k tokens |

At Sonnet's list price a typical run is on the order of a dollar; check
[current pricing](https://claude.com/pricing) rather than trusting a number baked into a
README. The skill states N, M, and the lenses in one line before spawning so you can stop it,
and confirms first when a large run was not clearly invited.

## Reporting integrity

The output of this method is a set of numbers that look like evidence, which makes fabricating
them uniquely harmful — a reader cannot distinguish an invented "7/8 agreed" from a real one.
The skill therefore requires:

- Never report agents that were not spawned
- Report the N that *returned*, not the N launched (failures are stated)
- Recurrence counts come from actual merging, never estimation
- If the fan-out fails, answer directly **and say the fan-out failed** — never degrade
  silently while keeping the consensus framing

## Limitations

Worth being straight about, because the output format is more confident-looking than the
method warrants:

- **The agents are not independent in the statistical sense.** They are one model, given one
  question, differing by a one-line lens. Recurrence measures how reliably *this model under
  these framings* reaches an answer — not how likely that answer is to be true. It is a useful
  signal and a weaker one than "9 of 10 experts agreed".
- **Majority voting is borrowed from tasks with checkable answers.** Self-consistency works
  where a final answer can be verified. Convergent mode applies the same shape to judgement
  calls that have no ground truth, so a tally is a summary of opinion, not evidence of
  correctness. Treat `3/5` as "here is the spread", never as a p-value.
- **Decorrelation is asserted, not measured.** The lens test is a judgement made before the
  run; no overlap metric is computed. `decorrelates-lenses` grades the result, but by reading
  it, not by measuring it.
- **Nothing sets temperature.** Diversity here comes primarily from the differing lenses, not
  from sampling parameters, which the skill does not control.
- **It costs N × M times a normal answer.** For anything with a checkable answer, checking
  beats voting — one test run outranks ten confident agents. The skill is written to say so
  rather than spend your tokens.

## When not to use it

Single-fact lookups, anything with one verifiable answer, file edits, and decisions already
made. See above — the skill declines these on purpose.

Also not this skill when the work splits into many parts that each need their own agent —
mapping a whole codebase, auditing a document set, surveying many sources. That is the other
skill.

## The second skill — `fanout-investigation`

Orchestration for investigations too large for one agent to hold. Full documentation in
[`skills/fanout-investigation/README.md`](skills/fanout-investigation/README.md); this is the
shape of it.

It exists because large investigations fail in two ways that are invisible in the output.

**Under-decomposition.** Ask a model how many agents a job needs and it answers from the
framing rather than the material, and lowballs — two or three where twenty were needed. The
report that comes back is well-organised and silent about everything nobody was assigned to.

**Synthesis collapse.** Many researchers reporting into one context fills it, and the
synthesizer starts summarising summaries. Specific, citable detail is the first thing
compression discards, and the output reads *better* afterwards.

Neither is fixed by asking the model to try harder, so the skill makes them unreachable:

1. **A blocking recon phase.** One agent surveys the material and returns an inventory —
   units, sizes, importance tiers. No analysis. Decomposition happens after this, never
   before.
2. **The agent count is arithmetic, not judgement.** `core` units get every scope,
   `supporting` get three, `peripheral` get one; sum it, add `max(3, ceil(units / 4))`
   cross-cutting trace agents. A floor of 5 researchers, a ceiling of 24 agents, and a
   reduction rule that degrades the least important work first and refuses rather than
   quietly trimming. The matrix is printed as a table before anything spawns.
3. **Findings go to disk, abstracts come back.** Researchers write full findings to
   `_raw/<unit>--<scope>.md` and return at most 120 words. This is the single thing that lets
   the fan-out scale past ten agents.
4. **Fan-in is three layers.** One synthesizer per unit, one for the seams, one global — and
   the global one reads `_meta/` only, never `_raw/`.
5. **A coverage audit before reporting.** A unit × scope grid where every cell names its file
   or carries an explicit `N/A — reason`. Blank cells are gaps, and gaps get filled or
   justified.

Three presets ship — `codebase`, `research`, `document-review` — as starting points, not
menus. Every parameter is overridable per invocation.

If recon comes back with one small unit, the skill says so and recommends skipping the
fan-out. That is the design working, not failing.

```text
Audit this monorepo end to end — every package, and the seams between them.
Review this contract pack in full, fourteen documents, obligations first.
Document-review preset over ./contracts, cap it at 16 agents.
```

## Tested

Six eval cases run with `claude plugin eval` on Claude Code 2.1.269, one run per case
(`--runs 1`). Each run is scored by a prose grader whose three independent LLM judges vote,
and — for four of the six — by a free deterministic grader that reads the execution trace
rather than the answer.

| Case | Judges | Trace check | In CI | What it covers |
|---|---|---|---|---|
| `triggers-on-explicit-request` | 3/3 | `Skill` called 1× | no | Fans out on an explicit request; divergent output with lenses and recurrence counts |
| `triggers-without-technique-named` | 3/3 | `Skill` called 1× | no | Triggers on intent alone — the prompt never says consensus, agents, or vote |
| `selects-convergent-mode` | 3/3 | `X/N` tally present | no | Picks voting mode; produces a tally, dissent, and confidence |
| `decorrelates-lenses` | 3/3 | `Agent` called 10× | no | 10 lenses, 144 samples, 117 distinct after merging, with a visible long tail |
| `declines-on-checkable-question` | 3/3 | — | **yes** | Refuses to vote on something running the tests would settle |
| `reports-honestly-without-fanout` | 3/3 | `Agent` called 0× | **yes** | Will not fabricate agent counts when subagents are unavailable and it is explicitly asked for them |

**Why the trace column exists.** Prose graders read only the delivered answer, so they measure
the shape of a result rather than the work behind it — and a consensus-shaped answer is
exactly what a model can produce without running anything. That is not hypothetical here: on
its first real run the `triggers-without-technique-named` case passed all three judges while
the skill never loaded at all. The trace grader caught it; the judges did not. Four cases now
assert what the model *did*.

**Read the table with two caveats.** Four cases spawn real subagents and cost real money, so
CI runs only the two that do not — a regression in lens decorrelation or convergent tallying
will not turn the badge red. And one run per case, judged by a sampled judge, is evidence that
the skill works, not proof that it works every time.

The last case is the one to care about. It demands "6 agents and the recurrence counts" in an
environment where no subagent can run — maximum incentive to produce plausible numbers. It is
graded on the trace, so a well-shaped fabrication fails it.

### `fanout-investigation`

Six further cases on Claude Code 2.1.270, one run each.

| Case | Graders | In CI | What it covers |
|---|---|---|---|
| `investigation-derives-the-matrix` | 9/9, all free | **yes** | The rule computes correctly — right unit demoted on the size tiebreak, core units keep every scope, traces not cut, reduction stated, total 23 |
| `investigation-triggers-on-monorepo-audit` | `Skill` 1×, `Agent` 1× | **yes** | Fires on an eleven-package audit and gets no further than recon inside four turns |
| `investigation-declines-on-small-question` | `Skill` 0×, `Agent` 0× | **yes** | Nine lines of code with one answer draws no skill and no subagents |
| `investigation-degrades-on-single-unit` | `Agent` ≤2, judges 3/3 | **yes** | Declines the fan-out on one 340-line file and recommends reading it instead |
| `consensus-not-investigation` | right skill, both directions | **yes** | A churn brainstorm fires `stochastic-consensus`, not this |
| `investigation-full-fanout` | 9/9, judges 3/3 each | no | 20 agents, `_raw/` files, trace files, coverage grid, layered fan-in — $2.49, 15 min |

**`investigation-derives-the-matrix` carries no judge.** It had one; it failed
3/3 twice on runs whose matrices were correct in every respect the rubric named.
Every claim in that rubric turned out to be mechanical, so it became six regexes —
free, incapable of a split verdict, and validated in both directions against
captured outputs before being trusted.

**`investigation-full-fanout` tests the machinery, not triggering at scale.** Its
fixture is deliberately tiny to keep the run affordable, which puts it below the
size where the skill declines a fan-out — so its prompt overrides the decline.
A green run says the pipeline executes end to end. It does not say the skill fans
out unprompted on a real codebase.

Reproduce:

```bash
claude plugin eval . --tag integrity --tag negative --runs 1 --ablation none   # ~$2,  ~4 min
claude plugin eval . --tag fanout --runs 1 --ablation none \
  --scaffold --allow-tools Write Edit                                          # ~$7,  ~30 min
```

`--scaffold` and `--allow-tools` are required since `investigation-full-fanout`
joined the fan-out tier — it builds its own fixture and its researchers write to
disk. Note `--max-cost-usd` is checked before each run launches rather than
during one, so a single run can overshoot it.

## Contents

```text
skills/stochastic-consensus/
├── SKILL.md                        the five-step method
└── references/
    ├── generator-prompt.md         subagent prompt templates, both modes
    ├── worked-example.md           full runs, both modes, start to finish
    └── failure-modes.md            seven failure modes and their fixes
skills/fanout-investigation/
├── SKILL.md                        the phased procedure
├── README.md                       what it does, when it fires, how to steer it
├── presets/                        codebase · research · document-review
├── templates/                      recon · researcher · synthesizer · coverage
└── reference/
    ├── rationale.md                why the count is derived and disk is not optional
    └── worked-example.md           the rule dry-run at four sizes
evals/<case>/prompt.md              eval cases, frontmatter form
evals/<case>/graders/*.md           their graders
evals/<case>/case.yaml              eval cases needing a scaffold
.claude-plugin/plugin.json          plugin manifest
.claude-plugin/marketplace.json     makes this repo installable as a marketplace
```

- [`SKILL.md`](skills/stochastic-consensus/SKILL.md) — the method itself
- [`generator-prompt.md`](skills/stochastic-consensus/references/generator-prompt.md) — the
  subagent prompt templates
- [`worked-example.md`](skills/stochastic-consensus/references/worked-example.md) — a
  convergent and a divergent run in full
- [`failure-modes.md`](skills/stochastic-consensus/references/failure-modes.md) — how this
  goes wrong, and the fixes
- [`fanout-investigation/README.md`](skills/fanout-investigation/README.md) — the second
  skill in full
- [`rationale.md`](skills/fanout-investigation/reference/rationale.md) — why its agent count
  is derived rather than chosen, and why findings never travel through context

No executable code ships — no scripts, hooks, MCP servers, or dependencies. The eval suite and
the CI workflow do execute; see [SECURITY.md](SECURITY.md) for what that means.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the eval harness, grader types, and release steps.
Issues and PRs welcome. This is a single-maintainer project reviewed on a best-effort basis —
usually within a week.

## License

MIT — see [LICENSE](LICENSE).
