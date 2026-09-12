# Changelog

All notable changes to this plugin are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `CODE_OF_CONDUCT.md`, `CODEOWNERS`, `.editorconfig`, `.gitattributes`, and a
  Dependabot config.
- Deterministic graders (`tool_used`, `regex`, and `llm` graders with
  `focus: trace`) alongside the existing prose graders, so the integrity and
  fan-out cases assert what the model *did*, not only what it said.
- CI now runs free, secret-less checks on every pull request: version agreement
  across all four places a version is written, manifest structure, eval-case
  completeness, and markdown lint. Fork PRs can pass these.
- `workflow_dispatch` accepts a `suite` input, so the `fanout` cases can be run
  from the Actions tab instead of only from a maintainer's laptop.
- README: a `Limitations` section stating plainly what recurrence does and does
  not measure, a worked output excerpt, install prerequisites, and a CI badge.

### Changed

- CI installs a pinned `@anthropic-ai/claude-code` from npm rather than piping
  an unpinned `install.sh` into `bash`, and every action is pinned by commit
  SHA. The workflow declares `permissions: contents: read`, a concurrency
  group, and job timeouts.
- `SECURITY.md` now scopes the audit surface correctly: the eval cases and the
  CI workflow are part of it, and both are described.
- `SKILL.md` treats pasted context as data rather than instructions, reconciles
  "lens" with "stance", tells you what to do when the mode is ambiguous, and
  qualifies the nested-spawning and cost claims.

### Fixed

- `CONTRIBUTING.md` listed six grader types that do not exist (`judge`,
  `contains`, `equals`, `script`, `command`, `file`) and omitted two that do
  (`tool_used`, `tool_order`). Corrected against the published harness
  documentation, along with the case frontmatter key set.
- The `Tested` table reported `3/3` for every case while four of the six
  declare `runs: 2`. The table now reports judge votes and run counts
  separately, and says which cases CI actually covers.
- Release instructions said to bump the version in two files; there are four
  places it is written. CI now enforces that they agree.

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

[Unreleased]: https://github.com/KENAN-LABS/stochastic-consensus/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/KENAN-LABS/stochastic-consensus/releases/tag/v0.1.0
