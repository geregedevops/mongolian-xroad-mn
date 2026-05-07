# Frontmatter Standard

> Бүх `.md` файлын эхэнд **YAML metadata block** заавал. Энэ нь tooling
> (gerege-doc-toolkit, link checker, status auditor) болон reader-уудыг
> автоматжуулна.

## 1. Минимум

```yaml
---
title: Документын нэр
owner: Хариуцагч
priority: P0 | P1 | P2
version: 1.0.0
status: draft | review | approved | retired
last_reviewed: 2026-04-29
classification: public | internal | confidential | restricted
---
```

## 2. Бүрэн schema

```yaml
---
# Заавал
title: <string>
owner: <string>
priority: P0 | P1 | P2
version: <semver>
status: draft | review | approved | retired
last_reviewed: <YYYY-MM-DD>
classification: public | internal | confidential | restricted

# Сонгомол
next_review: <YYYY-MM-DD>
effective_date: <YYYY-MM-DD>
public_url: <url>
oid: "<dotted.numeric.oid>"     # PKI projects
related:
  - <relative-path-to-md>
tags:
  - <tag>
authors:
  - <name>
deciders:                        # ADR only
  - <role>
date: <YYYY-MM-DD>               # Creation date (rare)
subtitle: <string>               # Cover page subtitle
toc-title: <string>              # Cover page TOC heading
cover_footer: <string>           # Cover page italic footer

# Customizable per project
team: <team name>
service: <service name>
component: <component name>
---
```

## 3. Field reference

### `title` (заавал)

Документын нэр. Word нүүр хуудаст том үсгээр гарна.

```yaml
title: Хувийн мэдээллийн нууцлалын мэдэгдэл
```

Special characters байвал quote:

```yaml
title: "Doc: with colon"
```

### `owner` (заавал)

Document-ийг хариуцаж буй хүн / role:

```yaml
owner: DPO              # role
owner: Б. Эрдэнэбат     # personal name
owner: SRE Team         # team
```

### `priority` (заавал)

| Утга | Утга |
|---|---|
| P0 | Хууль зүйн / production-ийн блокер |
| P1 | Бизнесийн өсөлт / operational reliability |
| P2 | Engineering hygiene / nice-to-have |

### `version` (заавал)

[Semver](https://semver.org/) — `MAJOR.MINOR.PATCH`.

```yaml
version: 1.0.0       # Major release
version: 1.2.3       # Minor + patch
version: 0.1.0       # Pre-release / draft
```

Date-based version-ыг бид зөвлөдөггүй (semver-ийг ялгаатай) — гэхдээ
ажилладаг:

```yaml
version: 2026.04.29  # ISO date as version
```

### `status` (заавал)

| Status | Утга |
|---|---|
| `draft` | Бичиж байна. Reference хийхгүй. |
| `review` | Reviewer-т явсан. |
| `approved` | Гарын үсэг зурагдсан. Production-д хүчинтэй. |
| `retired` | Хуучирсан. Replace-аар сольсон. |

### `last_reviewed` (заавал)

ISO 8601 дата (`YYYY-MM-DD`).

```yaml
last_reviewed: 2026-04-29
```

### `next_review` (сонгомол)

Дараагийн review хэзээ хийгдэх. Audit cadence-аар.

```yaml
next_review: 2026-10-29   # 6 months later
```

`scripts/audit-cadence.sh` (future) нь `last_reviewed`-аас хугацаа хэтэрсэн
docs-ыг flag хийнэ.

### `classification` (заавал)

| Class | Хэн уншина |
|---|---|
| `public` | Хэн ч |
| `internal` | Гэрэгэ ажилчид |
| `confidential` | NDA-той хүн |
| `restricted` | Top-tier (CTO, CEO) |

Default нь `internal` (хэрэв заагаагүй бол).

### `effective_date` (сонгомол)

Хэзээнээс хүчинтэй болсон. Эрхзүйн docs-д ихэвчлэн.

```yaml
effective_date: 2026-05-01
```

### `public_url` (сонгомол)

Хэрэв document нь нийтлэгдсэн бол тогтвортой URL.

```yaml
public_url: https://id.gerege.mn/legal/cp
```

### `oid` (сонгомол)

PKI зориулалттай. **Strings-ээр quote** хийх — YAML number мэт parse хийхгүй:

```yaml
oid: "1.3.6.1.4.1.99999.1.1"   # ✅ string
oid: 1.3.6.1.4.1.99999.1.1     # ❌ float parse error
```

### `related` (сонгомол)

Холбогдох документуудын жагсаалт:

```yaml
related:
  - certificate-policy.md
  - ../02-pki/key-ceremony-procedure.md
```

### `tags` (сонгомол)

Категориас гадуурх tag (search хэрэг):

```yaml
tags:
  - pki
  - security
  - audit
```

### `authors` (сонгомол)

Зохиогч / contributor-уудын жагсаалт. Owner-ээс бие даасан:

```yaml
authors:
  - Б. Эрдэнэбат
  - Я. Сэнгүм
```

### `deciders` (ADR only)

ADR-д шийдвэр гаргасан role/нэр-ийн жагсаалт:

```yaml
deciders:
  - CTO
  - Tech Lead
  - Backend Lead
```

### `subtitle` (cover page)

Default нь "Гэрэгэ Системс ХХК". Project-аар сольж болно:

```yaml
subtitle: Гэрэгэ Cloud Platform
```

### `toc-title` (cover page)

Default нь "Гарчиг". Англиар сольж:

```yaml
toc-title: Contents
```

### `cover_footer` (cover page)

Нүүр хуудсын доор италик мөр:

```yaml
cover_footer: Internal use only — Do not distribute
```

## 4. YAML-ийн анхаарах нөхцөл

### 4.1 Зайтай зөв бичих

```yaml
title: Privacy Notice          # ✅
title:Privacy Notice           # ❌ key-аас дараа зайгүй
title : Privacy Notice         # ❌ key-аас өмнө зайтай
```

### 4.2 Special characters quote хийх

| Эх утга | YAML |
|---|---|
| `Doc: title` | `title: "Doc: title"` |
| `1.2.3` (number-аар бичигдэхгүй) | `version: "1.2.3"` |
| `[link]` | `subtitle: "[link]"` |
| `# comment` | `cover_footer: "# 1 priority"` |

### 4.3 Multiline string

```yaml
description: |
  Урт олон мөр текст.
  Энд бичигдэнэ.

description: >
  Хоосон мөргүй,
  нэг урт мөр болж нэгдэнэ.
```

### 4.4 Жагсаалт format

```yaml
# 1) Inline (богино)
tags: [pki, security, audit]

# 2) Block
tags:
  - pki
  - security
  - audit
```

## 5. Жишээ — олон тохиолдол

### 5.1 Хууль зүйн public document

```yaml
---
title: Хувийн мэдээллийн нууцлалын мэдэгдэл
owner: DPO
priority: P0
version: 1.0.0
status: approved
last_reviewed: 2026-04-29
next_review: 2026-10-29
effective_date: 2026-05-01
classification: public
public_url: https://id.gerege.mn/privacy
authors:
  - DPO
  - Хууль зүйн зөвлөх
related:
  - terms-of-service.md
  - data-retention-deletion-policy.md
---
```

### 5.2 ADR

```yaml
---
title: ADR-0007 — Mobile Hardware Key Storage
status: accepted
date: 2026-04-06
deciders: Mobile Lead, Tech Lead
priority: P2
version: 1.0.0
classification: internal
---
```

### 5.3 Runbook

```yaml
---
title: Operations Runbook
owner: SRE Lead
priority: P0
version: 1.0.0
status: draft
last_reviewed: 2026-04-29
next_review: 2026-07-29
classification: internal
related:
  - incident-response-playbook.md
  - on-call-handbook.md
---
```

### 5.4 OpenAPI YAML (frontmatter биш — info section)

```yaml
openapi: 3.1.0
info:
  title: Gerege ID Backend API
  version: "1.0.0"
  description: |
    ...
  contact:
    email: support@gerege.mn
  license:
    name: Proprietary
```

OpenAPI YAML нь pandoc-аар хөрвүүлэгдэхгүй (yaml-аас docx нь). Stoplight /
Swagger UI-аар render хийнэ.

## 6. Validation

```bash
# CLI YAML check
python3 -c "
import yaml, sys
with open(sys.argv[1]) as f:
    text = f.read()
parts = text.split('---')
if len(parts) >= 3:
    yaml.safe_load(parts[1])
    print('OK')
" path/to/file.md

# Or yamllint
yamllint -d "{rules: {document-start: disable, line-length: disable}}" path/to/file.md
```

`scripts/validate-frontmatter.sh` (future) — батч check.

## 7. Required vs optional summary

| Field | Required | Default |
|---|---|---|
| title | ✅ | — |
| owner | ✅ | — |
| priority | ✅ | — |
| version | ✅ | — |
| status | ✅ | `draft` |
| last_reviewed | ✅ | — |
| classification | ✅ | `internal` |
| next_review | ⚠ | (recommended) |
| effective_date | (legal docs) | — |
| public_url | (public docs) | — |
| oid | (PKI docs) | — |
| related | optional | [] |
| tags | optional | [] |
| authors | optional | (owner) |

## 8. Хувилбарын түүх

| Хувилбар | Огноо | Өөрчлөлт |
|---|---|---|
| 1.0.0 | 2026-04-29 | Анхны schema (Гэрэгэ ID extract) |
