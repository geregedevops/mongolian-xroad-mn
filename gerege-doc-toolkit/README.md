# Gerege Document Toolkit

> Markdown source-аас **Гэрэгэ Системс ХХК-ийн брэндийн стандарт хэлбэрэн дэх
> Word (.docx) баримт бичиг** автоматаар үүсгэх toolkit. Аливаа төсөл / багт
> хуулсаны дараа л шууд ажилладаг.

## Юу хийдэг вэ?

`.md` (Markdown) файлуудыг авч:

1. **Нүүр хуудас** — Title (брэндийн өнгөтэй), Subtitle "Гэрэгэ Системс ХХК",
   документын мэдээлэл (Хувилбар, Эзэн, Нууцлал, Огноо, ...).
2. **Гарчиг хуудас** — Word-ийн auto-update Table of Contents.
3. **Үндсэн агуулга** — Markdown-ийн доторхи Heading, Table, Code block, List
   зэргийг template-ийн стилээр render хийнэ.

Гэрэгэ Blue Template v1.1-ийн **logo, header banner, color palette, font**-ыг
ашиглана.

## Хэрэглэх боломжтой ажил

- Бодлогын баримт (Policy, Procedure, Standard).
- Хууль зүйн нөхцөл (Privacy Notice, ToS, Subscriber Agreement).
- Технологийн спецификаци (API spec, architecture, runbook).
- Аудитын тайлан, төлөвлөгөө.
- Гэрээний загвар.
- Хүний нөөцийн баримт (handbook, onboarding).
- Бусад дотоод / гадаад харилцагчид өгөх Word документ.

## Бүтэц

```
gerege-doc-toolkit/
├── README.md                          ← Энэ файл (overview)
├── CHEATSHEET.md                      ← Команд бүхий хурдан reference
├── template/
│   └── gerege-document-template.docx  ← Гэрэгэ Blue Template v1.1
├── scripts/
│   ├── build.sh                       ← MD → DOCX батч хөрвүүлэгч
│   ├── cover-page.lua                 ← Pandoc Lua filter (cover + ToC)
│   └── scaffold.sh                    ← Шинэ project-д blueprint хуулна
├── examples/
│   ├── README.md                      ← Frontmatter field reference
│   ├── 01-simple-document.md          ← Хамгийн жижиг жишээ
│   └── 02-policy-document.md          ← Policy/standard загвар
└── blueprint/                         ← Documentation Architecture Standard
    ├── README.md                      (orientation)
    ├── ARCHITECTURE.md                (стандартын дэлгэрэнгүй)
    ├── SECTIONS.md                    (section бүрийн нарийвчилсан)
    ├── FRONTMATTER.md                 (YAML schema)
    ├── STYLE-GUIDE.md                 (бичлэгийн дүрэм)
    ├── scaffold/                      (copy-paste folder structure)
    │   ├── README.md, 00-PLAN.md
    │   └── 01-legal/, 02-domain/, ..., 09-business/
    └── templates/                     (per-doc-type templates)
        ├── policy.md, procedure.md, runbook.md
        ├── incident-playbook.md, adr.md, post-mortem.md
        ├── api-spec.yaml, user-manual.md, faq.md
        ├── threat-model.md, design-doc.md, meeting-notes.md
        └── README.md
```

## Шаардлага

| Tool | Хувилбар | Суулгах команд (macOS) |
|---|---|---|
| **pandoc** | 3.0+ | `brew install pandoc` |
| **bash** | 4+ (macOS-ийн default zsh-аас гадуур bash) | (`brew install bash` хэрэв шинэчлэхийг хүсвэл) |
| **Word** | 2016+ (нээж харахад) | (Microsoft 365 / Office) |

Linux:

```bash
sudo apt install pandoc            # Ubuntu / Debian
sudo dnf install pandoc            # Fedora / RHEL
```

Windows (WSL дотор):

```bash
sudo apt install pandoc
```

Эсвэл native Windows: https://pandoc.org/installing.html-аас .msi.

## Хурдан эхлэл

### А) Шинэ project — full scaffold

```bash
cp -r gerege-doc-toolkit /your/project/
cd /your/project

# 9 section + master files үүсгэх
./gerege-doc-toolkit/scripts/scaffold.sh ./documentation "Project Name"

# Эхний docs (template-аас)
cp gerege-doc-toolkit/blueprint/templates/policy.md \
   documentation/01-legal/privacy-notice.md
$EDITOR documentation/01-legal/privacy-notice.md

# Word generate
./gerege-doc-toolkit/scripts/build.sh documentation/
open dist/documentation/01-legal/privacy-notice.docx
```

### Б) Жижиг туршилт

```bash
cd gerege-doc-toolkit
./scripts/build.sh examples/
open dist/examples/01-simple-document.docx     # macOS
xdg-open dist/examples/01-simple-document.docx # Linux
```

## Үндсэн хэрэглээ

### `build.sh` — Markdown → DOCX

```bash
# Нэг файл
./scripts/build.sh path/to/document.md
# → dist/document.docx

# Фолдер бүхэлд (recursive)
./scripts/build.sh path/to/folder/
# → dist/folder/**/*.docx

# Custom output
./scripts/build.sh -o /tmp/build path/to/folder/
```

### `scaffold.sh` — Blueprint scaffold (шинэ project)

```bash
# Default
./scripts/scaffold.sh ./documentation "Project Name"

# Custom section names
./scripts/scaffold.sh ./docs "PKI System" \
  --domain-name 02-pki \
  --integration-name 05-rp-integrator

# Skip sections
./scripts/scaffold.sh ./docs "Library" \
  --skip 01-legal,05-integration,08-audit-evidence,09-business
```

### Blueprint reference

| Зорилго | Файл |
|---|---|
| Архитектурын стандарт ойлгох | [`blueprint/ARCHITECTURE.md`](./blueprint/ARCHITECTURE.md) |
| Section бүрийн нарийн зорилго | [`blueprint/SECTIONS.md`](./blueprint/SECTIONS.md) |
| YAML frontmatter schema | [`blueprint/FRONTMATTER.md`](./blueprint/FRONTMATTER.md) |
| Бичлэгийн дүрэм | [`blueprint/STYLE-GUIDE.md`](./blueprint/STYLE-GUIDE.md) |
| Doc type templates | [`blueprint/templates/`](./blueprint/templates/) |

## Frontmatter — Markdown файлд бичих metadata

`.md` файлынхаа эхэнд YAML frontmatter оруул. Эдгээр утгууд **нүүр хуудаст
автоматаар** гарна:

```yaml
---
title: Document name (нүүр хуудаст том үсгээр гарна)
version: 1.0.0
status: draft | review | approved | retired
priority: P0 | P1 | P2
classification: public | internal | confidential | restricted
owner: Хариуцагч (нэр / role)
effective_date: 2026-05-01
last_reviewed: 2026-04-29
next_review: 2026-10-29
public_url: https://id.gerege.mn/legal/cp     (зөвхөн public docs)
oid: "1.3.6.1.4.1.<<TBD>>.1"                  (PKI зориулалттай)
---
```

**Заавал**: `title`. Бусад нь сонгомол.

Дэлгэрэнгүй: [examples/README.md](./examples/README.md).

### Жишээ

```markdown
---
title: Хувийн мэдээллийн нууцлалын мэдэгдэл
version: 1.0.0
status: approved
classification: public
owner: DPO
effective_date: 2026-05-01
---

# 1. Танилцуулга

Энэхүү мэдэгдэл нь...

## 1.1 Хамрах хүрээ

...
```

## Markdown supported features

Pandoc GFM (GitHub Flavored Markdown)-ийн дэмжих **бүх зүйл** ажиллана:

- ✅ Heading (`# h1`, `## h2`, ... 6 level)
- ✅ Bold, italic, strikethrough
- ✅ Inline code, code block (syntax highlight)
- ✅ Bulleted + numbered list (nested)
- ✅ Table (markdown table syntax)
- ✅ Link, image
- ✅ Footnote (`[^1]`)
- ✅ Blockquote
- ✅ Horizontal rule (`---`)
- ⚠ HTML inline (limited support)
- ⚠ Mermaid diagram (render-гүй plain text-аар л үлдэнэ)

## Output

Default: `dist/` фолдер дотор source path-той ижил структуртай:

```
your-project/
├── docs/
│   └── policy/
│       └── privacy.md          ← source
├── gerege-doc-toolkit/
│   └── ...
└── dist/
    └── docs/
        └── policy/
            └── privacy.docx    ← output
```

## Сэдвээс гадуурх асуултууд

### 1. Word дотор гарчиг хоосон харагдаж байна

Гарчиг нь Word-ийн **auto-update field**. Анх удаа нээхэд автоматаар бөглөгдөж
магадгүй. Хэрэв хоосон бол:

1. Гарчгийн placeholder дээр right-click.
2. **"Update Field"** сонгох.
3. (Эсвэл бүгдийг сонгож `F9` дарах.)

### 2. Logo / header banner яагаад өөрчлөгддөггүй вэ?

Header нь `template/gerege-document-template.docx`-ийн дотроос ирдэг. Өөрчлөх
бол:

1. Word дотор template файлыг нээх.
2. Header / footer area-ыг засах.
3. "Save as" template хэвээр л хадгалах.

### 3. Брэндийн өнгийг өөрчлөх вэ?

Template дотор Title, Heading 1, Heading 2 г.м. style бүрийн өнгөнд тус тусын
config бий. Word → Home → Styles → "Modify" → Format → Font / Border.

### 4. Гарчиг өөр хэлээр (англиар) гарах вэ?

`scripts/cover-page.lua` дотор `"Гарчиг"` мөрийг англиар сольж тус мөрөн дэх
бусад текстийг ч ингэж сольж болно. Эсвэл per-document: frontmatter-д
`toc-title: Contents` нэмэх (Lua filter-ийг update хийх ёстой).

### 5. Нүүр хуудсан дээр өөр field гаргах вэ?

`scripts/cover-page.lua` дотор `fields` хүснэгтэн дотор шинэ мөр нэмэх:

```lua
local fields = {
  ...
  {"Шинэ field",   meta_str(meta.шинэ_утга)},
}
```

Frontmatter-д `шинэ_утга: ...` бичсэн нь автоматаар гарна.

### 6. Bash 4 шаардсан гэдэг яагаад вэ?

`scripts/build.sh` нь `[[`, associative array хэрэглэдэггүй учир bash 3.x-д ч
ажиллана. Гэхдээ macOS-ийн system bash 3.2 нь маш хуучин бөгөөд ⚠ `set -e`
зэрэгт bug-той — bash 4+ зөвлөнө.

### 7. CI/CD-д хэрхэн integrate хийх вэ?

GitHub Actions example:

```yaml
# .github/workflows/docs-build.yml
name: Build docs
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: sudo apt install pandoc
      - run: ./gerege-doc-toolkit/scripts/build.sh docs/
      - uses: actions/upload-artifact@v4
        with:
          name: documents
          path: dist/
```

## Customization recipes

### Recipe A: Internal vs Public layout

Internal docs-д өөр template хэрэглэх:

```bash
# scripts/build.sh-ыг хуулж build-internal.sh болгох
# TEMPLATE-ийг "internal-template.docx" руу зааж өөрчлөх
```

### Recipe B: Watermark нэмэх (DRAFT, CONFIDENTIAL, ...)

Template файл дотор Word-ээр watermark нэмэх:

1. Template-ийг Word-аар нээх.
2. Design → Watermark → Custom Watermark → Text → "DRAFT".
3. Save.

### Recipe C: Section break (бүлэг тус бүр шинэ хуудаснаас эхлэх)

`cover-page.lua` дотор `Header` filter нэмэх:

```lua
function Header(elem)
  if elem.level == 1 then
    -- Insert page break before each top-level heading
    return {
      pandoc.RawBlock('openxml',
        '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'),
      elem
    }
  end
end
```

## Технологи

- **pandoc** — universal document converter (Markdown → docx).
- **pandoc Lua filters** — AST manipulation (нүүр хуудас + ToC inject).
- **OOXML** — Word-ийн нутгийн XML формат (page break, fields).
- **Reference docx** — pandoc-ийн style-ыг хэрэглэх template.

Гүнзгий: https://pandoc.org/MANUAL.html#extension-yaml_metadata_block

## Лиценз

Toolkit (script-ууд + Lua filter): MIT.
Template (`template/gerege-document-template.docx`): **Гэрэгэ Системс ХХК**-ийн
өмч. Зөвхөн тус компанийн дотоод хэрэглээ + албан харилцагчдад зориулсан
баримт бичигт хэрэглэнэ.

## Холбогдох

| Зүйл | Холбоо |
|---|---|
| Bug / шинэчлэлт | dev@gerege.mn |
| Template-ийн брэнд асуултууд | brand@gerege.mn |
| Хэрэглэгчийн зөвлөмж | docs@gerege.mn |

## Хувилбарын түүх

| Хувилбар | Огноо | Өөрчлөлт |
|---|---|---|
| 1.0.0 | 2026-04-29 | Анхны хувилбар (Gerege ID документын toolkit-аас гарагдан гаргасан) |
