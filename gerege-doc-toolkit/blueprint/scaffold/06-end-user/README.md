---
title: 06 — End-User Documentation
owner: Product Lead / UX
priority: P1
version: 1.0.0
status: draft
last_reviewed: 2026-04-29
classification: public
---

# 06 — End-User Documentation

> Иргэн, customer, ААН-ийн админ зэрэг **end-user**-ийн гарт ороход бэлэн docs.
> Customer support track-ийн гол contentment.

## Document жагсаалт

| # | Файл | Template |
|---|---|---|
| 6.1 | `<user-type>-manual.md` (e.g., citizen-user-manual.md) | [user-manual.md](../../templates/user-manual.md) |
| 6.2 | `<role>-admin-manual.md` (e.g., organization-admin-manual.md) | user-manual.md |
| 6.3 | `<platform>-faq-troubleshooting.md` (e.g., mobile-faq-troubleshooting.md) | [faq.md](../../templates/faq.md) |
| 6.4 | `<feature>-manual.md` (e.g., desktop-usb-token-manual.md) | user-manual.md |
| 6.5 | `app-store-listing-assets.md` | (marketing-specific) |
| 6.6 | `localization-transliteration.md` | [policy.md](../../templates/policy.md) |
| 6.7 | `accessibility-statement.md` | policy.md |

## RACI

- **R**: Product Lead / UX
- **A**: CEO
- **C**: Support, Mobile Lead
- **I**: End-user

## Review cadence

- UI change бүрд.
- + 6 сар.

## PDF format

End-user docs нь PDF-аар тарагдана:

```bash
../../gerege-doc-toolkit/scripts/build.sh 06-end-user/
# → dist/06-end-user/*.docx
# Word-аар нээж File → Save As → PDF
```

## Best practice

- Хэлбэр нь "step-by-step" — number-аар.
- Screenshot оруулах — `06-end-user/screenshots/` фолдер.
- Хэт олон бичих хэрэггүй — "scan-able" структур (heading-аар, list-аар).
- "If A then B" нөхцөлийг table-аар.
- FAQ-д question нь **end-user өөрөө** асуух хэлбэрээр ("PIN мартсан үед яах вэ?").

## Sensitivity

`06-end-user/*` нь ихэвчлэн **public** classification. Internal-only handbook
бол `internal` гэж тэмдэглэх.
