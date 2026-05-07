---
title: Документжуулалтын Master Plan
owner: Project Lead
priority: P0
version: 1.0.0
status: draft
last_reviewed: 2026-04-29
next_review: 2026-05-29
classification: internal
---

# <PROJECT_NAME> — Documentation Plan

## 1. Зорилго

<PROJECT_NAME>-ийн хийгдсэн **бүх ажил**-ыг бүрэн баримтжуулна. Зорилго:

1. **Зохицуулагчийн өмнө** compliance хадгалах.
2. **Production эрсдэл бууруулах** — single-host уналт эсвэл ажилтан
   өөрчлөгдсөн тохиолдолд "ор уураар" сэргэх боломжтой баримттай байх.
3. **Integrator-ийг өөрөө integrate** хийдэг болгох.
4. **End-user хэрэглээ** — гарын авлага, FAQ, troubleshooting.
5. **Шинэ инженер 1 долоо хоногт** production-д ажиллах түвшин.

## 2. Document формат

- **Source**: Markdown (`.md`) — Git дотор versioned. Гол баримт.
- **Distribution**: Word (`.docx`) — `gerege-doc-toolkit`-аар auto-gen.
- **Хөрвүүлэх**:
  ```bash
  ../gerege-doc-toolkit/scripts/build.sh documentation/
  ```
- **Dist хадгалалт**: `dist/` нь `.gitignore` дотор. Customer-д өгөх final
  docx-ийг тусад нь release дотор.

## 3. Хэлбэр / Style guide

| Зүйл | Стандарт |
|---|---|
| Хэл | Монгол хэл (Cyrillic) primary; англи нэр томъёо |
| Толгой | YAML frontmatter (заавал бөглөх) |
| Гарчиг | `#` нэг л title-д. `##`, `###`, `####` хэрэглэгдэнэ |
| Хүснэгт | Markdown table |
| Код | ```bash, ```yaml, ```sql — pandoc tango syntax-highlight |
| Зураг | Mermaid block эсвэл `documentation/03-technical/diagrams/*.mmd` |
| Линк | Харьцангуй замаар |
| Огноо | ISO 8601 (`2026-04-29`) |

## 4. Бичих дараалал (priority order)

### Долоо хоног 1-2 (P0 — Хууль зүй)

```
[ ] 01-legal/privacy-notice.md
[ ] 01-legal/terms-of-service.md
[ ] 01-legal/<additional legal docs project-аас хамаарна>
```

### Долоо хоног 3 (P0 — Domain)

```
[ ] 02-domain/<domain-specific docs>
```

### Долоо хоног 4-5 (P0 — Operations)

```
[ ] 04-operations/operations-runbook.md
[ ] 04-operations/incident-response-playbook.md
[ ] 04-operations/disaster-recovery-plan.md
[ ] 04-operations/backup-restore-drill.md
[ ] 04-operations/network-diagram.md
[ ] 04-operations/sla-slo.md
[ ] 04-operations/monitoring-alerting.md
[ ] 04-operations/on-call-handbook.md
```

### Долоо хоног 6-7 (P1 — Technical)

```
[ ] 03-technical/api/<service>-openapi.yaml
[ ] 03-technical/database/schema.dbml
[ ] 03-technical/database/er-diagram.md
[ ] 03-technical/diagrams/*.mmd (sequence diagrams)
[ ] 03-technical/architecture/c4-{context,container,component}.md
[ ] 03-technical/threat-model.md
```

### Долоо хоног 8 (P1 — Integration)

```
[ ] 05-integration/onboarding-guide.md
[ ] 05-integration/integration-cookbook.md
[ ] 05-integration/error-code-reference.md
[ ] 05-integration/rate-limit-quotas.md
```

### Долоо хоног 9 (P1 — End-user)

```
[ ] 06-end-user/<user>-manual.md
[ ] 06-end-user/<role>-admin-manual.md
[ ] 06-end-user/faq-troubleshooting.md
```

### Долоо хоног 10 (P2 — Engineer)

```
[ ] 07-engineer/new-engineer-onboarding.md
[ ] 07-engineer/local-development-guide.md
[ ] 07-engineer/testing-strategy.md
[ ] 07-engineer/coding-standards.md
[ ] 07-engineer/release-process.md
[ ] 07-engineer/adr/0001-*.md ... 0008-*.md (initial ADRs)
```

### Долоо хоног 11 (P2 — Audit)

```
[ ] 08-audit-evidence/pentest-report-template.md
[ ] 08-audit-evidence/annual-security-review-template.md
[ ] 08-audit-evidence/sbom/*.md
```

### Долоо хоног 12 (P2 — Business)

```
[ ] 09-business/pricing-plan.md
[ ] 09-business/customer-support-sla.md
[ ] 09-business/master-service-agreement-template.md
```

## 5. Хариуцлага хуваарилалт (RACI)

| Хэсэг | Responsible | Accountable | Consulted | Informed |
|---|---|---|---|---|
| 01-legal | <legal advisor> | CEO | CTO, COO | All teams |
| 02-domain | <domain lead> | CTO | Architect, Audit | Engineers |
| 03-technical | Tech Lead | CTO | Stack leads | Integrators |
| 04-operations | SRE Lead | CTO | On-call | Engineers |
| 05-integration | Backend Lead | CTO | Sales, Tech Lead | Customer |
| 06-end-user | Product / UX | CEO | Support | End-users |
| 07-engineer | Tech Lead | CTO | All engineers | New hires |
| 08-audit-evidence | Audit Lead | CTO | External auditor | Board |
| 09-business | COO | CEO | Sales, Legal | Customer |

## 6. Quality gates

Документ "approved" болохын тулд:

```
[ ] Frontmatter бөглөгдсөн
[ ] Markdown lint pass
[ ] Linkcheck pass
[ ] Reviewer signoff
[ ] Owner approval
[ ] (legal) Хууль зүйн зөвлөгчийн гарын үсэг
[ ] Word output generated
```

## 7. Шинэчлэх trigger

| Trigger | Документ |
|---|---|
| Зохицуулалтын хууль өөрчлөгдсөн | 01-legal/* |
| Шинэ HSM key үүсгэх | 02-domain/key-ceremony-procedure.md |
| API endpoint нэмсэн | 03-technical/api/* + 05-integration/error-code-reference.md |
| DB migration нэмсэн | 03-technical/database/* |
| Production incident гарсан | 04-operations/incident-response-playbook.md |
| Шинэ integrator | 05-integration/* |
| App store release | 06-end-user/app-store-listing-assets.md |
| Шинэ engineer элссэн | 07-engineer/new-engineer-onboarding.md |
| Annual pentest | 08-audit-evidence/* |
| Pricing өөрчилсөн | 09-business/pricing-plan.md |

## 8. Хуваарь (Gantt)

```
Долоо хоног   01    02    03    04    05    06    07    08    09    10    11    12
01-legal      ████  ████
02-domain                 ████
04-operations                   ████  ████
03-technical                                ████  ████
05-integration                                          ████
06-end-user                                                   ████
07-engineer                                                         ████
08-audit                                                                  ████
09-business                                                                     ████
```

## 9. Анхаарах өөр зүйл

- **Нууцыг бичихгүй**. Real key, password, real API token энд орох ёсгүй.
  `<<EXAMPLE_API_KEY>>` эсвэл `***REDACTED***` placeholder ашигла.
- **Бодит огноог бичих** — "удахгүй" гэж бичихгүй; огноо тавь эсвэл `<<TBD>>`.
- **Зөрчилтэй мэдээллийг үлдээхгүй** — нэгийг засах эсвэл нөгөөг зааж өгнө.
- **Public хуудаст sensitive орохгүй** — classification зөв тогтоо.
