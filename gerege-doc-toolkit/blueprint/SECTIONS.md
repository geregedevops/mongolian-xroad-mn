# Sections — Detailed Reference

> Section 01-09 бүрийн **зорилго**, **типичен docs**, **owner**, **review
> cadence**, **жишээ файл**-уудын дэлгэрэнгүй reference.

## 01-legal — Хууль зүй / Compliance

### Зорилго

Хуулийн / зохицуулалтын / гэрээний бүх баримт. Public-аар нийтлэгдэх
ихэнх docs.

### Audience

Зохицуулагч (CRA, ХХЗХ), хууль зүйн зөвлөх, иргэн, RP, гадаад auditor.

### Типичен docs

| Файл | Зорилго | Template |
|---|---|---|
| `privacy-notice.md` | Хувийн мэдээллийн нууцлалын мэдэгдэл | policy.md |
| `terms-of-service.md` | Хэрэглээний нөхцөл | policy.md |
| `subscriber-agreement.md` | Иргэнтэй гэрээ | policy.md |
| `relying-party-agreement.md` | RP-тэй гэрээ | policy.md |
| `certificate-policy.md` | RFC 3647 CP (зөвхөн CA) | policy.md |
| `certification-practice-statement.md` | RFC 3647 CPS (зөвхөн CA) | policy.md |
| `data-retention-deletion-policy.md` | Хадгалах хугацаа | policy.md |
| `incident-disclosure-policy.md` | Зөрчлийн мэдэгдэх | policy.md |
| `vulnerability-disclosure-policy.md` | VDP (security.txt) | policy.md |
| `cookie-policy.md` | Cookie нөхцөл | policy.md |

### Owner / RACI

- **R**: Хууль зүйн зөвлөх
- **A**: CEO
- **C**: CTO, COO
- **I**: Бүх багийнхан

### Review cadence

- 6 сар + хууль өөрчлөгдсөн өдөр.

### Public публикжуулах

- `https://<your-domain>/legal/<file>` URL-аар нийтлэгдэнэ.
- URL тогтвортой байх (RP найдна).

---

## 02-domain — Project-specific core

### Зорилго

Project-н **уникал domain**-ийн дотоод үйлчилгээ. Энэ нь project-аар
чухал хэрэгтэй болно. Энэ folder-ыг **project-д тохируулж нэрлэх**:

| Project | Section name |
|---|---|
| Гэрэгэ ID (PKI/CA) | `02-pki/` |
| Payment processor | `02-payments/` |
| AI platform | `02-ml-platform/` |
| E-commerce | `02-marketplace/` |
| Identity provider | `02-identity/` |
| IoT platform | `02-iot/` |

### Audience

Domain operator-ууд + auditor-ууд.

### Типичен docs (PKI жишээгээр)

| Файл | Зорилго |
|---|---|
| `key-ceremony-procedure.md` | Issuing CA түлхүүр үүсгэх ёслол |
| `hsm-operations-manual.md` | HSM өдөр тутмын ажиллагаа |
| `pki-profile-spec.md` | X.509, OCSP, CRL, TSA profile |
| `key-rotation-lifecycle.md` | Key lifecycle |
| `cryptography-policy.md` | Зөвшөөрөгдсөн алгоритм |
| `revocation-procedure.md` | Revocation workflow |

### Owner / RACI

- **R**: Domain Lead (e.g., CA Officer)
- **A**: CTO
- **C**: Architect, Audit Lead
- **I**: Бүх инженерчүүд

### Review cadence

- 12 сар + том өөрчлөлт.

---

## 03-technical — Technical reference

### Зорилго

Engineering-д зориулсан **API spec, schema, sequence diagram, architecture
overview, threat model, audit log forensics** зэрэг.

### Audience

Engineer, backend lead, integrator.

### Sub-folder structure

```
03-technical/
├── README.md
├── api/
│   ├── backend-openapi.yaml
│   ├── ocsp-openapi.yaml
│   └── crl-openapi.yaml
├── database/
│   ├── schema.dbml
│   └── er-diagram.md
├── diagrams/
│   ├── 01-mobile-login.mmd
│   ├── 02-mobile-sign.mmd
│   └── ...
├── architecture/
│   ├── c4-context.md
│   ├── c4-container.md
│   └── c4-component.md
├── threat-model.md
└── audit-log-forensics.md
```

### Типичен docs

| Файл | Format | Template |
|---|---|---|
| `api/*.yaml` | OpenAPI 3 | api-spec.yaml |
| `database/schema.dbml` | DBML | (none — dbdiagram.io) |
| `database/er-diagram.md` | Mermaid | design-doc.md |
| `diagrams/*.mmd` | Mermaid sequence | (none — mermaid.live) |
| `architecture/c4-*.md` | Mermaid C4 + tайлбар | design-doc.md |
| `threat-model.md` | STRIDE | threat-model.md |
| `audit-log-forensics.md` | How-to | runbook.md |

### Owner / RACI

- **R**: Tech Lead
- **A**: CTO
- **C**: Backend, Mobile, Web Lead
- **I**: RP integrator

### Review cadence

- Том release бүрд (semver minor +).

### Best practice

- OpenAPI yaml-аас Stoplight Studio / Swagger UI-аар render хийнэ.
- DBML-аас [dbdiagram.io](https://dbdiagram.io)-аар ER diagram render.
- Mermaid файл нь GitHub-д auto render. Offline бол `mmdc` cli.

---

## 04-operations — Operations / SRE

### Зорилго

Production эрсдэл бууруулна. Single-host failure эсвэл ажилтан өөрчлөгдсөн
тохиолдолд **үргэлжлүүлэх боломжтой** болгоно.

### Audience

SRE, on-call engineer, incident commander.

### Типичен docs

| Файл | Template |
|---|---|
| `operations-runbook.md` | runbook.md |
| `incident-response-playbook.md` | incident-playbook.md |
| `disaster-recovery-plan.md` | runbook.md |
| `backup-restore-drill.md` | procedure.md |
| `on-call-handbook.md` | runbook.md |
| `monitoring-alerting.md` | runbook.md |
| `sla-slo.md` | policy.md |
| `network-diagram.md` | design-doc.md |
| `change-management.md` | procedure.md |
| `capacity-planning.md` | design-doc.md |

### Owner / RACI

- **R**: SRE Lead
- **A**: CTO
- **C**: Backend Lead, Domain Lead
- **I**: Бүх engineer

### Review cadence

- 3 сар + incident бүрийн дараа (lessons learned section шинэчлэх).

---

## 05-integration — External integrators / partners

### Зорилго

Project-д integration хийдэг **гадаад этгээдэд** (RP, partner, API consumer)
зориулсан гарын авлага.

Project-аар нэр өөр:
- Гэрэгэ ID → `05-rp-integrator/`
- Payment processor → `05-merchant-integration/`
- API gateway → `05-api-consumers/`

### Audience

3rd party developer, partner technical team.

### Типичен docs

| Файл | Template |
|---|---|
| `onboarding-guide.md` | user-manual.md |
| `integration-cookbook.md` | user-manual.md |
| `webhook-sse-spec.md` | api-spec.yaml + procedure.md |
| `error-code-reference.md` | (table-heavy) |
| `rate-limit-quotas.md` | policy.md |
| `sandbox-guide.md` | user-manual.md |
| `xroad-subsystem-onboarding.md` (e.g.) | procedure.md |

### Owner / RACI

- **R**: Backend Lead / Developer Relations
- **A**: CTO
- **C**: Sales, Tech Lead
- **I**: Customer

### Review cadence

- API change бүрд + 6 сар.

---

## 06-end-user — End-user documentation

### Зорилго

Иргэн, customer, ААН-ийн админ зэрэг **end-user**-ийн гарт ороход бэлэн docs.
Customer support track-ийн гол contentment.

### Audience

Иргэн, ААН админ, customer support.

### Типичен docs

| Файл | Template |
|---|---|
| `citizen-user-manual.md` | user-manual.md |
| `organization-admin-manual.md` | user-manual.md |
| `mobile-faq-troubleshooting.md` | faq.md |
| `desktop-usb-token-manual.md` | user-manual.md |
| `app-store-listing-assets.md` | (marketing) |
| `localization-transliteration.md` | policy.md |
| `accessibility-statement.md` | policy.md |

### Owner / RACI

- **R**: Product Lead / UX
- **A**: CEO
- **C**: Support, Mobile Lead
- **I**: Иргэн

### Review cadence

- UI change бүрд + 6 сар.

### PDF format

End-user docs нь PDF болгож тарагдана:

```bash
./gerege-doc-toolkit/scripts/build.sh 06-end-user/
# → dist/06-end-user/*.docx (Word-аас PDF export)
```

---

## 07-engineer — Engineer / Developer

### Зорилго

Шинэ engineer 1 долоо хоногт production-д ажиллах түвшинд орох гарын авлага.
ADR (Architecture Decision Record)-ууд.

### Audience

Engineer (full-time, contractor, intern).

### Типичен docs

| Файл | Template |
|---|---|
| `new-engineer-onboarding.md` | runbook.md |
| `local-development-guide.md` | runbook.md |
| `testing-strategy.md` | policy.md |
| `coding-standards.md` | policy.md |
| `pr-review-checklist.md` | (checklist) |
| `release-process.md` | procedure.md |
| `mobile-signing-certificate-handling.md` | runbook.md |
| `adr/0001-*.md`, `adr/0002-*.md`, ... | adr.md |

### ADR — Architecture Decision Records

`adr/` фолдер дотор. Нэр: `NNNN-short-title.md` (4-digit zero-padded).

ADR нь "**яагаад тэр шийдвэр гаргасан вэ**" гэдгийг хадгалдаг — кодын
commit-аас илүү дэлгэрэнгүй.

ADR template: `templates/adr.md`. Status: proposed → accepted → superseded.

### Owner / RACI

- **R**: Tech Lead
- **A**: CTO
- **C**: All engineers
- **I**: New hires

### Review cadence

- Том рефактор бүрд.
- Шинэ ADR — шийдвэр бүрд.
- Coding standard / onboarding — 12 сар.

---

## 08-audit-evidence — Audit trail

### Зорилго

Гадаад аудитор / зохицуулагч-д өгөх **бэлэн нотолгоо**. Pen test report,
SBOM, vulnerability scan, post-mortem-ууд.

### Audience

Audit Lead, External auditor, Regulator.

### Sub-folder structure

```
08-audit-evidence/
├── README.md
├── pentest-report-template.md
├── annual-security-review-template.md
├── vulnerability-scan-template.md
├── sbom/
│   ├── go-modules.md
│   ├── npm-packages.md
│   └── ...
├── post-mortems/
│   └── YYYY-MM-DD-<title>.md
├── backup-drills/
│   └── YYYY-MM.md
├── pentest-reports/
│   └── YYYY-QN-vendor.md (encrypted PDF)
└── data-retention-audits/
    └── YYYY.md
```

### Типичен docs

| Файл | Template |
|---|---|
| `pentest-report-template.md` | (template хэвээр; бодит report тус тусдаа) |
| `annual-security-review-template.md` | (SOC 2-loose) |
| `vulnerability-scan-template.md` | (template) |
| `sbom/*.md` | (table-heavy) |
| `post-mortems/*.md` | post-mortem.md |

### Owner / RACI

- **R**: Audit Lead
- **A**: CTO
- **C**: External auditor
- **I**: Board

### Review cadence

- Pen-test, SOC review бүрийн дараа.

### Sensitivity

`08-audit-evidence/*` ихэнхи нь **internal** classification. Pen test
result-уудыг **confidential** (PGP encrypted).

---

## 09-business — Business / Commercial

### Зорилго

Үнэ, гэрээний загвар, customer support SLA, sales asset.

### Audience

Sales, COO, customer success, RP.

### Типичен docs

| Файл | Template |
|---|---|
| `pricing-plan.md` | policy.md |
| `customer-support-sla.md` | policy.md |
| `master-service-agreement-template.md` | policy.md |

### Owner / RACI

- **R**: COO / Sales Lead
- **A**: CEO
- **C**: Sales, Legal
- **I**: RP

### Review cadence

- 12 сар + үнэ өөрчлөгдсөн өдөр.

---

## Cross-section шилжүүлэх

Document-аас section руу зөвшөөрсөн **multi-section линк** allowed:

```markdown
[../03-technical/api/backend-openapi.yaml](../03-technical/api/backend-openapi.yaml)
```

Ингэснээр RP onboarding (05) нь technical API (03) дээр reference хийж буй
нь хэвийн.

---

## Хувилбарын түүх

| Хувилбар | Огноо | Өөрчлөлт |
|---|---|---|
| 1.0.0 | 2026-04-29 | Initial breakdown (Гэрэгэ ID-аас extract) |
