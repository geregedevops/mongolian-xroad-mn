# <PROJECT_NAME> — Documentation

<!-- Энэ нь scaffold template. scaffold.sh-аар copy хийгдсэний дараа
     <PROJECT_NAME> placeholder-ыг өөрийн project-н нэрээр сольно. -->

> **<PROJECT_NAME>**-ийн **бүх ажил, бүх шийдвэр, бүх процесс**-ыг бүрэн,
> нарийвчилсан, дараагийн инженер/операторын тэр чигтээ үргэлжлүүлж чадахаар нь
> баримтжуулсан **нэгдсэн архив**.
>
> Энэ фолдер нь монорепо-той хамт versioned. PR / commit бүрд эдгээр документыг
> шинэчлэх ёстой. Кодын өөрчлөлт нь архитектур, аюулгүй байдал, эсвэл үйл
> ажиллагаанд нөлөөлж байвал, тус тохирох документыг **тэр PR-д хамт**
> шинэчилнэ.

## Үндсэн зарчим

1. **Single source of truth** — нэг асуултанд нэг л зөв хариулт.
2. **Versioned and dated** — документ бүр толгойдоо `version`, `last_reviewed`,
   `owner` талбартай.
3. **Монгол хэлээр контент, англиар нэр томъёо**.
4. **Аудит ул мөртэй** — гарын үсэг зурсан documentуудыг `08-audit-evidence/`
   дотор хадгална.

## Бүтэц

```
documentation/
├── README.md                        ← энэ файл (master index)
├── 00-PLAN.md                       ← бичих төлөвлөгөө + урагшлал
│
├── 01-legal/                        ← Хууль зүй / Compliance (P0)
├── 02-domain/                       ← Project-specific core (P0/P1)
├── 03-technical/                    ← Technical reference (P1)
│   ├── api/                         (OpenAPI specs)
│   ├── database/                    (DBML, ER)
│   ├── diagrams/                    (Mermaid)
│   └── architecture/                (C4)
├── 04-operations/                   ← Operations / SRE (P0)
├── 05-integration/                  ← External integrators (P1)
├── 06-end-user/                     ← End-user docs (P1)
├── 07-engineer/                     ← Engineer docs (P2)
│   └── adr/                         (Architecture Decision Records)
├── 08-audit-evidence/               ← Audit trail (P1)
│   └── sbom/                        (Software Bill of Materials)
└── 09-business/                     ← Business / Commercial (P2)
```

(Project-аас хэрэгтэй section-уудыг үлдээж бусдыг устгана.)

## Тэргүүлэх ач холбогдол

| Тэмдэглэгээ | Утга | Хугацаа |
|---|---|---|
| **P0** | Хууль зүйн / production-ийн блокер | 4-6 долоо хоног |
| **P1** | Бизнес өсөлт ба operational reliability | 4-8 долоо хоног |
| **P2** | Engineering hygiene + аудитын материал | 6-10 долоо хоног |

## Документ бүрийн толгойн стандарт

```yaml
---
title: <Documentийн нэр>
owner: <хариуцагчийн нэр / role>
priority: P0 | P1 | P2
version: 1.0.0
status: draft | review | approved | retired
last_reviewed: 2026-04-29
next_review: 2026-10-29
classification: public | internal | confidential | restricted
---
```

Дэлгэрэнгүй: [`<toolkit-path>/blueprint/FRONTMATTER.md`](../../gerege-doc-toolkit/blueprint/FRONTMATTER.md)

## Шинэ инженерт зориулсан унших дараалал

1. `/README.md` (project root) — 5 минутад платформын ерөнхий дүр
2. `/CLAUDE.md` (хэрэв байгаа бол) — production топологи + service
3. `documentation/03-technical/architecture/c4-context.md` → `c4-container.md`
4. Үйлчлэх service-ийнхээ `documentation/03-technical/api/*.yaml`
5. `documentation/07-engineer/new-engineer-onboarding.md`
6. `documentation/04-operations/operations-runbook.md`

## End-user-д зориулсан унших дараалал

1. `documentation/06-end-user/citizen-user-manual.md` (или адил)
2. `documentation/06-end-user/mobile-faq-troubleshooting.md`
3. `documentation/01-legal/privacy-notice.md`
4. `documentation/01-legal/subscriber-agreement.md`
5. `documentation/01-legal/terms-of-service.md`

## Integrator / Partner-д зориулсан унших дараалал

1. `documentation/05-integration/onboarding-guide.md`
2. `documentation/03-technical/api/backend-openapi.yaml`
3. `documentation/05-integration/integration-cookbook.md`
4. `documentation/05-integration/error-code-reference.md`
5. `documentation/05-integration/rate-limit-quotas.md`
6. `documentation/01-legal/relying-party-agreement.md`

## Документын review цикл

| Documentийн төрөл | Review давтамж | Шалгуур |
|---|---|---|
| 01-legal/* | 6 сар + хууль өөрчлөгдсөн өдөр | Зөвлөгчийн гарын үсэг |
| 02-domain/* | 12 сар + том өөрчлөлт | Domain Lead approval |
| 03-technical/* | Том release бүрд | Tech Lead approval |
| 04-operations/* | 3 сар + incident бүрийн дараа | SRE Lead |
| 05-integration/* | API change бүрд | Backend Lead |
| 06-end-user/* | UI change бүрд + 6 сар | Product/UX |
| 07-engineer/* | Том рефактор бүрд | Tech Lead |
| 08-audit-evidence/* | Pen-test, SOC review бүр дараа | Audit Lead |
| 09-business/* | 12 сар + үнэ өөрчлөгдсөн өдөр | CEO + COO |

## Урагшлал

[`00-PLAN.md`](./00-PLAN.md)-ыг харж урагшлал болон одоогийн status-ыг харна уу.

## Toolkit

Энэ documentation нь
[`gerege-doc-toolkit`](../gerege-doc-toolkit/)-аас scaffold-сэн.
Markdown source-ыг Word-руу хөрвүүлэх:

```bash
../gerege-doc-toolkit/scripts/build.sh documentation/
# → dist/documentation/**/*.docx
```
