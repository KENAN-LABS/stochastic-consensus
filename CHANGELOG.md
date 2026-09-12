# Changelog

All notable changes to this plugin are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] — 2026-09-12

Initial release.

### Added
- `stochastic-consensus` skill with a five-step method: mode selection, run
  sizing, agent decorrelation, parallel fan-out, recurrence-ranked synthesis.
- Divergent (union) and convergent (voting) modes with separate output formats.
- Integrity rules requiring that reported agent counts and recurrence figures
  reflect runs that actually happened.
- `references/generator-prompt.md` — fill-in-the-blank subagent prompts for both
  modes.
- `references/worked-example.md` — a full convergent run, start to finish.
- `references/failure-modes.md` — six documented failure modes and their fixes.
- Eval suite of six cases runnable with `claude plugin eval`, covering
  triggering (explicit and implicit), mode selection, lens decorrelation,
  declining checkable questions, and refusal to fabricate agent counts.
  All six pass with unanimous judge votes on Claude Code 2.1.269.
