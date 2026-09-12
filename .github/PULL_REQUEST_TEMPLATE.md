## What this changes

<!-- One or two sentences. -->

## Why

<!-- The situation that makes the current behaviour inadequate. -->

## Evals

CI runs only the two non-fan-out cases. If this touches `skills/`, run the rest locally and
paste the result:

```bash
claude plugin eval . --tag fanout --runs 1 --ablation none --concurrency 2
```

- [ ] `integrity` + `negative` pass
- [ ] `fanout` cases pass, or this change cannot affect them
- [ ] New behaviour has a case covering it, or none is warranted (say why)

## Checklist

- [ ] Version bumped in **both** `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`
- [ ] `CHANGELOG.md` entry added
- [ ] No personal paths, credentials, or local directory references
