---
title: 02 — Domain (Project-specific core)
owner: Domain Lead
priority: P0
version: 1.0.0
status: draft
last_reviewed: 2026-04-29
classification: internal
---

# 02 — Domain

> Project-н **уникал domain**-ийн дотоод үйлчилгээний дэлгэрэнгүй.
>
> ⚠ **Section name-ыг project-д тохируулж нэрлэх**:
> - PKI/CA → `02-pki/`
> - Payment → `02-payments/`
> - AI platform → `02-ml-platform/`
> - E-commerce → `02-marketplace/`
> - Identity provider → `02-identity/`

## Document жагсаалт (PKI жишээгээр)

| Файл | Template |
|---|---|
| `key-ceremony-procedure.md` | [procedure.md](../../templates/procedure.md) |
| `hsm-operations-manual.md` | [runbook.md](../../templates/runbook.md) |
| `pki-profile-spec.md` | [design-doc.md](../../templates/design-doc.md) |
| `key-rotation-lifecycle.md` | [policy.md](../../templates/policy.md) |
| `cryptography-policy.md` | [policy.md](../../templates/policy.md) |
| `revocation-procedure.md` | [procedure.md](../../templates/procedure.md) |

## Document жагсаалт (Payment processor жишээ)

| Файл | Template |
|---|---|
| `payment-flow-spec.md` | design-doc.md |
| `merchant-onboarding-procedure.md` | procedure.md |
| `chargeback-handling.md` | runbook.md |
| `risk-scoring-policy.md` | policy.md |
| `pci-dss-compliance.md` | policy.md |

## Document жагсаалт (AI/ML жишээ)

| Файл | Template |
|---|---|
| `model-training-procedure.md` | procedure.md |
| `model-evaluation-policy.md` | policy.md |
| `data-pipeline-spec.md` | design-doc.md |
| `ml-incident-response.md` | runbook.md |

## RACI

- **R**: Domain Lead (e.g., CA Officer, Payment Architect)
- **A**: CTO
- **C**: Architect, Audit Lead
- **I**: Бүх engineer

## Review cadence

- 12 сар + том өөрчлөлт (key rotation, infra change).

## Nuance

Domain-ы dependency бол project-н core. Энэ section-ийн docs нь нэн нарийн
байх ёстой — кодыг хэрхэн хэрэгжүүлэх, аюулгүй байдлын чухал шинж нь юу
гэдгийг тус нөхцөл байдалд хадгална.
