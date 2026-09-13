---
max_turns: 10
timeout_seconds: 300
runs: 2
tags: [triggering, investigation, negative]
---

Why does this return undefined when `DB_URL` isn't set, instead of throwing?

```ts
export function parseConfig(env: NodeJS.ProcessEnv) {
  const url = env.DB_URL;
  if (!url) return;
  return { url, pool: Number(env.DB_POOL ?? 10) };
}
```
