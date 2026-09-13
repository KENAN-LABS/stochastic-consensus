# Phase 4 — Coverage audit

Built by you, in the main thread, before you report anything. It is a check on
the run, so delegating it to an agent that would have to be told what was
supposed to happen defeats it.

## The grid

Units down, scopes across. Every cell holds a file path or an explicit `N/A`.

```text
| Unit       | cartography | stack | architecture | runtime | config | security | quality |
|------------|-------------|-------|--------------|---------|--------|----------|---------|
| api-core   | _raw/api-core--cartography.md | _raw/api-core--stack.md | ... | ... | ... | ... | ... |
| web-client | _raw/web-client--cartography.md | _raw/web-client--stack.md | _raw/web-client--architecture.md | N/A — supporting tier, 3 scopes | N/A — supporting tier | N/A — supporting tier | N/A — supporting tier |
| tooling    | _raw/tooling--cartography.md | N/A — peripheral tier, 1 scope | N/A — peripheral | N/A — peripheral | N/A — peripheral | N/A — peripheral | N/A — peripheral |
```

Then the threads:

```text
| Thread              | Trace file                  | Crossed          |
|---------------------|-----------------------------|------------------|
| request lifecycle   | _raw/trace--request.md      | web → api → db   |
| auth and identity   | _raw/trace--auth.md         | web → api → idp  |
| money movement      | _raw/trace--money.md        | api → billing    |
```

## The rules

- **An empty cell is a gap.** Fill it with a late researcher or write the `N/A`
  and its reason. There is no third option, and a blank cell shipped in a report
  is the under-decomposition failure arriving at the reader.
- **`N/A` states a reason.** "N/A" alone is an empty cell with punctuation. The
  reason is usually the tier, and that is a fine reason — it is a decision the
  matrix made on purpose, recorded where a reader can see it.
- **Every thread has a trace file.** A thread with no file means a trace agent
  failed. Say so, and either respawn it or report the seam as uncovered.
- **Every named file exists.** Check, do not assume. An agent that returned an
  abstract without writing its file is the one failure the abstract contract
  cannot reveal on its own.
- **Count what returned.** If 21 launched and 17 returned, the run had 17
  researchers. Say which cells lost their agent and what you did about it.

## In the report

Include the grid, or a one-line summary of it plus the full grid at
`_meta/coverage.md`. Then state, in one line, agents launched, agents returned,
cells covered, cells `N/A`, and threads traced. Those five numbers are the
honest description of what the run actually did.
