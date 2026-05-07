---
title: 05 — Integration / External Partners
owner: Backend Lead / Developer Relations
priority: P1
version: 1.0.0
status: draft
last_reviewed: 2026-04-29
classification: public
---

# 05 — Integration / External Partners

> Project-той **гадаад этгээд** (RP, partner, API consumer)-уудад зориулсан
> гарын авлага.
>
> ⚠ Section name-ыг project-д тохируулна:
> - PKI auth → `05-rp-integrator/`
> - Payment → `05-merchant-integration/`
> - API gateway → `05-api-consumers/`
> - Marketplace → `05-seller-onboarding/`

## Document жагсаалт

| # | Файл | Template |
|---|---|---|
| 5.1 | `onboarding-guide.md` | [user-manual.md](../../templates/user-manual.md) |
| 5.2 | `integration-cookbook.md` | user-manual.md |
| 5.3 | `webhook-sse-spec.md` | [api-spec.yaml](../../templates/api-spec.yaml) + [procedure.md](../../templates/procedure.md) |
| 5.4 | `error-code-reference.md` | (table-heavy custom) |
| 5.5 | `rate-limit-quotas.md` | [policy.md](../../templates/policy.md) |
| 5.6 | `sandbox-guide.md` | user-manual.md |
| 5.7 | `<protocol>-onboarding.md` (e.g., x-road-subsystem-onboarding.md) | procedure.md |

## RACI

- **R**: Backend Lead / Developer Relations
- **A**: CTO
- **C**: Sales, Tech Lead
- **I**: Customer

## Review cadence

- API change бүрд.
- + 6 сар.

## Public публикжуулалт

`https://<domain>/developers/` (planned).

GitHub Pages эсвэл MkDocs-аар render. SaaS бол [Stoplight](https://stoplight.io)
эсвэл [ReadMe](https://readme.com).

## Best practice

- Code жишээг **зөвхөн нэг хэлээр биш** — curl + JS + Go + Python (popular).
- "Hello world" example нь 5 минутын дотор run хийгдэх ёстой.
- Error code reference нь **тус code-аар filter хийгдэх** боломжтой.
- Sandbox env нь production-аас хатуу тусдаа.
