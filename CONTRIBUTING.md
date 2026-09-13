# Contributing

## Layout

```text
.claude-plugin/plugin.json        plugin manifest (points evals at evals/)
.claude-plugin/marketplace.json   makes this repo installable as a marketplace
skills/stochastic-consensus/      consensus over one question, many lenses
skills/fanout-investigation/      investigation over one corpus, many slices
evals/<case>/prompt.md            eval case + frontmatter
evals/<case>/graders/*.md         graders for that case
evals/<case>/case.yaml            eval case needing keys frontmatter rejects
```

The plugin directory is named after the first skill because the plugin loader
derives `skills/<plugin name>/SKILL.md` from `plugin.json`'s `name`, and renaming
the plugin would break every existing install. A second skill directory alongside
it loads normally.

## Getting a change merged

1. Fork, then branch from `main`.
2. Make the change. The deliverable here is prose, so match the surrounding
   voice: second person, present tense, concrete over abstract, roughly 88-column
   wrap. `.editorconfig` covers the mechanical part.
3. Run the checks below. The free ones must pass; the paid ones are judgement.
4. Open a PR and fill in the template. It asks which evals you ran, because the
   reviewer cannot tell from the diff.

Reviews come from a single maintainer, best effort, usually within a week.

### Before you push

```bash
npx markdownlint-cli2 "**/*.md" "#node_modules"   # free, also runs in CI
claude plugin eval . --tag integrity --tag negative --runs 1 --ablation none
```

CI runs the markdown lint plus three structural checks — version agreement,
manifest shape, and eval-case completeness — on every PR including from forks.
The eval job needs `ANTHROPIC_API_KEY`, which GitHub does not expose to fork
PRs, so it is skipped there rather than failed. That is expected; you have not
broken anything.

## Running the evals

```bash
claude plugin eval .                                  # everything, default runs
claude plugin eval . --tag integrity --runs 1         # one group, cheap
claude plugin eval . --ablation none                  # skip the no-plugin arm
claude plugin eval . --keep-temp                      # preserve traces
```

Two knobs dominate cost:

- `--ablation none` skips the baseline arm and halves the run count. The default
  (`with-without`) is more informative — it reports Δ against no plugin — but
  costs twice as much.
- `--runs N` overrides each case's `runs:`. The harness default is `case.runs`,
  falling back to 3 when a case declares none. Use `--runs 1` while iterating.

Cases tagged `fanout` spawn real subagents. They are slow (several minutes) and
cost roughly $0.75–1.50 per run. Cases tagged `integrity` and `negative` do not
fan out and cost about $0.20. These are observed figures from runs on Claude
Code 2.1.269, not a guarantee — use `--max-cost-usd` if you need a hard ceiling.

### Traces contain your machine

`--keep-temp` preserves `trace.jsonl`, which holds the full prompt and response
stream plus local paths and environment details. It is gitignored. Scrub it
before attaching any of it to an issue or PR.

## Case frontmatter schema

A case is either `prompt.md` plus `graders/*.md`, or a single `case.yaml`. Use
`prompt.md` unless you need something it cannot express.

### `prompt.md` frontmatter

The accepted key set, verified against the 2.1.270 binary. An unknown key is an
error at load time.

```text
schema_version   name        description            tags
plugins          runs        expected_outcome
model            max_turns   timeout_seconds        env
allowed_tools    append_system_prompt   artifact_publish   growthbook_overrides
```

### `case.yaml`

Everything above plus the keys the flat form has no slot for, nested under
`context:` and `execution:`:

```yaml
schema_version: "1.0"
name: my-case
tags: [something]
runs: 1
context:
  scaffold_script: scaffold.sh   # bash, run in the case workspace
  history_file: ...              # seed conversation history
  add_dirs: []                   # extra directories the run may reach
execution:
  prompt: |
    ...
  max_turns: 90
  timeout_seconds: 2400
graders:
  - type: tool_used
    name: fanout-actually-happened
    tool: Agent
    min: 8
```

Graders move inline and each needs a `name`. Note `scaffold_script` and
`add_dirs` are **not** accepted in `prompt.md` frontmatter — that is the usual
reason to reach for `case.yaml`, and `investigation-full-fanout` is the example
in this suite.

**A scaffolded case needs `--scaffold`**, which is off by default and not implied
by `--trust-plugin`. Without it the harness warns and runs the case against an
empty workspace, where it fails for the wrong reason. If the case's agents write
files, it also needs `--allow-tools Write`.

```bash
claude plugin eval . --case 'investigation-full-fanout' \
  --scaffold --allow-tools Write Edit --runs 1 --ablation none
```

## Graders

Six grader types exist. Four are free and deterministic; two call a model and
cost money.

| Type | Cost | Required fields |
|---|---|---|
| `regex` | free | `pattern`, `target` (plus optional `flags`, `match`) |
| `tool_used` | free | `tool` (plus optional `input_match`, `min`, `max`) |
| `tool_order` | free | `before`, `after` |
| `file_exists` | free | `path` |
| `llm` | paid | `criteria` (plus optional `focus`) |
| `baseline` | paid | `baseline_file`, `criteria` |

Frontmatter is `type:` and `weight:`.

**Prefer a free grader wherever the claim is mechanical.** A tally in `X/N`
form, a `×n` recurrence marker, or the presence of an `Agent` call are all
checkable without a judge, and a deterministic check cannot return a 2–1 split.
Reserve `llm` for genuinely semantic criteria — "did it rotate stance rather
than topic" is not regexable.

### What a grader can see

`llm` graders take `focus:` and `regex` graders take `target:`. Both accept the
same values:

| Value | What it exposes |
|---|---|
| `last_message` | the delivered answer — **the default** |
| `trace` | the full execution trace, including tool calls |
| `files` | files the run touched |
| `{ source: file, path: <path> }` | one named file |
| `mock_calls` | recorded MCP mock invocations |

This matters here more than in most suites. A skill whose output is *numbers
that look like evidence* can produce a final message with a perfectly shaped
tally that no fan-out ever backed. Grading `last_message` proves the shape;
proving the substance takes `focus: trace` or a `tool_used` grader counting
actual `Agent` calls. Both are used in this suite — see
`evals/reports-honestly-without-fanout/graders/` for the pattern.

`llm` graders sample three independent judge votes and take the majority, on a
small default judge model (`--judge-model` overrides it). An ambiguous criteria
file shows up as a 2–1 split rather than a clean result, so write explicit
PASS-requires and FAIL-if clauses.

### One run is a sample, not a result

`reports-honestly-without-fanout` failed a `--runs 1` pass on 2026-09-13 with
three unanimous FAIL votes, then passed 4/4 with unanimous PASS votes on a rerun
minutes later, no change in between. Six of seven observed runs that day passed.

The failing output had not fabricated anything — it said subagents were disabled,
said explicitly that it had run the sampling passes itself, and caveated the
counts as correlated rather than independent. What it did do was present the
result as a recurrence table anyway, which is close enough to the line that a
judge can reasonably go either way.

So treat a single red case as a prompt to rerun, not as a regression, and reach
for `--runs 3` or more before concluding a behaviour changed. Cases in this suite
declare `runs: 3` for exactly this reason; `--runs 1` is an iteration convenience
that trades reliability for cost, and the trade is invisible in the report.

### A `max`-only `tool_used` grader can never pass

Give a `tool_used` grader `max: 0` and no `min:`, and the harness defaults `min`
to 1. The constraint becomes "expected 1..0", which fails whether or not the tool
was used — so a negative case written this way reports a regression that is not
there, and would keep reporting one after any fix.

```yaml
tool: Skill
input_match: fanout-investigation
min: 0        # not redundant — without it this reads "expected 1..0"
max: 0
```

Observed on Claude Code 2.1.270, on two cases at once. State both bounds on every
"must not happen" grader.

### Do not suppress the mechanism a case is testing

A trigger case for a fan-out skill asserted in `append_system_prompt` that
subagents were unavailable, to keep the run cheap, and then graded that the skill
fired. It did not fire, and that was correct — told it cannot spawn anything, the
model declined to load a skill built entirely on spawning and explained why
instead.

The cheap way to bound a triggering case is `max_turns`, plus a `tool_used`
grader with an upper bound on `Agent`. That caps the spend without changing the
behaviour under test.

The same trap has a judge-side version. A criteria file whose FAIL-if clauses
name strings like "demote mobile instead" will fire on an answer that *offers*
that as an alternative after committing to the right decision — three unanimous
FAIL votes against correct output, which reads exactly like a real regression.
Tell the judge which part of the answer to grade.

### On `allowed_tools` and the `Agent` tool

`allowed_tools` is an allowlist of read-only tools, and the published docs
include `Agent` among the tools it can name. What the docs do not state is the
behaviour when `Agent` is *omitted*. On Claude Code 2.1.269 we observed a case
listing `allowed_tools: [Read, Glob, Grep, Skill]` spawn six subagents anyway,
confirmed by inspecting `trace.jsonl` under `--keep-temp`.

Treat that as a dated observation, not a rule — re-check it before relying on
it. There is no `disallowed_tools` key. If you need a run that genuinely must
not fan out, state the constraint in `append_system_prompt` and then *verify it
held* with a `tool_used` grader bounded by `max: 0`, rather than assuming the
prompt was obeyed.

## Changing the skills

### `stochastic-consensus`

Its value rests on three behaviors. If you change its `SKILL.md`, re-run the
evals that cover them:

| Behavior | Case |
|---|---|
| Never fabricates agent counts | `reports-honestly-without-fanout` |
| Declines when the answer is checkable | `declines-on-checkable-question` |
| Lenses actually decorrelate | `decorrelates-lenses` |

### `fanout-investigation`

Four behaviors, and the first three are cheap to check:

| Behavior | Case |
|---|---|
| The derived count is computed correctly, reductions shown | `investigation-derives-the-matrix` |
| Declines on material too small for it | `investigation-degrades-on-single-unit` |
| Does not fire on ordinary questions | `investigation-declines-on-small-question` |
| Disk discipline and coverage audit actually execute | `investigation-full-fanout` |

`investigation-full-fanout` tests the **machinery**, not spontaneous triggering.
Its fixture is deliberately tiny to keep the run affordable, which puts it below
the size where the skill declines a fan-out — so the prompt overrides the decline
explicitly. Read literally, a green run says the pipeline executes end to end. It
does **not** say the skill fans out on its own against a real codebase; no
committed case says that, because a fixture large enough to need twenty agents
costs more per run than this suite is worth.

**Fan-out cases are more expensive than the cost table below suggests.** One run
of `investigation-full-fanout` spawned 18 agents and cost **$19.30** over 36
minutes, because researchers inherit the orchestrator's model unless told
otherwise. `SKILL.md` now instructs the orchestrator to put researchers on a
cheaper tier and reserve the strong model for synthesis, which is the single
biggest lever on what this skill costs in real use as well as in CI.

Note also that `--max-cost-usd` is checked *before each run launches*, not during
one. A single run can overshoot the ceiling by a wide margin — this one exceeded
$15 and finished at $19.30, and the harness reports the overrun rather than
preventing it. When a breach happens, paid graders are skipped while free ones
still score, so a case can come back with a misleadingly low score and two
graders marked `skipped: cost ceiling` rather than failed. Read the grader lines,
not just the number.

If you touch the derivation rule, also re-check `reference/worked-example.md` —
it dry-runs the rule at four sizes and its four numbers are the fastest way to
see that a change was load-bearing.

### Either skill

Both fan out subagents, so they compete for triggering. A change to either
`description` can move the boundary, and `consensus-not-investigation` plus
`investigation-triggers-on-monorepo-audit` bracket it from both sides. Re-run
both after any description edit.

Only the cheap cases run in CI. `decorrelates-lenses` and
`investigation-full-fanout` are tagged `fanout` and cost real money, so a
regression in lens quality or in disk discipline ships unless you run it
yourself:

```bash
claude plugin eval . --tag fanout --runs 1 --ablation none --concurrency 2 \
  --scaffold --allow-tools Write Edit
```

`--scaffold` and `--allow-tools` are required since `investigation-full-fanout`
joined this tier — it builds its own fixture and its researchers write to disk.
Omitting them fails that case for reasons that have nothing to do with the skill.

A maintainer can also trigger it from the Actions tab — run the **evals**
workflow and pick `fanout` for the `suite` input; the workflow passes both flags.

## Releasing

The version is written in **four** places, and they are read separately:

```text
.claude-plugin/plugin.json        version
.claude-plugin/marketplace.json   metadata.version
.claude-plugin/marketplace.json   plugins[0].version
CHANGELOG.md                      the newest ## [x.y.z] heading
```

CI fails the PR if they disagree, so you will not ship a silent mismatch — but
update all four. Then move the `## [Unreleased]` entries under the new heading,
update the link definitions at the bottom of `CHANGELOG.md`, and after merge tag
the commit:

```bash
git tag -a v0.2.0 -m 'v0.2.0'
git push origin v0.2.0
gh release create v0.2.0 --notes-from-tag
```

Tagging matters beyond bookkeeping: `/plugin marketplace add` resolves the
default branch, so a tag is the only thing an installer can pin to.

## Before you commit

This is a public repository and the maintainer's local paths have leaked into it
once already. Check that a change introduces no absolute paths, home
directories, real names, credentials, or references to private projects — the PR
template has this as a checklist item, and it is the one worth actually reading.
