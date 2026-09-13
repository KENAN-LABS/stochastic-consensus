# Preset — codebase

For auditing, mapping, or onboarding onto a codebase large enough that one agent
cannot read it.

```yaml
units:  packages, workspaces, services, or top-level source directories
scopes: [cartography, stack, architecture, runtime, config, security, quality]
tiers:  core 7 · supporting 3 · peripheral 1
floor:  5
ceiling: 24
traces: max(3, ceil(units / 4))
output_dir: .investigation/
```

## The scopes

Ordered deliberately — `supporting` units take the first three, `peripheral` the
first one, so the order decides what survives a demotion. Cartography first
because a map of a unit is the single most useful thing to have about it.

| Scope | What the researcher covers |
|---|---|
| `cartography` | what is here — directory shape, entry points, what each part is for, where the real logic lives as opposed to where the file count is |
| `stack` | languages, frameworks, versions, dependencies, what is pinned, what is stale, what is vendored, what is dead |
| `architecture` | the intended structure — layers, boundaries, the patterns actually followed, and where the code departs from them |
| `runtime` | what happens when it runs — startup, request or job flow, state, concurrency, what talks to what |
| `config` | configuration, environments, secrets handling, build, deploy, CI, and how the thing is operated |
| `security` | trust boundaries, authn and authz, input handling, dependency exposure, what an attacker reaches first |
| `quality` | tests and what they actually cover, error handling, observability, and the specific places that will break |

## Tiering in Phase 0

Recon tiers by how much the investigation question depends on the unit, not by
size. A 2,000-line payments package is `core` where a 60,000-line generated
client is `peripheral`. Size is a tiebreak, never the criterion — tiering by line
count is how the build tooling gets seven agents and the money path gets one.

## Threads worth tracing

A request from arrival to response · authentication and identity · money or any
other irreversible side effect · a write from API to storage · the build and
deploy path · error propagation to wherever a human sees it.

## Overrides that come up

- Monorepo with many tiny packages — group by domain rather than by
  `package.json`, or `units` inflates and every unit is `peripheral`.
- A question about one dimension only, such as a security audit — cut `scopes` to
  three or four and raise `ceiling`. Depth per unit beats breadth of dimension
  when the dimension is already chosen.
- Read-only is **not** the default here. State it — the caller decides whether
  researchers may run builds, tests, or anything that writes.
