# Examples — Frontmatter Reference

> Frontmatter гэдэг нь Markdown файлын хамгийн дээд хэсэгт байх YAML metadata
> блок. `gerege-doc-toolkit`-ийн нүүр хуудсыг автоматаар бөглөдөг.

## Файлын ерөнхий бүтэц

```markdown
---
title: Документын нэр
version: 1.0.0
status: draft
classification: internal
owner: Хариуцагч
last_reviewed: 2026-04-29
---

# 1. Эхний бүлэг

Энд таны бичиг бичиг эхэлнэ...

## 1.1 Дэд бүлэг

...
```

`---` хоёрын хооронд YAML; үлдсэн бүгд markdown.

## Frontmatter талбарууд

### Заавал

| Талбар | Утга | Жишээ |
|---|---|---|
| **`title`** | Документын нэр. Нүүр хуудаст том үсгээр гарна. | `Privacy Notice` |

### Сонгомол (нүүр хуудсанд гарна)

| Талбар | Утга | Жишээ |
|---|---|---|
| `version` | Документын хувилбар (semver зөвлөнө) | `1.0.0` |
| `status` | Одоогийн төлөв | `draft` / `review` / `approved` / `retired` |
| `priority` | Тэргүүлэх ач холбогдол | `P0` / `P1` / `P2` |
| `classification` | Нууцлалын зэрэглэл | `public` / `internal` / `confidential` / `restricted` |
| `owner` | Хариуцагч (нэр / role) | `CA Officer` |
| `effective_date` | Хүчин төгөлдөр болсон огноо (ISO 8601) | `2026-05-01` |
| `last_reviewed` | Сүүлд review хийгдсэн өдөр | `2026-04-29` |
| `next_review` | Дараагийн review хуваарь | `2026-10-29` |
| `oid` | PKI OID (string-аар bracket-тэй) | `"1.3.6.1.4.1.99999.1.1"` |
| `public_url` | Public URL хэрэв нийтлэгдсэн бол | `https://id.gerege.mn/legal/cp` |
| `subtitle` | Subtitle мөр (default: "Гэрэгэ Системс ХХК") | `Гэрэгэ Cloud` |
| `toc-title` | TOC heading (default: "Гарчиг") | `Contents` |
| `cover_footer` | Нүүр хуудсын доор гарах italic мөр | `Internal use only` |

### Pandoc-ийн стандарт талбарууд (адил ажиллана)

| Талбар | Утга |
|---|---|
| `author` | Зохиогчийн нэр |
| `date` | Огноо (`pandoc`-ийн стандарт format) |
| `lang` | Хэл код (`mn` / `en`) |

### Custom талбар

`scripts/cover-page.lua` дотор `fields` хүснэгтэн дотор шинэ мөр нэмж олон
custom field бичих боломжтой.

## YAML-ийн анхаарах нөхцөл

### 1. Зайтай зөв бичих

```yaml
title: Privacy Notice          # ✅ зайтай
title:Privacy Notice           # ❌ зайгүй
title : Privacy Notice         # ❌ key-ээс ; өмнө зайтай
```

### 2. Special characters quote хийх

```yaml
title: "Doc: with colon"       # ✅
title: Doc: with colon         # ❌ YAML parse error

oid: "1.3.6.1.4.1.99999.1.1"   # ✅ string гэдгийг тодорхой болгох
oid: 1.3.6.1.4.1.99999.1.1     # ❌ YAML number мет parse хийх
```

### 3. Нэгээс олон мөр

```yaml
description: |
  Урт тайлбар олон мөртэй
  бичиж болно.
```

### 4. Жагсаалт

```yaml
related:
  - certificate-policy.md
  - hsm-operations-manual.md
```

(`related` field гэхдээ default-аар нүүр хуудаст гарахгүй — frontmatter
дотор нэмэлт мэдээлэл хадгалах боломжтой.)

## Жишээ файлууд

### `01-simple-document.md`

Хамгийн жижиг хувилбар — title, version, owner л.

### `02-policy-document.md`

Policy / standard загвар — бүх field бөглөгдсөн.

### Бусад

```bash
# Жишээг хөрвүүлэх
../scripts/build.sh .
```

Гарах файл:

```
dist/01-simple-document.docx
dist/02-policy-document.docx
```

## Tips

### Tip 1 — Хэлбэрийг хадгалах

`---` мөрөөс өмнө **юу ч бичиж болохгүй**. Frontmatter заавал файлын эхэнд
байх ёстой.

```markdown
---                  # ← яг 1-р мөрөнд эхлэх ёстой
title: ...
---
```

### Tip 2 — Pre-commit hook-аар YAML validate

```bash
# .pre-commit-config.yaml
- repo: https://github.com/adrienverge/yamllint
  rev: v1.35.1
  hooks:
    - id: yamllint
      files: \.md$
```

Эсвэл хялбар: `python3 -c "import yaml, sys; yaml.safe_load(open(sys.argv[1]))" file.md`.

### Tip 3 — Status flow

```
draft  →  review  →  approved  →  (retired сүүлд)
```

`retired` болсон document нь устгахаас илүү статусыг хадгалах нь дээр
(аудит trail).

### Tip 4 — Хувилбарын ялгал

Major өөрчлөлт (1.0.0 → 2.0.0) — backward incompatible.
Minor (1.0.0 → 1.1.0) — шинэ section нэмсэн.
Patch (1.0.0 → 1.0.1) — typo fix.

### Tip 5 — Classification

| Зэрэглэл | Хэн уншина | Жишээ |
|---|---|---|
| public | Хэн ч | Privacy notice, ToS |
| internal | Гэрэгэ ажилчид | Engineering docs, runbook |
| confidential | Зөвхөн NDA-тай | HSM ops, key ceremony |
| restricted | Top-tier (CTO, CEO) | Compromise post-mortem, exec memo |

## Common error messages

| Error | Fix |
|---|---|
| `YAML parse exception at line N` | YAML syntax шалгах. Special char-ийг quote. |
| `mapping values are not allowed in this context` | Утгадаа colon (`:`) бий — quote хийх |
| `did not find expected node content` | Indentation буруу — нэг түвшинд зайтай |

## See also

- [Pandoc YAML metadata block](https://pandoc.org/MANUAL.html#extension-yaml_metadata_block)
- [YAML 1.2 spec](https://yaml.org/spec/1.2.2/)
