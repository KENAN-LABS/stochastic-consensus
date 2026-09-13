---
type: regex
weight: 1
target: last_message
pattern: "\\|\\s*web-client\\s*\\|\\s*peripheral"
flags: "i"
---

The reduction's tiebreak, checked deterministically.

`web-client` and `mobile` are both `supporting` and both hold three scopes, so
the tie breaks on smallest size — web-client at 24,800 goes before mobile at
31,200. This asserts web-client ends the run at `peripheral`.

Paired with `survived-mobile.md`, which asserts the other half. Demoting both, or
demoting the wrong one, fails one of the two.
