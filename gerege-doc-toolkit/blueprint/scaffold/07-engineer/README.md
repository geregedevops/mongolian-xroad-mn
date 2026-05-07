---
title: 07 — Engineer / Developer
owner: Tech Lead
priority: P2
version: 1.0.0
status: draft
last_reviewed: 2026-04-29
classification: internal
---

# 07 — Engineer / Developer

> Шинэ engineer 1 долоо хоногт production-д ажиллах түвшин олох гарын авлага.
> ADR (Architecture Decision Record)-ууд.

## Document жагсаалт

| Файл | Template |
|---|---|
| `new-engineer-onboarding.md` | [runbook.md](../../templates/runbook.md) |
| `local-development-guide.md` | runbook.md |
| `testing-strategy.md` | [policy.md](../../templates/policy.md) |
| `coding-standards.md` | policy.md |
| `pr-review-checklist.md` | (checklist) |
| `release-process.md` | [procedure.md](../../templates/procedure.md) |
| `mobile-signing-certificate-handling.md` (e.g.) | runbook.md |
| `adr/0001-*.md` ... `adr/NNNN-*.md` | [adr.md](../../templates/adr.md) |

## ADR — Architecture Decision Records

`adr/` фолдер дотор. Нэр format: `NNNN-short-kebab-title.md` (zero-padded
4-digit).

ADR нь "**яагаад тэр шийдвэр гаргасан вэ**" гэдгийг хадгалдаг — кодын
commit-аас илүү дэлгэрэнгүй. Status: proposed → accepted → superseded → retired.

Жишээ:

```
adr/
├── 0001-backend-framework.md
├── 0002-database-choice.md
├── 0003-auth-strategy.md
├── 0004-monorepo-vs-polyrepo.md
├── 0005-deployment-platform.md
└── ...
```

ADR template: [`templates/adr.md`](../../templates/adr.md).

## RACI

- **R**: Tech Lead
- **A**: CTO
- **C**: All engineers
- **I**: New hires

## Review cadence

- Том рефактор бүрд.
- Шинэ ADR — шийдвэр бүрд (immediate).
- Coding standard / onboarding — 12 сар.

## Шинэ engineer-руу шилжүүлэх

Onboarding-ийн дараа `new-engineer-onboarding.md`-ийг тус engineer-аар
review хийлгэж rough edge засах. "Day 1, 2, 3, 4, 5, 6, 7" plan хадгалагдсан.

## Code style configs

`07-engineer/coding-standards.md`-аас гадна repo-д configs:

```
.golangci.yml         (Go)
.eslintrc.json        (TS/JS)
.prettierrc           (TS/JS)
.swiftlint.yml        (Swift)
detekt.yml            (Kotlin)
.editorconfig         (universal)
```

CI-аар enforce.
