## What this changes

<!-- One or two sentences. -->

## Why

<!-- The situation that makes the current behaviour inadequate. -->

## Evals

CI runs the free checks on every PR, plus the two non-fan-out eval cases when a
maintainer's secret is available. Fan-out cases cost real money and never run
automatically — if this touches `skills/`, run them locally and paste the result:

```bash
claude plugin eval . --tag fanout --runs 1 --ablation none --concurrency 2
```

- [ ] `integrity` + `negative` pass
- [ ] `fanout` cases pass, or this change cannot affect them
- [ ] New behaviour has a case covering it, or none is warranted (say why)

## Checklist

- [ ] Version bumped in all four places, if this is a release (`plugin.json`,
      `marketplace.json` × 2, `CHANGELOG.md`) — CI checks this
- [ ] `CHANGELOG.md` entry added under `## [Unreleased]`
- [ ] No personal paths, credentials, local directory references, or unscrubbed
      `trace.jsonl` content
