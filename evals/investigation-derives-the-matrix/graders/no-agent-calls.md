---
type: tool_used
weight: 1
tool: Agent
min: 0
max: 0
---

The prompt supplies the inventory and asks for the numbers before anything runs,
so a spawn here is a violation of the matrix-print gate rather than a cost
problem. Checked from the trace, because `allowed_tools` does not reliably gate
the `Agent` tool on this harness.
