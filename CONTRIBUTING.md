# Contributing

## Layout

```
.claude-plugin/plugin.json        plugin manifest (points evals at evals/)
.claude-plugin/marketplace.json   makes this repo installable as a marketplace
skills/stochastic-consensus/      the skill itself
evals/<case>/prompt.md            eval case + frontmatter
evals/<case>/graders/*.md         graders for that case
```

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
- `--runs N` overrides each case's `runs:`. Use `--runs 1` while iterating.

Cases tagged `fanout` spawn real subagents. They are slow (several minutes) and
cost roughly $0.75–1.50 per run. Cases tagged `integrity` and `negative` do not
fan out and cost about $0.20.

## Case frontmatter schema

Not documented elsewhere; this is the accepted key set, recovered from the
loader's own error message. Any other key fails the case at load time.

```
schema_version   name        description   tags
plugins          runs        expected_outcome
model            max_turns   timeout_seconds
allowed_tools    artifact_publish
growthbook_overrides         append_system_prompt        env
```

Two findings worth knowing before you write a case:

- **`allowed_tools` does not gate the `Agent` tool.** A case listing
  `allowed_tools: [Read, Glob, Grep, Skill]` will still happily spawn six
  subagents. Verified by inspecting `trace.jsonl` under `--keep-temp`. If you
  need a run that genuinely cannot fan out, state the constraint in
  `append_system_prompt` — there is no `disallowed_tools` key.
- **Graders see the last message by default** (`focus: last_message`). Write
  criteria against the delivered answer, not against the process. If you need to
  assert what the model *did* rather than what it *said*, inspect
  `trace.jsonl` from a `--keep-temp` run instead of writing a grader for it.

## Grader types

`llm` (used throughout here), plus `judge`, `baseline`, `regex`, `contains`,
`equals`, `script`, `command`, `file`. Frontmatter is `type:` and `weight:`.

LLM graders sample three independent judge votes and take the majority, so a
criteria file that is ambiguous will show up as a 2–1 split rather than a clean
result. Write criteria with explicit PASS-requires and FAIL-if clauses.

## Changing the skill

The skill's value rests on three behaviors. If you change `SKILL.md`, re-run the
evals that cover them:

| Behavior | Case |
|---|---|
| Never fabricates agent counts | `reports-honestly-without-fanout` |
| Declines when the answer is checkable | `declines-on-checkable-question` |
| Lenses actually decorrelate | `decorrelates-lenses` |

Bump the version in **both** `.claude-plugin/plugin.json` and
`.claude-plugin/marketplace.json` — they are read separately and silently
disagree if you update only one. Add a `CHANGELOG.md` entry.
