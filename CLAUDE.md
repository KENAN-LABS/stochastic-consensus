# CLAUDE.md — stochastic-consensus

A Claude Code plugin holding **two** fan-out/fan-in skills. The deliverable is prose that
changes a model's behaviour (`skills/*/SKILL.md`) plus an eval suite that proves it did. There
is no runtime code, no dependencies, no build.

| Skill | Agents differ by | Merged by |
|---|---|---|
| `stochastic-consensus` | lens on **one question** | recurrence |
| `fanout-investigation` | slice of **one corpus** | coverage |

## Before changing a skill

Read `CONTRIBUTING.md` first. Three harness findings documented there will otherwise cost you
an afternoon:

- `allowed_tools` does not gate the `Agent` tool, and there is no `disallowed_tools` key.
- An `llm` grader with `focus: trace` is **truncated** to the first and last 12 messages. A
  `regex` on `target: trace` is not, but it bridges across unrelated messages. Assert against
  the calls with `tool_used` + `input_match`.
- Never suppress the mechanism a case is testing. A case that disables subagents and then
  grades that the skill fired measures nothing, and fails in the direction that looks like a
  real regression.

The skills' value rests on these behaviours. If you edit a `SKILL.md`, re-run its cases:

| Skill | Behaviour | Case |
|---|---|---|
| `stochastic-consensus` | Never fabricates agent counts | `reports-honestly-without-fanout` |
| `stochastic-consensus` | Declines when the answer is checkable | `declines-on-checkable-question` |
| `stochastic-consensus` | Lenses actually decorrelate | `decorrelates-lenses` |
| `fanout-investigation` | Derives the count and prints the matrix | `investigation-derives-the-matrix` |
| `fanout-investigation` | Declines material too small to warrant a fan-out | `investigation-degrades-on-single-unit` |
| `fanout-investigation` | Keeps findings on disk through a real fan-out | `investigation-full-fanout` |
| both | The two skills do not poach each other's work | `consensus-not-investigation` |

```bash
# cheap tier — no fan-out. This is what CI runs.
claude plugin eval . --tag integrity --tag negative --runs 1 --ablation none   # ~$2, ~4 min

# real subagent swarms
claude plugin eval . --tag fanout --runs 1 --ablation none --concurrency 2 \
  --scaffold --allow-tools Write Edit                                         # ~$7, ~30 min
```

> `--scaffold --allow-tools Write Edit` is **required** on the fan-out tier and is not implied
> by `--trust-plugin`. `investigation-full-fanout` builds its own fixture with a
> `scaffold_script`, and its researchers write to `_raw/`. Without those flags the case runs
> against an empty workspace and every file grader fails — which reads as a skill regression
> rather than a missing flag.

CI runs only the first line. A regression in lens decorrelation, convergent tallying, or the
fan-out's disk discipline ships unless you run the second yourself.

## Releasing

Bump the version in **four** places — `.claude-plugin/plugin.json`, *both* fields in
`.claude-plugin/marketplace.json`, and the newest `## [x.y.z]` heading in `CHANGELOG.md`. They
are read separately and disagree silently; CI fails the PR when they do. Move the
`## [Unreleased]` entries under the new heading, update the link definitions at the bottom of
`CHANGELOG.md`, then tag and release:

```bash
git tag -a v0.3.0 -F - <<'MSG'   # a real message: gh uses it as the release body
v0.3.0 — what changed
MSG
git push origin main && git push origin v0.3.0
gh release create v0.3.0 --notes-from-tag
```

Tagging matters beyond bookkeeping: `/plugin marketplace add` resolves the default branch, so
a tag is the only thing an installer can pin to.
