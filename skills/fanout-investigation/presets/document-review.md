# Preset — document review

For reviewing a large document, or a set of them, where the whole must be read
but no one reading can hold it all — a contract pack, a spec, a policy set, an
RFP response.

```yaml
units:  sections, chapters, or individual documents
scopes: [content, consistency, risk, open-questions]
tiers:  core 4 · supporting 3 · peripheral 1
floor:  5
ceiling: 24
traces: max(3, ceil(units / 4))
output_dir: .investigation/
```

| Scope | What the researcher covers |
|---|---|
| `content` | what this section actually says, in plain terms — obligations, definitions, mechanics, and who is bound by what |
| `consistency` | internal coherence, and whether defined terms are used as defined |
| `risk` | exposure created here — liability, cost, timing, dependency, anything irreversible or unbounded |
| `open-questions` | what is undecided, undefined, deferred to an unwritten annex, or ambiguous enough to be argued both ways |

## Tiering in Phase 0

By consequence, never by length. A three-line limitation-of-liability clause is
`core`. A twelve-page appendix of boilerplate is `peripheral`. Length-based
tiering fails hardest in this preset, which is why recon is told to give a
reason for every tier.

## Threads worth tracing

A defined term, traced through every place it is used · an obligation, from
where it is created to where it is enforced and what happens on breach · money,
from trigger to invoice to remedy · termination · anything the document points
at another document to resolve.

Cross-references are the seams here, and a section-scoped reader systematically
cannot see a term redefined three sections later.

## Overrides that come up

- Comparing versions or counterparties — make `units` the documents and add
  `deltas` as a scope, or the diff never gets its own agent.
- One long document with no sections — have recon cut it into units by topic and
  return exact ranges, so every researcher's slice is unambiguous.
- Reviewing for a decision rather than for understanding — replace
  `open-questions` with `recommendation` and say what the decision is.
