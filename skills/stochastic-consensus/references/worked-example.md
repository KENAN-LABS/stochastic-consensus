# Worked examples

Two compact end-to-end traces, one per mode. The point is the shape of the
decisions, not the subject matter.

- [A convergent run](#a-convergent-run) — voting, tallying, and dissent
- [A divergent run](#a-divergent-run) — coverage, merging, and the long tail

---

## A convergent run

---

**User:** "We're on a single Postgres box and reads are getting slow. I'm torn
between adding a read replica, putting Redis in front of the hot queries, or
just buying a bigger instance. Small team, no dedicated ops. Which way?"

---

### Step 1 — Mode

Convergent. There are three named options and the user wants one picked, with a
sense of how sure we are. Not a brainstorm.

### Step 2 — Size

A real infrastructure decision, three bounded options, one domain. That is the
middle row: **5 agents × 1 committed answer each**. (In convergent mode M is
effectively 1 — each agent commits to one answer plus a runner-up. The M column
in the sizing table governs divergent runs.)

Cost is ~200k tokens. The user asked a real decision question and named the
options, so the spend is invited — run it, no confirmation needed.

### Step 3 — Lenses (stances, because this is convergent)

1. **Advocate for the simplest thing** — argue the lowest-operational-burden path
2. **Advocate for correctness under growth** — argue what survives 10× traffic
3. **Adversarial failure-hunter** — find what breaks each option in production
4. **Premise-checker** — is "reads are slow" even the real problem?
5. **Cost-and-team-capacity realist** — argue from the two-person-team constraint

Note that stance 4 is doing real work: it is the only agent permitted to reject
the question. Convergent runs without a premise-checker inherit the user's
framing uncritically.

### Step 4 — Fan out

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

### Step 5 — Fan in

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

### The delivered answer

```text
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

### What to notice

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

---

## A divergent run

The harder synthesis of the two: nothing is voted out, so the work is merging
without flattening.

---

**User:** "We're losing people during onboarding and I don't know why. What are
all the ways we could be losing them? B2B SaaS, self-serve signup, 14-day
trial, about 400 signups a month."

---

### Step 1 — Mode (divergent)

Divergent. "All the ways" is a coverage request — there is no option set to
choose between, and voting one of these out would be actively harmful. Rarity
is interesting here, not disqualifying.

### Step 2 — Size (divergent)

Churn causes span many domains — product, pricing, lifecycle, support,
billing — so this is the bottom row: **8 agents × 12 candidates**, a pool of
around 100. Roughly 350k tokens.

The user asked an open "what are all the ways" question but did not invite a
large spend explicitly, so this gets a one-line check before spawning:

> "This'd be ~350k tokens across 8 agents for a full sweep. Want that, or a
> quicker 3-agent pass?"

### Step 3 — Lenses

The dimensions onboarding drop-off actually varies along — derived from the
domain, not pulled from a stock list:

1. **Signup and activation friction** — the mechanics of getting in
2. **Time-to-first-value** — how long before the product does something useful
3. **Onboarding content and guidance** — docs, tours, empty states
4. **Fit and expectation mismatch** — people who were never going to convert
5. **Pricing and packaging** — what the trial gates and when that bites
6. **Technical failure** — errors, latency, broken integrations, email
   deliverability
7. **Lifecycle messaging** — the emails and nudges during the 14 days
8. **Segment-specific causes** — where drop-off concentrates by company size,
   channel, or role

Apply the test: agent 1 (signup friction) and agent 6 (technical failure) would
return nearly disjoint lists. So would 4 (fit) and 7 (messaging). The lenses
are doing their job. Had the list been "onboarding, activation, user
experience, engagement", four agents would have written the same list four
times.

### Step 4 — Fan out (divergent)

Eight `Agent` calls in one message, `general-purpose`, `model: "sonnet"`,
descriptions `"Lens: signup friction"`, `"Lens: time-to-first-value"`, and so
on. Each carries the divergent template: the question verbatim and identical
across all eight, the assigned lens, "at least 12 candidates", the output
shape, and the no-hedging instruction.

`{{CONTEXT}}` carries the facts that change the answer — B2B, self-serve, 14-day
trial, ~400 signups/month — fenced and labelled as material. Without it agent 5
reasons about enterprise procurement and agent 8 about a consumer app, and the
recurrence counts stop meaning anything.

### Step 5 — Fan in (divergent)

Seven agents returned; one came back empty. **N is 7, and the report says so.**

The pool is 84 raw candidates. Merging collapses it to 61 distinct. Most of the
merging is semantic rather than lexical — "users don't reach the aha moment
fast enough" from the time-to-value agent and "the empty state doesn't tell you
what to do first" from the content agent are the same underlying problem
described from two directions, and they merge into one candidate with a count
of 2.

Three items recurred across five or more agents. Twenty-two are singletons, and
they are kept — that tail is what 84 samples were spent to reach.

### The delivered answer (divergent)

```text
## Where you could be losing trial users
7 agents × 12 candidates → 84 samples → 61 distinct after merging.
(8 launched, 1 returned empty.)
Lenses: signup friction · time-to-first-value · onboarding content · fit and
expectation · pricing and packaging · technical failure · lifecycle messaging

### Getting in the door
- **Email verification required before anything is visible** — a hard stop
  before any value is seen; deliverability problems here look like disinterest.
  `×5`
- **Signup asks for company size and role before the product loads** — every
  field before first value costs conversions. `×4`
- **No SSO for the segment most likely to buy** `×1 (uncorroborated)`

### Time to first value
- **The product is empty until data is imported** — the integration is the real
  onboarding, and it is the step nobody finishes. `×6`
- **The "aha" action is not the first action offered** — the empty state leads
  with settings rather than the thing that demonstrates value. `×5`

### The trial clock
- **14 days spans one buying cycle, not two** — B2B evaluation often needs a
  second stakeholder, who is unavailable in week one. `×3`
- **Trial starts at signup rather than at first successful use** — days are
  consumed before the product has done anything. `×2`

### Quiet technical failure
- **Onboarding emails landing in spam** — invisible from inside the funnel;
  looks identical to users who lost interest. `×3`
- **Integration OAuth failing silently for one provider** `×1 (uncorroborated)`

**Strong recurrence** (5+ agents, independently): empty-until-imported,
verification-before-value, wrong first action.

**Long tail worth a look**: trial-clock-starts-at-signup — only 2 agents raised
it, but it is the cheapest of these to test and it would explain drop-off that
looks like disinterest.
```

### What to notice (divergent)

- **The failed agent is reported**, in the header, as part of the run
  statistics. Seven returned; the count says seven.
- **Singletons are marked, not deleted.** The OAuth item came from one agent and
  may be nothing — but it is exactly the kind of specific, checkable cause a
  single-pass answer never surfaces.
- **The long tail gets its own callout**, because burying a 2-count item in a
  61-item list wastes what the run was for. Recurrence ranks the list; it does
  not decide what is worth saying.
- **Groups came from the pool, not from the lenses.** "Quiet technical failure"
  collects items from three different agents. Sectioning by lens would just be
  reprinting each agent's output in order, which is a transcript, not a merge.
