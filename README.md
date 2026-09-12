# Stochastic Consensus

A Claude Code skill for **multi-agent consensus**: fan out independent subagents
that each sample candidate answers, then merge the pool and rank ideas by how
often they recurred *independently*.

One prompt gives you one trajectory through the model's distribution — usually a
safe, central one. This runs many isolated trajectories and reports what they
agreed on, which buys you two things a single answer cannot provide:

- **Coverage** — the union of many isolated samples is far wider than any one
- **Recurrence** — "reached independently by 7 of 8 agents" is a confidence
  signal you can act on

## Install

```
/plugin marketplace add KENAN-LABS/stochastic-consensus
/plugin install stochastic-consensus
```

Or point Claude Code at a local clone:

```
/plugin marketplace add /path/to/stochastic-consensus
```

## Use

The skill triggers on its own when a request calls for breadth or cross-checking.
You can also invoke it directly:

```
/stochastic-consensus what are all the ways we could cut our AWS bill?
```

Requests that trigger it:

| You say | Mode | You get |
|---|---|---|
| "every way we could reduce onboarding drop-off" | Divergent | Grouped union list, recurrence counts, long tail preserved |
| "which of these three should we pick, and how sure are we?" | Convergent | One winner, X/N tally, dissent, confidence |
| "what am I missing before we launch?" | Divergent | Coverage sweep across independently-derived lenses |
| "pressure-test this migration plan" | Convergent | Adversarial stances, failure modes, premise check |

## The two modes

Conflating these is what makes naive fan-out implementations useless — they need
opposite synthesis rules.

**Divergent (union)** — goal is *coverage*. Nothing is voted out. Rarity is
interesting, not disqualifying. Singletons are preserved and marked, because the
long tail is exactly what you paid N × M samples to reach.

**Convergent (voting)** — goal is *reliability*. Agents rotate **stance** (for,
against, failure-hunter, premise-checker) rather than topic, then commit to one
answer each so the results can actually be tallied.

## How it avoids the obvious trap

Five agents given the same prompt return five overlapping lists — 5× the cost for
roughly 1.2× the coverage. The skill requires each agent receive a distinct
**lens**, derived from the dimensions the answer space actually varies along
(sub-discipline, mechanism, constraint, scale, time horizon, failure
orientation).

The test it applies: *if you cannot predict that two agents holding different
lenses would produce nearly disjoint lists, the lenses are too close together and
you are paying for redundancy.*

## Cost

Generator agents run ~40–50k tokens each.

| Run | Agents | Pool | Rough cost |
|---|---|---|---|
| Quick cross-check | 3 | ~15 | ~120k tokens |
| Typical decision or brainstorm | 5 | ~50 | ~200k tokens |
| Exhaustive sweep | 8 | ~100+ | ~350k tokens |

The skill states N, M, and the lenses before spawning so you can stop it, and
confirms first when a large run was not clearly invited.

## Reporting integrity

The output of this method is a set of numbers that look like evidence, which
makes fabricating them uniquely harmful — a reader cannot distinguish an invented
"7/8 agreed" from a real one. The skill therefore requires:

- Never report agents that were not spawned
- Report the N that *returned*, not the N launched (failures are stated)
- Recurrence counts come from actual merging, never estimation
- If the fan-out fails, answer directly **and say the fan-out failed** — never
  degrade silently while keeping the consensus framing

## When not to use it

Breadth and confidence at N × M cost is a bad trade for single-fact lookups,
anything with one verifiable answer, file edits, or decisions already made. If a
question has a checkable answer, checking beats voting — one test run outranks
ten confident agents. The skill will say so rather than spend your tokens.

## Tested

Six eval cases, all passing with unanimous judge votes (`claude plugin eval`,
Claude Code 2.1.269):

| Case | Result | What it proves |
|---|---|---|
| `triggers-on-explicit-request` | 3/3 | Fans out on an explicit request; divergent output with lenses and recurrence counts |
| `triggers-without-technique-named` | 3/3 | Triggers on intent alone — the prompt never says consensus, agents, or vote |
| `selects-convergent-mode` | 3/3 | Picks voting mode; produces an X/N tally, dissent, and confidence |
| `decorrelates-lenses` | 3/3 | Lenses genuinely decorrelate — 9 agents, ~140 samples, 108 distinct after merging |
| `declines-on-checkable-question` | 3/3 | Refuses to vote on something running the tests would settle |
| `reports-honestly-without-fanout` | 3/3 | Will not fabricate agent counts when subagents are unavailable and it is explicitly asked for them |

The last case is the one to care about. It demands "6 agents and the recurrence
counts" in an environment where no subagent can run — maximum incentive to
produce plausible numbers. Execution traces confirm zero `Agent` calls and no
invented statistics.

Reproduce:

```bash
claude plugin eval . --tag integrity --tag negative --runs 1 --ablation none   # ~$0.40, ~1 min
claude plugin eval . --tag fanout --runs 1 --ablation none --concurrency 2     # ~$6, ~12 min
```

## Contents

```
skills/stochastic-consensus/
├── SKILL.md                        the five-step method
└── references/
    ├── generator-prompt.md         subagent prompt templates, both modes
    ├── worked-example.md           a full convergent run, start to finish
    └── failure-modes.md            six failure modes and their fixes
evals/<case>/prompt.md              6 eval cases
evals/<case>/graders/criteria.md    their graders
.claude-plugin/plugin.json          plugin manifest
.claude-plugin/marketplace.json     makes this repo installable as a marketplace
```

No executable code ships — no scripts, hooks, MCP servers, or dependencies. See
[SECURITY.md](SECURITY.md).

## Development

Run the eval suite:

```bash
claude plugin eval .                    # all cases
claude plugin eval . --tag triggering   # one group
claude plugin eval . --runs 1           # cheap smoke pass
```

Cases live in `evals/<case-name>/prompt.md` with graders in
`evals/<case-name>/graders/*.md`.

## License

MIT — see [LICENSE](LICENSE).
