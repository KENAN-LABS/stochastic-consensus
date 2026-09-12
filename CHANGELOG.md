# Changelog

All notable changes to this plugin are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1] — 2026-09-12

### Fixed

- `SKILL.md`'s YAML frontmatter was invalid. The `description` is an unquoted
  scalar, and v0.2.0 introduced a `": "` inside it ("deliberately narrow: it
  covers..."), which YAML reads as a nested mapping. GitHub refused to render
  the file — *"mapping values are not allowed in this context at line 2 column
  1090"* — and a strict loader would refuse to load the skill. Replaced with an
  em dash.

### Added

- CI parses the frontmatter of every Markdown file with a real YAML loader, so
  this class of breakage cannot ship again. It is a free check and runs on
  fork PRs.

## [0.2.0] — 2026-09-12

### Added

- `.github/workflows/claude.yml` and `claude-code-review.yml` — the Claude Code
  GitHub App workflows, added by `/install-github-app`. They authenticate from
  the `CLAUDE_CODE_OAUTH_TOKEN` repository secret.

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

- The `description`'s checkable-answer exclusion was written broadly enough to
  suppress legitimate coverage questions: `triggers-without-technique-named`
  regressed to a single-pass answer with the skill never loading, and all three
  prose judges passed it anyway. Narrowed to "one check would settle it", with
  open-ended questions about a codebase explicitly still in scope. Verified in
  both directions — the trigger fires again, the negative case still declines.
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

[Unreleased]: https://github.com/KENAN-LABS/stochastic-consensus/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/KENAN-LABS/stochastic-consensus/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/KENAN-LABS/stochastic-consensus/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/KENAN-LABS/stochastic-consensus/releases/tag/v0.1.0
