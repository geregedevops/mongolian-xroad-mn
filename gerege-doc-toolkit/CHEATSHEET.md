# Cheatsheet

## Хамгийн үндсэн команд

```bash
# ═══ Build (Markdown → Word) ═══
./scripts/build.sh path/to/file.md             # Нэг файл
./scripts/build.sh path/to/folder/             # Фолдер бүхэлд
./scripts/build.sh -o /tmp/out path/to/folder/ # Custom output
./scripts/build.sh examples/                   # Жишээ test

# ═══ Scaffold (blueprint structure) ═══
./scripts/scaffold.sh ./documentation "Name"
./scripts/scaffold.sh ./docs "PKI" --domain-name 02-pki
./scripts/scaffold.sh ./docs "App" --skip 01-legal,09-business
```

## Шинэ project — 5 алхам

```bash
# 1. Toolkit-ыг хуулах
cp -r gerege-doc-toolkit /your/project/

# 2. Folder structure scaffold
./gerege-doc-toolkit/scripts/scaffold.sh ./documentation "Project"

# 3. Эхний docs (template-аас)
cp gerege-doc-toolkit/blueprint/templates/policy.md \
   documentation/01-legal/privacy-notice.md
$EDITOR documentation/01-legal/privacy-notice.md

# 4. Word generate
./gerege-doc-toolkit/scripts/build.sh documentation/

# 5. Open
open dist/documentation/01-legal/privacy-notice.docx
```

## Frontmatter

```yaml
---
title: Бичиг бичгийн нэр              # ЗААВАЛ
version: 1.0.0                       # сонгомол
status: draft                        # draft | review | approved | retired
priority: P1                         # P0 | P1 | P2
classification: internal             # public | internal | confidential | restricted
owner: Хариуцагч                     # сонгомол
effective_date: 2026-05-01           # YYYY-MM-DD
last_reviewed: 2026-04-29            # YYYY-MM-DD
next_review: 2026-10-29              # YYYY-MM-DD
public_url: https://...              # сонгомол
oid: "1.3.6.1.4.1.99999.1"          # сонгомол (string-аар бичих!)
---
```

## Layout

```
Page 1   →  Cover (title + subtitle + metadata + footer)
Page 2+  →  "Гарчиг" (auto-update TOC field)
Page N+  →  Body content
```

## Word дотор хийх 1 алхам

Гарчиг ("Update Field" placeholder-той) дээр **right-click → Update Field**.
Эсвэл бүгдийг сонгож **F9**.

## Markdown шорткат

```markdown
# Heading 1
## Heading 2
### Heading 3

**bold**, *italic*, ~~strikethrough~~, `code`

- bullet
- list
  - nested

1. numbered
2. list

| Col1 | Col2 |
|------|------|
| a    | b    |

```bash
code block
```

[link](https://example.com)
![image](path/image.png)

> blockquote

---

Footnote[^1]

[^1]: footnote text
```

## Common error → fix

| Error | Fix |
|---|---|
| `pandoc not found` | `brew install pandoc` |
| `template not found` | Toolkit folder-аас гадуур execute хийсэн — `cd gerege-doc-toolkit/` |
| `YAML parse error` | Frontmatter-ийн утгуудыг `:`-ээс хойш зайтай. Special chars-той бол `"..."` |
| `Гарчиг хоосон` | Word дотор гарчгийн placeholder дээр right-click → Update Field |
| `Logo харагдахгүй` | Template-ийг Word-аар нээж header дотор logo баталгаажуулна |

## Lua filter-ийг өөрчлөх

`scripts/cover-page.lua` дотор:

- **`fields = {...}`** — нүүр хуудаст гаргах metadata мөрүүд.
- **`styled_para("Title", title)`** — Word "Title" style ашигла. "Subtitle"-аар
  өөрчилж болно.
- **`toc_field()`** — TOC field-ийн агуулга. Mongolian/English placeholder
  текстийг өөрчлөх боломжтой.
- **`page_break()`** — page break helper. Шаардлагатай газарт нэмж болно.

## Бусад toolkit-уудтай нийцэх

| Tool | Comment |
|---|---|
| GitHub Actions | `pandoc` apt-аар суулгана. Build артефакт upload хийнэ. |
| GitLab CI | Same. |
| Make | `Makefile` бичиж `make docs` командаар target үүсгэх. |
| pre-commit | Markdown lint өмнө нь run хийх (markdownlint). |
