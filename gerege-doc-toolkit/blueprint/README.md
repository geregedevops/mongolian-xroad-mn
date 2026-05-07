# Gerege Documentation Blueprint

> **Гэрэгэ Системс ХХК-ийн төслүүдэд дагах баримт бичгийн архитектурын
> нэгдсэн стандарт.** Энэ blueprint нь шинэ төсөл эхлүүлэх, эсвэл хуучин
> төслийн docs-ыг refactor хийхэд **direct copy-paste**-аар ашиглах зорилготой.

## Юунд хэрэгтэй вэ?

Бид олон төсөлтэй. Session тус бүрд өөр өөр байдлаар бүтэц зохиоход:

- ❌ Нэг ажилтан project A-аас project B руу шилжихэд бүгдийг шинээр сурна.
- ❌ Customer / auditor бүх project-н документыг өөр өөр форматтайгаар авна.
- ❌ Memory-н фрагмент бүх session-д давтагдана.
- ❌ Хэн юу хийсэнг ярихад "энэ runbook-ыг аль folder-т хайх вэ?" асуулт.

Blueprint нь:

- ✅ **9 numbered section** (01-09) — бүгд нэг л хэлбэрээр.
- ✅ **Frontmatter standard** — version, status, classification бүх docs-д.
- ✅ **Doc type templates** — policy, runbook, ADR, post-mortem зэрэг.
- ✅ **RACI + review cadence** — хариуцлага тодорхой.
- ✅ **scaffold.sh** — нэг командаар бүх structure copy.

## Файлын бүтэц

```
blueprint/
├── README.md              ← (энэ файл)
├── ARCHITECTURE.md        ← Стандартын дэлгэрэнгүй тайлбар
├── SECTIONS.md            ← Section бүрийн нарийвчилсан зорилго + жишээ
├── FRONTMATTER.md         ← YAML frontmatter spec
├── STYLE-GUIDE.md         ← Бичлэгийн дүрэм + stylistic conventions
├── scaffold/              ← Бэлэн folder structure (copy-paste-ready)
│   ├── README.md          (master index template)
│   ├── 00-PLAN.md         (execution plan template)
│   ├── 01-legal/
│   ├── 02-domain/
│   ├── 03-technical/
│   ├── 04-operations/
│   ├── 05-integration/
│   ├── 06-end-user/
│   ├── 07-engineer/
│   ├── 08-audit-evidence/
│   └── 09-business/
└── templates/             ← Per-doc-type templates
    ├── policy.md
    ├── procedure.md
    ├── runbook.md
    ├── incident-playbook.md
    ├── adr.md
    ├── post-mortem.md
    ├── api-spec.yaml
    ├── user-manual.md
    ├── faq.md
    ├── threat-model.md
    ├── design-doc.md
    └── meeting-notes.md
```

## Хэрэглэх 3 арга

### 1. Шинэ төсөл — `scaffold.sh`

```bash
# Нэг команд: blueprint-ийн structure-ыг target folder руу хуулна
../gerege-doc-toolkit/scripts/scaffold.sh ./documentation
```

→ Үр дүн: `./documentation/` дотор бүх 9 section + master files бэлэн.

### 2. Хуучин төсөл — manual sync

```bash
# Аль section-ууд хэрэгтэйг сонгоно
cp -r blueprint/scaffold/01-legal /your-project/docs/
cp -r blueprint/scaffold/03-technical /your-project/docs/

# Шаардлагатай template
cp blueprint/templates/runbook.md /your-project/docs/04-operations/server-restart.md
```

### 3. Reference unicатеж — `ARCHITECTURE.md` уншина

`ARCHITECTURE.md` + `SECTIONS.md` дээр блок section бүрийн зорилго болон агуулгыг
тайлбарласан. Тус session-аар "ийм structure-ыг follow хий" гэж зөвлөнө.

## Сонголтоор хэрэглэх

Бүх 9 section-ыг **заавал** ашиглах хэрэггүй. Project-н шинж чанараас хамаараад:

| Project төрөл | Хэрэгтэй sections |
|---|---|
| **CA / PKI / Identity** (Гэрэгэ ID жишээ) | 01-09 бүгд |
| **Internal SaaS** | 03, 04, 06, 07 (skip legal/audit) |
| **Open source library** | 03, 07 (+ optional 06 user docs) |
| **Banking / fintech** | 01-09 бүгд + extra compliance |
| **Government project** | 01, 03, 04, 05, 09 |
| **Internal tooling** | 03, 04, 07 |

Хэрэгтэй section-уудыг сонгож copy. Дараа шинэ section нэмэх хүсэлтэй болсон
бол `10-`, `11-` гэсэн дугаараар үргэлжлүүлж нэмж болно.

## Оршил уншигч

| Хэрвээ та... | Эхлээд унш |
|---|---|
| Шинэ project зохион байгуулж байгаа | [ARCHITECTURE.md](./ARCHITECTURE.md) |
| Хуучин project-д blueprint apply хийх гэж байгаа | [ARCHITECTURE.md §11 Adoption](./ARCHITECTURE.md) |
| Шинэ document бичих гэж байгаа | [SECTIONS.md](./SECTIONS.md) + [templates/](./templates/) |
| Frontmatter асуулт | [FRONTMATTER.md](./FRONTMATTER.md) |
| Бичлэгийн стиль асуулт | [STYLE-GUIDE.md](./STYLE-GUIDE.md) |
| Section X-д юу багтах вэ | [SECTIONS.md](./SECTIONS.md) |

## Жишээ implementations

Эх blueprint-ыг бодит project-д хэрэглэсэн жишээ:

- **Гэрэгэ ID** — `gerege-mn-eid` repo-ийн `documentation/` фолдер
  (119 файл, 9 section). Үндсэн blueprint reference.

(Нэмэлт example-ууд project-ийн дараа энд жагсаална.)

## Зөвшөөрөл

Этэ blueprint нь **MIT-төстэй** дотоод лицензтэй — Гэрэгэ Системс ХХК-ийн
аливаа төсөл, group-ийн дотоод хэрэгцээнд чөлөөтэй ашиглана.

## Шинэчлэлт

Blueprint нь хувьслан нэмэгдэнэ. Бодит project-аас санал авч сайжруулах нь
зөв. Issue / PR-ыг toolkit-ийн репозитортой нийцүүлж submit хийж болно.

| Хувилбар | Огноо | Өөрчлөлт |
|---|---|---|
| 1.0.0 | 2026-04-29 | Анхны хувилбар (Гэрэгэ ID-аас extract) |
