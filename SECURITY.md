# Security

## Scope

What installs onto your machine is **Markdown only** — no hooks, no MCP servers, no
dependencies: two skills that instruct a model, the reference files, presets and templates
they load on demand, and eval cases.

The repository itself contains one executable script —
`evals/investigation-full-fanout/scaffold.sh`, which builds a throwaway fixture for a single
eval case. It is not part of what an installer receives and runs only when you pass
`--scaffold`. See "What runs code" below.

That shape removes most of the usual attack surface. It does not remove all of it, and the
parts that remain are worth stating precisely.

### What you are trusting when you install

- **Prompt injection through the skill text.** Both skills instruct a model to spawn subagents
  and act on what they return. A malicious edit to either `SKILL.md`, or to any file under
  `references/`, `reference/`, `presets/` or `templates/`, could steer that behaviour without
  looking like code.
- **Injection through the context the skill pastes.** The method deliberately copies your
  material — file contents, an issue body, fetched text — into every generator prompt
  verbatim, because subagents inherit no conversation. If that material contains instructions,
  it reaches all N agents identically, and text designed to manufacture agreement can come
  back looking like independent corroboration. `SKILL.md` instructs the model to treat pasted
  context and returned candidates as data rather than instructions; that is a prompt-level
  control, not an enforced boundary.
- **Cost.** A run fans out to multiple subagents on your credential, and nesting is possible.
  The brakes are advisory prose in `SKILL.md` — a sizing table and a confirmation step for
  `stochastic-consensus`, a derived agent count and an approval gate for `fanout-investigation`
  — and an edit that removes them would make a routine question expensive. There is no enforced
  ceiling on agent count or recursion depth. `fanout-investigation` in particular is designed to
  spawn tens of agents; one unpinned eval run of it cost $19.30.
- **No pinning.** `/plugin marketplace add` resolves this repository's default branch. Unless
  you install from a tag, what you audited and what you later receive can differ. Releases are
  tagged; pin to one if that matters to you.

### What runs code

Three things in this repository execute, and none of them ship to an installer:

- **`claude plugin eval` runs the eval suite on your machine, as you.** The cases under
  `evals/` drive a real agent with real tool access. `allowed_tools` is an allowlist of
  read-only tools; as of Claude Code 2.1.269 we have observed cases spawning subagents that
  the case did not list, and the published documentation does not specify the behaviour when
  `Agent` is omitted (see `CONTRIBUTING.md`). Treat any eval suite — this one included — as
  code you are choosing to run. Read it first.
- **`.github/workflows/evals.yml` runs that suite in CI with an API key in the job
  environment.** Pull requests that touch `evals/**` therefore propose changes to something
  that will execute with a live credential. The workflow declares `permissions: contents:
  read`, pins every action by commit SHA, installs a pinned CLI version rather than piping a
  remote script to a shell, and caps spend with `--max-cost-usd`. Secrets are not exposed to
  pull requests from forks, so the eval job is skipped there and only the free checks run.
- **`evals/investigation-full-fanout/scaffold.sh` runs as a shell script when you pass
  `--scaffold`.** It is the only executable file in the repository. It writes a small synthetic
  fixture into the eval's own disposable workspace and makes no network calls, but it is shell
  that executes as you, so read it before granting `--scaffold`. The CI workflow grants it only
  on the manually dispatched `fanout` and `all` suites, never on a pull request.

## For reviewers

The skills themselves — everything an installer actually receives — are these 15 files:

```text
skills/stochastic-consensus/SKILL.md
skills/stochastic-consensus/references/generator-prompt.md
skills/stochastic-consensus/references/worked-example.md
skills/stochastic-consensus/references/failure-modes.md

skills/fanout-investigation/SKILL.md
skills/fanout-investigation/README.md
skills/fanout-investigation/presets/codebase.md
skills/fanout-investigation/presets/document-review.md
skills/fanout-investigation/presets/research.md
skills/fanout-investigation/reference/rationale.md
skills/fanout-investigation/reference/worked-example.md
skills/fanout-investigation/templates/coverage.md
skills/fanout-investigation/templates/recon.md
skills/fanout-investigation/templates/researcher.md
skills/fanout-investigation/templates/synthesizer.md
```

Read those to audit what the plugin will do. To audit what this repository does, add
`evals/` and `.github/workflows/evals.yml`.

## Reporting

Report suspected issues through
[GitHub private vulnerability reporting](https://github.com/KENAN-LABS/stochastic-consensus/security/advisories/new).
Please do not open a public issue for a security problem.

Expect an initial response within seven days. This is a single-maintainer project; that is a
best-effort commitment, not a staffed SLA.
