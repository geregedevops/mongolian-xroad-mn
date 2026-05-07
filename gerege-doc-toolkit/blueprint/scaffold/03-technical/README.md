---
title: 03 — Technical Reference
owner: Tech Lead
priority: P1
version: 1.0.0
status: draft
last_reviewed: 2026-04-29
classification: public
---

# 03 — Technical Reference

> Engineering-д зориулсан API spec, schema, sequence diagram, architecture
> overview, threat model, audit log forensics.

## Sub-folder бүтэц

```
03-technical/
├── README.md                    (энэ файл)
├── api/
│   └── *.yaml                   (OpenAPI spec)
├── database/
│   ├── schema.dbml              (DBML source)
│   └── er-diagram.md            (Mermaid ER)
├── diagrams/
│   └── *.mmd                    (Mermaid sequence/flow)
├── architecture/
│   ├── c4-context.md
│   ├── c4-container.md
│   └── c4-component.md
├── threat-model.md
└── audit-log-forensics.md
```

## Document жагсаалт

| Файл / зам | Format | Template |
|---|---|---|
| `api/<service>-openapi.yaml` | OpenAPI 3 | [api-spec.yaml](../../templates/api-spec.yaml) |
| `database/schema.dbml` | DBML | (нет — dbdiagram.io render) |
| `database/er-diagram.md` | Mermaid + commentary | [design-doc.md](../../templates/design-doc.md) |
| `diagrams/*.mmd` | Mermaid sequence | (нет — mermaid.live render) |
| `architecture/c4-*.md` | Mermaid C4 + tайлбар | design-doc.md |
| `threat-model.md` | STRIDE | [threat-model.md](../../templates/threat-model.md) |
| `audit-log-forensics.md` | How-to | [runbook.md](../../templates/runbook.md) |

## RACI

- **R**: Tech Lead
- **A**: CTO
- **C**: Backend, Mobile, Web Lead
- **I**: Integrator

## Review cadence

- Том release бүрд (semver minor +).
- API өөрчлөгдөхөд тэр дороо.

## Tooling

- **OpenAPI**: Stoplight Studio / Swagger UI рендер.
- **DBML**: [dbdiagram.io](https://dbdiagram.io) рендер.
- **Mermaid**: GitHub auto-render. Offline `mmdc` cli.

## Best practice

- Sequence diagram нь **end-to-end use case-аар** (per business flow), биш
  per service.
- C4 diagram-ийн **Context > Container > Component** дарааллаар.
- Threat model нь **per service / per integration boundary**.
- API spec нь **версион + deprecated tag-тай**.
