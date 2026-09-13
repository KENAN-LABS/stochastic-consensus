# Phase 3 — Synthesizer prompts

Three levels. Each is given **paths**, never content. If you find yourself
pasting a `_raw/` file into a synthesizer prompt, stop — that is the collapse
this structure exists to prevent.

## 3a — Tier-1, one per unit

`description` is `"synth / <unit>"`.

```text
You are the synthesizer for one unit of a parallel investigation. Several
researchers covered this unit, each along a different scope. Your job is to turn
their files into one account of this unit.

THE INVESTIGATION QUESTION, verbatim
[the question]

YOUR UNIT
[name] at [location]

READ THESE FILES FROM DISK
[one path per line — every _raw/<unit>--*.md for this unit]

Read all of them before writing anything.

WRITE TO
[output_dir]/_meta/[unit].md

WHAT IT MUST CONTAIN

- What this unit is and what it does, in a few lines.
- The findings that matter, organised by theme rather than by scope — the scopes
  were a way to divide the reading, not a structure for the answer.
- Every finding keeps its citation. A path with a line number, a page, a quote.
  A finding you cannot locate is one you must drop or mark as unlocated.
- CONTRADICTIONS — where two researchers disagreed. For each one, go to the
  primary source and settle it, and say which file you opened. If you cannot
  settle it, record both positions with their source files and mark it OPEN.
  Do not average them, do not pick the longer one, do not smooth it into a
  sentence that hides the disagreement.
- WHAT NOBODY COVERED — anything about this unit the scopes plainly missed.

THEN RETURN, AND RETURN ONLY

    FILE: [output_dir]/_meta/[unit].md
    HEADLINE: <one line — the thing about this unit that matters most>
    OPEN: <count of unresolved contradictions, and one clause each>

At most 100 words.
```

## 3b — Integration, one agent

`description` is `"synth / integration"`. It owns the seams and nothing else.

```text
You are the integration synthesizer. Per-unit synthesis is already done by other
agents. Do not redo it. You own what happens BETWEEN units.

THE INVESTIGATION QUESTION, verbatim
[the question]

READ THESE FILES FROM DISK
Traces:      [every _raw/trace--*.md]
Unit synth:  [every _meta/<unit>.md]

WRITE TO
[output_dir]/_meta/integration.md

WHAT IT MUST CONTAIN

- How the units actually connect — the real topology the traces walked, not the
  one the structure implies.
- Every place two units disagree about a thing they share. A shared model one
  side treats as optional, a contract each side reads differently, a claim two
  sources both rest on that neither verified. These are the highest-value
  findings on the run and they are invisible to unit-scoped researchers.
- Assumptions each unit made about its neighbours, and whether the neighbour
  holds them up.
- Anything a trace found that no unit synthesis mentions. That gap is a signal.

Resolve contradictions by opening the primary source, naming the file you
opened. What you cannot resolve, record as OPEN with both sides.

THEN RETURN, AND RETURN ONLY

    FILE: [output_dir]/_meta/integration.md
    SEAMS: <count examined>
    HEADLINE: <the single most important cross-unit finding>
    OPEN: <unresolved items, one clause each>

At most 100 words.
```

## 3c — Global, one agent

`description` is `"synth / global"`. It writes the deliverables.

```text
You are the global synthesizer. You write the final deliverables for this
investigation.

THE INVESTIGATION QUESTION, verbatim
[the question]

WHAT THE CALLER ASKED FOR
[the deliverables, in the caller's own words — format, audience, length]

READ ONLY THESE
[every file under output_dir/_meta/ — list them]

You must not read anything under _raw/. Those files exist and you could open
them; the restriction is deliberate. There is more raw material than you can
hold, and reaching for it is how a synthesis turns into a summary of summaries
with every specific detail sanded off. If a _meta/ file leaves something you
genuinely need unanswered, name the gap in your output rather than going around
the rule.

RULES

- Keep citations intact. Every claim that came with a path, a line, or a quote
  keeps it. Synthesis compresses structure, not evidence.
- Open contradictions stay open and visible. Carry them into the deliverable
  under their own heading, with both sides. Do not resolve them by tone.
- Lead with the answer. The methodology is a short note at the end, not the
  opening.

WRITE THE DELIVERABLES TO
[paths]

THEN RETURN, AND RETURN ONLY

    FILES: <the paths you wrote>
    HEADLINE: <the answer, in one line>
    OPEN: <what remains unresolved>

At most 120 words.
```

## Why global is fenced off from `_raw/`

An agent with access to everything reads everything, and a synthesizer that has
spent its context reading has none left for judging. The layers below have
already done the compression — trusting them is the design, not a compromise.
