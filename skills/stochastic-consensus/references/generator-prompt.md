# Generator prompt templates

Fill the placeholders and send one of these per agent, all in a single assistant
message so they run concurrently. Never send the same text to every agent — the
`{{LENS}}` line is the only thing stopping the samples from collapsing onto each
other, and without it the run is just an expensive single query.

## Divergent (union) generator

```
You are one of {{N}} independent contributors working in isolation on the same
question. You cannot see the others and should not try to guess what they wrote.

QUESTION (verbatim — answer exactly this):
{{QUESTION}}

YOUR LENS: {{LENS}}
Approach the question primarily through this lens. It is what makes your
contribution different from everyone else's. Do not dilute it into a generic
answer — a distinctive list from one angle is worth far more to the pool than a
safe list that overlaps with everyone else's.

PRODUCE: at least {{M}} candidates. Distinct means substantively different — a
different mechanism, component, technique, or tradeoff. Rewording one idea does
not make two. If you run short, push further into your lens rather than padding
with near-duplicates.

BE CONCRETE. Name specific things, quantities, techniques, tools, and tradeoffs.
A candidate someone could act on beats a category label every time.

FORMAT — return only this list. No preamble, no caveats, no closing summary:
1. **Name of candidate** — one or two sentences: what it is, and why it works.
2. **Name of candidate** — ...
```

## Convergent (voting) generator

```
You are one of {{N}} independent reviewers working in isolation on the same
question. You cannot see the others' answers.

QUESTION (verbatim):
{{QUESTION}}

YOUR STANCE: {{LENS}}
Reason from this stance honestly. If the evidence pushes you off it, say so —
the point is an independent read, not advocacy.

CONTEXT YOU NEED:
{{CONTEXT}}

PRODUCE, in this order, and nothing else:
1. **Answer** — your single best answer in one line, no hedging.
2. **Confidence** — high / medium / low.
3. **Reasoning** — the 2-4 considerations that actually drove your answer.
4. **What would change my mind** — the specific fact or result that would flip you.
5. **Runner-up** — the next-best answer, and why you rejected it.
```

## Filling these in

- **`{{QUESTION}}` must be byte-identical across agents.** If each agent gets a
  subtly different question, recurrence counts stop meaning anything — you are
  pooling answers to different questions and calling the overlap consensus.
- **`{{CONTEXT}}` matters most in convergent mode** when the question concerns the
  user's own code or situation. Subagents inherit no conversation history, so
  paste the relevant file paths, snippets, constraints, and prior decisions. An
  agent guessing at missing context votes on a different question than its peers,
  which corrupts the tally silently — the worst kind of corruption, because the
  output still looks like a clean vote.
- **Vary only the lens.** It is tempting to also vary format or count "for more
  diversity"; that just makes synthesis harder without widening the distribution
  in any useful way.
- **Name the lens in the Agent call's `description`** (e.g. "Lens: caching") so the
  run is legible while it executes and you can tell at a glance whether your
  lenses were actually distinct.
