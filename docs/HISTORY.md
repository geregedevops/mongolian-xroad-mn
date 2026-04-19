# docs/ — operational history

## 2026-04-19 — Initial monorepo creation

Per-server folders created, configs gathered, READMEs written, secrets sanitized to `REDACTED`. Cross-cutting docs (`topology.md`, `pki-architecture.md`, `onboarding-new-member-ss.md`, `operational-gotchas.md`) authored from the running production state and the operator's local memory.

## What this folder is for going forward

- `topology.md` — keep updated whenever a new SS is added, ports change, or an IP rotates.
- `pki-architecture.md` — update when CA hierarchy changes (new intermediate, key rotation, EKU profile addition).
- `onboarding-new-member-ss.md` — whenever the partner-onboarding playbook gets new steps (e.g. new mandatory firewall rule), append here. Future partners + their consultants will rely on this being current.
- `operational-gotchas.md` — every time a new "I burned 2 hours debugging this" incident happens, append the symptom + cause + fix here. The point is to never burn that 2 hours twice.

## Watch list for the next maintainer

- The HISTORY.md files in each per-server folder capture chronological incidents. The cross-cutting `operational-gotchas.md` here de-duplicates by symptom — it's the first place an operator should look when something breaks. Keep both in sync.
- Diagrams in `topology.md` and `pki-architecture.md` are ASCII so they render in GitHub without external tooling. Don't replace with mermaid/PlantUML unless the GitHub render quality is verified — being readable in `git diff` matters more than being pretty.
