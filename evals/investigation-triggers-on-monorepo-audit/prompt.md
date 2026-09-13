---
max_turns: 4
timeout_seconds: 300
runs: 2
tags: [triggering, investigation, integrity]
---

We're taking over maintenance of a monorepo none of us has seen — eleven
packages, roughly 180k lines, plus an infra directory and a pile of CI config. I
need a complete audit before we commit to it. What's in each package, how they
fit together, where the risk is. Nothing skipped.
