---
title: 04 — Operations / SRE
owner: SRE Lead / CTO
priority: P0
version: 1.0.0
status: draft
last_reviewed: 2026-04-29
classification: internal
---

# 04 — Operations / SRE

> Production эрсдэлийг бууруулна. Single-host уналт эсвэл ажилтан
> өөрчлөгдсөн тохиолдолд **үргэлжлүүлэх боломжтой** болгох операцийн материал.

## Document жагсаалт

| # | Файл | Template |
|---|---|---|
| 4.1 | `operations-runbook.md` | [runbook.md](../../templates/runbook.md) |
| 4.2 | `incident-response-playbook.md` | [incident-playbook.md](../../templates/incident-playbook.md) |
| 4.3 | `disaster-recovery-plan.md` | runbook.md |
| 4.4 | `backup-restore-drill.md` | [procedure.md](../../templates/procedure.md) |
| 4.5 | `on-call-handbook.md` | runbook.md |
| 4.6 | `monitoring-alerting.md` | runbook.md |
| 4.7 | `sla-slo.md` | [policy.md](../../templates/policy.md) |
| 4.8 | `network-diagram.md` | [design-doc.md](../../templates/design-doc.md) |
| 4.9 | `change-management.md` | procedure.md |
| 4.10 | `capacity-planning.md` | design-doc.md |

## RACI

- **R**: SRE Lead
- **A**: CTO
- **C**: Backend Lead, Domain Lead, Customer Support Lead
- **I**: Бүх engineer, CEO

## Review cadence

- Quarterly review (3 сар тутамд).
- After every SEV-0/1 incident (lessons learned section шинэчлэх).
- After major architecture change.

## Гарын үсэг зурах

`04-operations/*` бүгд **internal** classification. CTO + SRE Lead approval.
