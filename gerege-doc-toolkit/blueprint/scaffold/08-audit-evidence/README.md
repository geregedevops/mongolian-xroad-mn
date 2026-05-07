---
title: 08 — Audit Evidence
owner: Audit Lead / CISO
priority: P1
version: 1.0.0
status: draft
last_reviewed: 2026-04-29
classification: internal
---

# 08 — Audit Evidence

> Гадаад аудитор / зохицуулагчид өгөх **бэлэн нотолгоо**.

## Sub-folder бүтэц

```
08-audit-evidence/
├── README.md                          (энэ файл)
├── pentest-report-template.md         ← annual pen test
├── annual-security-review-template.md
├── vulnerability-scan-template.md     ← weekly / monthly
├── sbom/                              (Software Bill of Materials)
│   ├── README.md
│   ├── go-modules.md
│   ├── npm-packages.md
│   ├── swift-packages.md
│   └── gradle-deps.md
├── post-mortems/                      ← incident dump
│   └── YYYY-MM-DD-<title>.md
├── backup-drills/                     ← monthly drill reports
│   └── YYYY-MM.md
├── key-ceremonies/                    ← signed witness sheets
├── pentest-reports/                   ← actual reports (encrypted)
│   └── YYYY-QN-<vendor>.pdf.gpg
├── data-retention-audits/             ← annual compliance check
│   └── YYYY.md
└── legal-signed/                      ← scanned PDFs of signed legal docs
```

## Document жагсаалт

| Файл | Template |
|---|---|
| `pentest-report-template.md` | (template хэвээр; бодит report тус тусдаа) |
| `annual-security-review-template.md` | (SOC 2-loose) |
| `vulnerability-scan-template.md` | (template) |
| `sbom/<ecosystem>.md` | (table-heavy custom) |
| `post-mortems/YYYY-MM-DD-*.md` | [post-mortem.md](../../templates/post-mortem.md) |

## RACI

- **R**: Audit Lead
- **A**: CTO
- **C**: External auditor
- **I**: Board

## Review cadence

- Pen-test, SOC review бүрийн дараа.
- Annual full audit.

## Хадгалах журам

- Бүх audit document version-аар маркировлогдсон.
- Sensitive (pen test detail) нь PGP encrypted.
- 7 жил retention минимум.
- Гадаад auditor-аас VPN + time-boxed read access.

## Sensitivity

`08-audit-evidence/*` ихэнхи нь **internal**. Pen test result-уудыг
**confidential** + PGP encrypted. Public summary report-ыг
`08-audit-evidence/public/` дотор.
