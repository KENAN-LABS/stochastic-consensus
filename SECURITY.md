# Security

## Scope

This plugin ships **no executable code** — no scripts, no hooks, no MCP servers, no
dependencies. It is Markdown: a skill that instructs a model, reference files it loads on
demand, and eval cases.

That shape removes most of the usual attack surface, but not all of it. The realistic concerns
are:

- **Prompt injection through the skill text.** The skill instructs a model to spawn subagents
  and act on their pooled output. A malicious edit to `SKILL.md` or any file under
  `references/` could steer that behaviour.
- **Cost.** A run fans out to multiple subagents. An edit that removes the sizing guidance or
  the confirmation step could make a routine question expensive.
- **Eval cases execute as you.** `claude plugin eval` runs a suite on your machine. Only run
  suites you have read.

## Reporting

Report suspected issues through
[GitHub private vulnerability reporting](https://github.com/KENAN-LABS/stochastic-consensus/security/advisories/new).
Please do not open a public issue for a security problem.

Expect an initial response within seven days.

## For reviewers

The entire attack surface is four files, about 500 lines total:

```
skills/stochastic-consensus/SKILL.md
skills/stochastic-consensus/references/generator-prompt.md
skills/stochastic-consensus/references/worked-example.md
skills/stochastic-consensus/references/failure-modes.md
```

Read them directly. There is nothing else to audit.
