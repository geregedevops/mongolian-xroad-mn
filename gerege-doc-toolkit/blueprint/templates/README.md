# Document Templates

> Document type-аар бэлэн **boilerplate**. Шинэ document бичих хэрэгтэй болоход
> тохирох template-ыг copy + content-ыг бөглөж эхлэх.

## Template жагсаалт

| Template | Зорилго | Section-д ихэвчлэн |
|---|---|---|
| [policy.md](./policy.md) | Policy / Standard / Agreement | 01-legal, 02-domain, 04-operations, 09-business |
| [procedure.md](./procedure.md) | Step-by-step procedure | 02-domain, 04-operations, 07-engineer |
| [runbook.md](./runbook.md) | Operations runbook (commands + troubleshooting) | 04-operations, 07-engineer |
| [incident-playbook.md](./incident-playbook.md) | Severity-based incident response | 04-operations |
| [adr.md](./adr.md) | Architecture Decision Record | 07-engineer/adr/ |
| [post-mortem.md](./post-mortem.md) | Post-incident review | 08-audit-evidence/post-mortems/ |
| [api-spec.yaml](./api-spec.yaml) | OpenAPI 3.1 skeleton | 03-technical/api/ |
| [user-manual.md](./user-manual.md) | End-user / integrator guide | 05-integration, 06-end-user |
| [faq.md](./faq.md) | Q&A reference | 05-integration, 06-end-user |
| [threat-model.md](./threat-model.md) | STRIDE per service | 03-technical |
| [design-doc.md](./design-doc.md) | Шинэ feature design / architecture | 03-technical, 02-domain |
| [meeting-notes.md](./meeting-notes.md) | Шийдвэр гаргасан уулзалт | (anywhere) |

## Хэрэглэх дараалал

```bash
# 1. Template сонгох
cp blueprint/templates/policy.md \
   /your-project/documentation/01-legal/your-policy.md

# 2. Frontmatter бөглөх
$EDITOR /your-project/documentation/01-legal/your-policy.md

# 3. Бөглөгдөөгүй placeholder ("<<TBD>>") бөглөх
grep -n '<<TBD' /your-project/documentation/01-legal/your-policy.md
```

## Template-ийн зарчим

1. **Frontmatter бэлэн** — заавал бөглөх field-ууд placeholder-аар.
2. **Section structure уламжлалт** — well-known approach (RFC 3647 for CP/CPS,
   STRIDE for threat model, etc.).
3. **`<<TBD: ...>>` placeholder** — бөглөх ёстой газруудыг тэмдэглэсэн.
4. **Жишээ table / list** — заавал ашиглах хэлбэр (rename / extend).
5. **Хавсралт** — structured supporting material slot.

## Custom template нэмэх

Project-аар тогтмол давтагддаг шинэ document type гарвал template нэмж
болно:

```bash
# 1. Шинэ template бичих
$EDITOR blueprint/templates/<your-template>.md

# 2. Энэ файл (templates/README.md)-д жагсаалтад нэмэх

# 3. PR + review
```

## Convention

- Template файлын **content нь monolingual Mongolian**.
- **Англи** нь зөвхөн нэр томъёо, кодын код.
- **`<placeholder>`** angle bracket-аар тодорхой бичих ("<<TBD: explain>>" эсвэл "<your name>").
