---
title: 01 — Хууль зүй / Compliance
owner: Хууль зүйн зөвлөх / CEO
priority: P0
version: 1.0.0
status: draft
last_reviewed: 2026-04-29
classification: public
---

# 01 — Хууль зүй / Compliance

> Хуулийн / зохицуулалтын / гэрээний бүх баримт. Эдгээр документ нь **public
> web дээр** ихэвчлэн нийтлэгдэх ба customer + auditor + zохицуулагчид зориулагдсан.

## Document жагсаалт (тохирох ёстой template)

| Файл | Template | Заавал? |
|---|---|---|
| `privacy-notice.md` | [policy.md](../../templates/policy.md) | Хувийн мэдээлэл боловсруулдаг бол ✅ |
| `terms-of-service.md` | [policy.md](../../templates/policy.md) | Public-facing app-тай бол ✅ |
| `subscriber-agreement.md` | [policy.md](../../templates/policy.md) | End-user account-тай бол ✅ |
| `relying-party-agreement.md` | [policy.md](../../templates/policy.md) | Partner / RP-тэй бол ✅ |
| `certificate-policy.md` (CP) | [policy.md](../../templates/policy.md) | CA project-д ✅ (RFC 3647) |
| `certification-practice-statement.md` (CPS) | [policy.md](../../templates/policy.md) | CA project-д ✅ (RFC 3647) |
| `data-retention-deletion-policy.md` | [policy.md](../../templates/policy.md) | PII боловсруулдаг бол ✅ |
| `incident-disclosure-policy.md` | [policy.md](../../templates/policy.md) | Production system-д ✅ |
| `vulnerability-disclosure-policy.md` | [policy.md](../../templates/policy.md) | Public-facing service-д ✅ |
| `cookie-policy.md` | [policy.md](../../templates/policy.md) | Web app-тай бол ✅ |

## RACI

- **R**: Хууль зүйн зөвлөх (гадаад / ажилтан)
- **A**: CEO
- **C**: CTO, COO
- **I**: Бүх багийнхан

## Review cadence

- **6 сар** + хууль өөрчлөгдсөн өдөр (хүчин төгөлдөр болох өдөр).
- Routine: 12 сар.

## Public публикжуулалт

| Document | URL pattern |
|---|---|
| privacy-notice.md | `https://<domain>/privacy` |
| terms-of-service.md | `https://<domain>/terms` |
| cookie-policy.md | `https://<domain>/cookies` |
| certificate-policy.md | `https://<domain>/legal/cp` |
| ... | `https://<domain>/legal/<file>` |

URL тогтвортой байх — RP, Web archives, third-parties линкээр найдна.

## Гарын үсэг зурах

`01-legal/*` бүх документ зөвхөн дараах гарын үсэгтэй approved:

1. CEO эсвэл түүнтэй ижил эрхтэй ажилтан (legal binding).
2. Хууль зүйн зөвлөх (зохиолтын баталгаа).
3. CTO (технологийн нийцлийн баталгаа).

Гарын үсэг зурсан хувилбар нь PDF / scan-аар `08-audit-evidence/legal-signed/`
дотор хадгалагдана. `.docx` хувилбар нь distribute-д.

## Орчуулга

Хууль зүйн документ нь **монгол хэлээр** гарын үсэг зурагдана (хууль зүйн
эх хувилбар). Англи орчуулга нь зөвхөн **тайлбарын** зорилгоор гарна — зөрчил
гарвал монгол эх хувилбар хүчинтэй.
