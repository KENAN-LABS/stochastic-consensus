---
type: regex
weight: 1
target: last_message
pattern: "\\btotal\\b[^\\n]{0,60}\\b23\\b"
flags: "i"
---

Duplicate of `total-is-23.md` in intent — kept separate because this file also
records why this case carries no `llm` grader at all.

It had one. It failed 3/3 twice, on two runs whose matrices were correct in
every respect the rubric named — right unit demoted, core untouched, traces at
3, reduction stated, all six units present. The first rubric failed because its
FAIL-if clauses matched text inside the alternatives the answer offered after
committing to the right decision. The second failed after that was fixed, on a
rubric long enough that the default judge could not hold it against a long
answer.

Every claim in that rubric is mechanical, and `CONTRIBUTING.md` says to prefer a
free grader wherever that is true. So the rubric became six regexes. They cost
nothing, they cannot return a 2-1 split, and they cannot fail correct output —
which a judge did, four times, at real expense.
