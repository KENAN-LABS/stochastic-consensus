# Worked example — a convergent run, start to finish

A compact end-to-end trace. The point is the shape of the decisions, not the
subject matter.

---

**User:** "We're on a single Postgres box and reads are getting slow. I'm torn
between adding a read replica, putting Redis in front of the hot queries, or
just buying a bigger instance. Small team, no dedicated ops. Which way?"

---

## Step 1 — Mode

Convergent. There are three named options and the user wants one picked, with a
sense of how sure we are. Not a brainstorm.

## Step 2 — Size

A real infrastructure decision, three bounded options, one domain. That is the
middle row: **5 agents × 1 committed answer each**. (In convergent mode M is
effectively 1 — each agent commits to one answer plus a runner-up. The M column
in the sizing table governs divergent runs.)

Cost is ~200k tokens. The user asked a real decision question and named the
options, so the spend is invited — run it, no confirmation needed.

## Step 3 — Lenses (stances, because this is convergent)

1. **Advocate for the simplest thing** — argue the lowest-operational-burden path
2. **Advocate for correctness under growth** — argue what survives 10× traffic
3. **Adversarial failure-hunter** — find what breaks each option in production
4. **Premise-checker** — is "reads are slow" even the real problem?
5. **Cost-and-team-capacity realist** — argue from the two-person-team constraint

Note that stance 4 is doing real work: it is the only agent permitted to reject
the question. Convergent runs without a premise-checker inherit the user's
framing uncritically.

## Step 4 — Fan out

Five `Agent` calls in one message, `general-purpose`, `model: "sonnet"`,
descriptions `"Vote: simplest thing"`, `"Vote: correctness under growth"`, etc.

Each prompt carries the convergent template from `generator-prompt.md` with:

- the question verbatim, identical across all five
- `{{CONTEXT}}` — **critically**, the facts from the conversation: single
  Postgres box, team of two, no dedicated ops, symptom is read latency. Without
  this, agent 3 invents a 50-person team and agent 5 invents a hobby project,
  and the tally becomes meaningless.
- stance, then the five-part output shape (answer / confidence / reasoning /
  what-would-change-my-mind / runner-up)

## Step 5 — Fan in

What came back:

| Agent | Answer | Confidence |
|---|---|---|
| Simplest thing | Bigger instance | high |
| Correctness under growth | Read replica | medium |
| Failure-hunter | Bigger instance | medium |
| Premise-checker | **Neither — find the slow query first** | high |
| Cost realist | Bigger instance | high |

Tally: **3/5 for vertical scaling**, 1 for a replica, 1 rejecting the premise.

Recurring reasoning across the three agreeing agents: a read replica adds
failover, lag, and connection-routing complexity that a two-person team without
ops will carry forever; Redis adds a second source of truth and cache-invalidation
bugs; both are permanent operational taxes taken on to solve a problem nobody has
profiled yet.

The premise-checker's dissent turned out to matter more than its single vote —
two of the three vertical-scaling agents independently noted they had not seen a
query plan, which is the same concern arriving from a different direction. That
is a merge the tally alone would miss, and catching it is why synthesis happens
in the main thread.

## The delivered answer

```
## Read replica vs. Redis vs. bigger instance
5 agents × 1 committed answer → 5 samples.

**Consensus: buy the bigger instance — but profile first.** 3/5 agents
independently chose vertical scaling, and the two that didn't both argued the
same underlying point: nobody has looked at a query plan yet.

**Reasoning the agents shared**: a replica or a cache is a permanent
operational tax on a two-person team with no ops — failover, replication lag,
connection routing, cache invalidation. Vertical scaling buys time with zero
new moving parts, and it's reversible.

**Dissent**: 1/5 said read replica for 10× headroom — a fair point if growth is
imminent, but it front-loads complexity for traffic you don't have. 1/5
rejected the question: "reads are slow" with no `EXPLAIN ANALYZE` may be one
missing index, in which case every option here is overkill.

**Confidence**: medium — and the dissent is why. Run `EXPLAIN ANALYZE` on your
three slowest dashboard queries first. If one is a sequential scan on an
unindexed column, the answer changes completely and costs nothing.
```

## What to notice

- The **answer leads**; the run statistics are one supporting line.
- The dissent is not buried — it changed the recommendation into a conditional
  one, which is more useful than the bare majority.
- **Confidence is medium, not high, despite 3/5 agreement**, because the
  premise-checker raised something the majority had not ruled out. Agreement
  count and confidence are related but not the same number, and reporting the
  tally as confidence would have overstated the case.
- The final line is the cheapest next action, not the winning option. A
  consensus run that ends in "do the expensive thing" without first naming the
  free check has not finished thinking.
