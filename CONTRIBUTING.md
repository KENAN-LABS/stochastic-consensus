# Contributing

## Layout

```text
.claude-plugin/plugin.json        plugin manifest (points evals at evals/)
.claude-plugin/marketplace.json   makes this repo installable as a marketplace
skills/stochastic-consensus/      the skill itself
evals/<case>/prompt.md            eval case + frontmatter
evals/<case>/graders/*.md         graders for that case
```

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

The accepted key set. An unknown key is an error at load time.

```text
schema_version   name        description   tags
plugins          runs        expected_outcome
model            max_turns   timeout_seconds
allowed_tools    append_system_prompt       env
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

## Changing the skill

The skill's value rests on three behaviors. If you change `SKILL.md`, re-run the
evals that cover them:

| Behavior | Case |
|---|---|
| Never fabricates agent counts | `reports-honestly-without-fanout` |
| Declines when the answer is checkable | `declines-on-checkable-question` |
| Lenses actually decorrelate | `decorrelates-lenses` |

Only the first two run in CI. `decorrelates-lenses` is tagged `fanout` and costs
real money, so a regression in lens quality ships unless you run it yourself:

```bash
claude plugin eval . --tag fanout --runs 1 --ablation none --concurrency 2
```

A maintainer can also trigger it from the Actions tab — run the **evals**
workflow and pick `fanout` for the `suite` input.

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
