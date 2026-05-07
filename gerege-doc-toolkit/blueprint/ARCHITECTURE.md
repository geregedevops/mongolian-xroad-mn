# Documentation Architecture Standard

> **Гэрэгэ-ийн Documentation Standard v1.0** — баримт бичгийн фолдер бүтэц,
> файлын нэрлэлт, frontmatter, lifecycle, RACI бүх хүн нийтлэгээр дагах
> standard.

## 1. Зорилго

Дараах асуудлуудыг шийдвэрлэнэ:

1. **Discoverability** — Хэн ч "энэ документ хаана байх ёстой вэ?" хэлэхгүй.
   Section дугаараар тэр дороо олно.
2. **Consistency** — Project бүр ижил хэлбэртэй. Engineer A → Engineer B
   шилжихэд retraining шаардахгүй.
3. **Auditability** — Гадаад auditor / зохицуулагч бүх project-той ижил
   structure-аар танилцах.
4. **Lifecycle hygiene** — Document бүр "хэн эзэмшдэг", "хэзээ review хийгдэх"
   тодорхой.
5. **Audience clarity** — Иргэн, RP, engineer, audit бүх audience тус тусын
   read-order авах боломжтой.

## 2. Үндсэн зарчим

### 2.1 Single source of truth

Нэг асуултанд нэг л зөв хариулт. Зөрчилтэй мэдээллийг хэзээ ч үлдээхгүй.

### 2.2 Versioned + dated

Документ бүр `version` + `last_reviewed` + `status` талбартай. Хувилбар
semver-аар (1.0.0).

### 2.3 Public-by-default үгүй

Document бүр `classification` талбартай:

- `public` — олон нийт уншиж болно
- `internal` — Гэрэгэ ажилчид
- `confidential` — NDA-той хүн
- `restricted` — Top-tier (CTO, CEO)

Default нь `internal`.

### 2.4 Markdown source, Word output

Source нь `.md` (git-friendly, diff-able). Word docx нь output (gerege-doc-toolkit-аар
generate).

### 2.5 Хэлээр

Контент **монгол хэл (Cyrillic)**. Нэр томъёо, кодын код **англи хэл**. Энэ нь:

- Mongolian audience-аар ойлгомжтой.
- Code identifier-ууд globally readable.
- Translation хэрэглэгдэх үед Cyrillic body, English code.

### 2.6 Audit-able шинж

Document-ийн өөрчлөлт бүгд git-аар track. Approval нь PR review.

## 3. Folder structure

```
documentation/                      ← (any name OK; "documentation" recommended)
├── README.md                       ← Master index (read order, sections list)
├── 00-PLAN.md                      ← Execution plan (priorities, RACI, cadence)
│
├── 01-legal/                       ← Compliance, contracts, policy
├── 02-domain/                      ← Project-specific core (renaming OK)
├── 03-technical/                   ← API, schema, diagrams, design
│   ├── api/                        ← OpenAPI YAML
│   ├── database/                   ← DBML, ER diagram
│   ├── diagrams/                   ← Mermaid sequence/architecture
│   └── architecture/               ← C4 context/container/component
├── 04-operations/                  ← Runbook, IR, DR, monitoring
├── 05-integration/                 ← External integrators (RP, partners)
├── 06-end-user/                    ← Citizen / admin manuals
├── 07-engineer/                    ← Onboarding, ADR, coding standards
│   └── adr/                        ← Architecture Decision Records
├── 08-audit-evidence/              ← Pen test, SBOM, audit trail
│   └── sbom/                       ← Software Bill of Materials
└── 09-business/                    ← Pricing, MSA, SLA
```

### Section дугаар яагаад?

- **01-09** prefix нь file system-ийн алфабит сортыг section reading order-той
  тэгшийнэ.
- Section нэмэх боломжтой (10-, 11-).
- Section устгах боломжтой (project-аар хязгаарлалт байхгүй).

### Section name-ыг өөрчилж болох уу?

| Section | Хатуу нэр? |
|---|---|
| 01-legal | Хатуу |
| 02-domain | Свободно (`02-pki`, `02-payments`, `02-identity` гэх мэт) |
| 03-technical | Хатуу |
| 04-operations | Хатуу |
| 05-integration | Свободно (`05-rp-integrator`, `05-partners`, `05-api-consumers`) |
| 06-end-user | Хатуу |
| 07-engineer | Хатуу |
| 08-audit-evidence | Хатуу |
| 09-business | Хатуу |

Хатуу section-ууд нь cross-project consistency-т чухал. Свободно section-ууд
нь project-н шинж чанарт тохируулагдана.

## 4. Document type taxonomy

Section дотор олон document type байж болно. Гол type-ууд:

| Type | Зорилго | Template |
|---|---|---|
| **Policy** | "Юу зөвшөөрөгдсөн / хориотой" — high-level rule | `templates/policy.md` |
| **Standard** | "Юуг яаж хийх ёстой" — detailed | `templates/policy.md` |
| **Procedure** | Step-by-step үйлдлийн дараалал | `templates/procedure.md` |
| **Runbook** | Operations-д өдөр тутмын команд | `templates/runbook.md` |
| **Playbook** | Incident response сценари тус бүрд | `templates/incident-playbook.md` |
| **ADR** | Architecture Decision Record | `templates/adr.md` |
| **Post-mortem** | Incident-ний дараах review | `templates/post-mortem.md` |
| **API spec** | OpenAPI YAML | `templates/api-spec.yaml` |
| **User manual** | End-user гарын авлага | `templates/user-manual.md` |
| **FAQ** | Q&A | `templates/faq.md` |
| **Threat model** | STRIDE per service | `templates/threat-model.md` |
| **Design doc** | Шинэ feature design | `templates/design-doc.md` |
| **Meeting notes** | Шийдвэр гаргасан уулзалт | `templates/meeting-notes.md` |

## 5. Frontmatter standard

`.md` файл бүрд YAML frontmatter заавал:

```yaml
---
title: Документын нэр
owner: Хариуцагч (нэр / role)
priority: P0 | P1 | P2
version: 1.0.0
status: draft | review | approved | retired
last_reviewed: 2026-04-29
next_review: 2026-10-29
classification: public | internal | confidential | restricted
---
```

Дэлгэрэнгүй [FRONTMATTER.md](./FRONTMATTER.md).

## 6. File naming

```
kebab-case-english.md
```

Дүрэм:

- **kebab-case** (`hsm-operations-manual.md`).
- **Англи** (Cyrillic file name search-friendly биш).
- **Нэг файл — нэг утга** (хоёр зүйлийг нэг файлд бичихгүй).
- **Дугаарлалт ADR-д** — `0001-fiber-v2-framework.md` (zero-padded 4 digit).

## 7. Status lifecycle

```
draft → review → approved
                    ↓
                 retired
```

| Status | Утга |
|---|---|
| `draft` | Бичиж байна. Бусад нь reference хийхгүй. |
| `review` | Reviewer-т явсан. Кодын баримт хүчинтэй боловч төгс биш. |
| `approved` | Гарын үсэг зурагдсан. Production-д хүчинтэй. |
| `retired` | Хуучирсан. Replace-аар сольсон. Линк зөв шилжүүлэгдэх ёстой. |

## 8. RACI

Section бүр өөрийн RACI-тай. Default матриц:

| Section | Responsible | Accountable | Consulted | Informed |
|---|---|---|---|---|
| 01-legal | Хууль зүйн зөвлөх | CEO | CTO, COO | Бүх багийнхан |
| 02-domain | Domain Lead | CTO | Architect, Audit | Бүх инженерчүүд |
| 03-technical | Tech Lead | CTO | Backend/Mobile/Web Lead | RP integrator |
| 04-operations | SRE Lead | CTO | On-call, Backend Lead | Бүх инженерчүүд |
| 05-integration | Backend Lead | CTO | Sales, Tech Lead | Customer |
| 06-end-user | Product / UX | CEO | Support, Mobile Lead | Иргэн |
| 07-engineer | Tech Lead | CTO | All engineers | New hires |
| 08-audit-evidence | Audit Lead | CTO | External auditor | Board |
| 09-business | COO | CEO | Sales, Legal | RP |

Project-аар RACI-ыг тохируулна (e.g., COO-гүй жижиг team дотор COO-ыг CEO-аар орлуулах).

## 9. Review cadence

| Section | Review давтамж | Trigger |
|---|---|---|
| 01-legal | 6 сар + хууль өөрчлөгдсөн өдөр | Хуулийн шинэчлэлт |
| 02-domain | 12 сар + том өөрчлөлт | Domain rotation, key event |
| 03-technical | Том release бүрд (semver minor) | API өөрчлөлт |
| 04-operations | 3 сар + incident бүрд | Incident review |
| 05-integration | API change бүрд | New integrator |
| 06-end-user | UI change бүрд + 6 сар | Шинэ feature |
| 07-engineer | Том рефактор бүрд | New tooling |
| 08-audit-evidence | Pen-test, SOC review бүр дараа | Annual audit |
| 09-business | 12 сар + үнэ өөрчлөгдсөн өдөр | Pricing change |

## 10. Quality gates

Document `approved` status-руу шилжихийн тулд:

```
[ ] Frontmatter бүгд бөглөгдсөн (owner, version, status, last_reviewed)
[ ] Markdown lint pass
[ ] Internal link шалгагдсан
[ ] Reviewer signoff (RACI-ийн consulted-аас 1+)
[ ] Owner approval (RACI-ийн responsible)
[ ] (legal) Хууль зүйн зөвлөгчийн гарын үсэг
[ ] (PKI) CA Officer + HSM Operator-ийн гарын үсэг
[ ] Word output generated (`gerege-doc-toolkit/scripts/build.sh`)
```

## 11. Adoption guide

### 11.1 Шинэ project-д

```bash
# Step 1: Toolkit-ыг clone эсвэл copy
git clone <toolkit-repo> /tmp/toolkit
cp -r /tmp/toolkit/gerege-doc-toolkit ./

# Step 2: Scaffold
./gerege-doc-toolkit/scripts/scaffold.sh ./documentation

# Step 3: README.md, 00-PLAN.md-ыг project-та тохируулах
$EDITOR documentation/README.md
$EDITOR documentation/00-PLAN.md

# Step 4: Section-уудаас шаардлагатайг үлдээж бусдыг устгах
rm -rf documentation/05-integration   # хэрвээ external integrator байхгүй бол

# Step 5: Эхний docs бичих (template-аас copy)
cp gerege-doc-toolkit/blueprint/templates/policy.md \
   documentation/01-legal/privacy-notice.md
$EDITOR documentation/01-legal/privacy-notice.md

# Step 6: Word generate
./gerege-doc-toolkit/scripts/build.sh documentation/
```

### 11.2 Хуучин project-д

Phased migration:

1. **Audit одоогийн docs** — file бүрийг section 01-09-руу map.
2. **Quick wins** — `04-operations/` (runbook, IR) хамгийн хэрэглээтэй.
3. **Section-аар** — нэг хуудсаар pull, frontmatter нэмэх.
4. **Linkcheck** — өмнөх линкүүдийг redirect.
5. **Sign-off** — section бүрд owner approve.

Бүгдийг нэг дор шилжүүлэх хэрэггүй — 1-2 сард section-аар хийж болно.

### 11.3 Project-н шинж чанарт зориулсан

| Project төрөл | Хэрэгтэй section |
|---|---|
| CA / PKI | 01-09 бүгд |
| Internal SaaS | 03, 04, 06, 07 |
| Open source lib | 03, 07 (+ 06 optional) |
| Banking | 01-09 бүгд + extra |
| Internal tooling | 03, 04, 07 |
| Mobile-only product | 03, 04, 06, 07 |

## 12. Анти-pattern

### 12.1 ❌ Нэр томъёотой folder

```
docs/
├── policies/
├── procedures/
├── runbooks/
└── design-docs/
```

→ Document type-аар хувааж буй (хүн уншихаар "юунд хайх вэ?" мэдэхгүй).

### 12.2 ❌ Project-domain хайх

```
docs/
├── auth/
├── sign/
├── kyc/
└── admin/
```

→ Domain-аар хуваагдсан — каждый domain-д ops, technical, legal хольсон болно.

### 12.3 ❌ Бүх docs-ыг root дээр

```
docs/
├── README.md
├── architecture.md
├── runbook.md
├── policy.md
├── ...50 файл...
```

→ Discoverability муу. 10+ файлтай бол sub-folder.

### 12.4 ❌ Frontmatter байхгүй

```markdown
# Privacy Notice

[content]
```

→ Хэн эзэмшиж байгаа, хэзээ review хийсэн, ямар status-тай мэдэгдэхгүй.

### 12.5 ❌ Approved-д Mongolian + retired-д англиар

→ Бүгд монгол. Хэлийг сольж болохгүй.

## 13. Common questions

### Q1: 02-domain-ыг яаж нэрлэх вэ?

Project-н core domain-аар:
- PKI-аар → `02-pki`
- Payment-аар → `02-payments`
- Identity-аар → `02-identity`
- AI / ML platform → `02-ml-platform`
- E-commerce → `02-marketplace`

### Q2: 02-domain хэт том болсон бол?

Sub-section-аар хуваах:
```
02-pki/
├── README.md
├── ca/
├── ocsp/
├── crl/
└── tsa/
```

Эсвэл шинэ section дугаар нэмэх (`10-`, `11-`).

### Q3: Сар тутмын review-ыг яаж track хийх вэ?

GitHub Actions cron + `last_reviewed`-аас 180 days хэтэрсэн docs-ыг
issue-аар flag хийх. (Future tooling — `scripts/audit-cadence.sh` enhancement.)

### Q4: Document version нь semver биш бол?

Date-аар хэрэгжүүлж болно (`version: 2026.04.29`). Гэхдээ semver-ийг зөвлөнө —
"breaking change vs feature add vs typo fix" ялгаа гарна.

### Q5: Multilang docs?

Гэрэгэ-д Mongolian primary. Англи хувилбар нь `<file>-en.md` (или `i18n/en/file.md`)
парallel-аар. Frontmatter-д `lang: mn` / `lang: en`. Authoritative нь Mongolian.

### Q6: External vendor docs (HSM manual гэх мэт)?

`08-audit-evidence/vendor-docs/` дотор архивлах. Source link + downloaded copy
(license зөвшөөрсөн бол).

## 14. Tooling

| Зүйл | Tool |
|---|---|
| Markdown → Word | `gerege-doc-toolkit/scripts/build.sh` |
| Folder scaffold | `gerege-doc-toolkit/scripts/scaffold.sh` |
| Link check | `markdown-link-check` (npm) |
| Lint | `markdownlint-cli` |
| Diagram render | Mermaid (auto by GitHub), `mmdc` for offline |
| YAML validate | `yamllint`, `python -c 'import yaml; ...'` |

## 15. Хувилбарын түүх

| Хувилбар | Огноо | Өөрчлөлт |
|---|---|---|
| 1.0.0 | 2026-04-29 | Initial standard (extracted from Гэрэгэ ID) |
