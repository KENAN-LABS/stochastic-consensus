---
type: llm
weight: 1
---

This prompt never says "consensus", "agents", "vote", or "sample". It tests
whether the skill triggers on intent alone.

PASS requires:

1. Evidence the consensus method ran — run statistics, named lenses, and
   recurrence counts in the answer.
2. Lenses derived from this specific stack: payments/billing edge cases, auth
   and session security, abuse and fraud, ops and on-call, data and privacy,
   support load. A generic pre-launch checklist is a FAIL.
3. Findings are specific to Stripe / magic-link / Postgres / a small team —
   not stack-agnostic advice.
4. The long tail is explicitly surfaced, honoring the request for non-obvious
   items.
5. Obvious-checklist filler that the user pre-emptively rejected is absent or
   negligible.

If the skill did NOT trigger, this is a FAIL — the request is a textbook
coverage sweep and the skill's description claims it.
