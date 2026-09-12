# CLAUDE.md — stochastic-consensus

A Claude Code plugin. The deliverable is prose that changes a model's behaviour
(`skills/stochastic-consensus/SKILL.md`) plus an eval suite that proves it did. There is no
runtime code, no dependencies, no build.

## Before changing the skill

Read `CONTRIBUTING.md` first. Two harness findings documented there will otherwise cost you an
afternoon: `allowed_tools` does not gate the `Agent` tool, and there is no `disallowed_tools`
key.

The skill's value rests on three behaviours. If you edit `SKILL.md`, re-run their cases:

| Behaviour | Case |
|---|---|
| Never fabricates agent counts | `reports-honestly-without-fanout` |
| Declines when the answer is checkable | `declines-on-checkable-question` |
| Lenses actually decorrelate | `decorrelates-lenses` |

```bash
claude plugin eval . --tag integrity --tag negative --runs 1 --ablation none   # ~$0.40, ~1 min
claude plugin eval . --tag fanout --runs 1 --ablation none --concurrency 2     # ~$6,    ~12 min
```

CI runs only the first line. A regression in lens decorrelation or convergent tallying ships
unless you run the second yourself.

## Releasing

Bump the version in **both** `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`
— they are read separately and disagree silently — and add a `CHANGELOG.md` entry.
