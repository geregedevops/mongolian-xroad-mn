---
title: Incident Response Playbook
owner: CISO / SRE Lead
priority: P0
version: 1.0.0
status: draft
last_reviewed: 2026-04-29
next_review: 2026-07-29
classification: internal
---

# Incident Response Playbook

> Severity-аар classify хийсэн **incident-ийн specific хариу үйлдэл**.
> On-call SRE болон incident commander-ийн ширээний гарын авлага.

## 1. Severity classification

| Severity | Шалгуур | Initial response time |
|---|---|---|
| **SEV-0** | <<TBD: e.g., total outage >30 min, data breach >1000 user>> | **5 минут** |
| **SEV-1** | <<TBD: limited impact, partial degradation>> | **15 минут** |
| **SEV-2** | <<TBD: minor impact, single user>> | **1 цаг** |
| **SEV-3** | <<TBD: minor / cosmetic>> | **24 цаг** |

## 2. Incident commander (IC)

SEV-0/1 incident бүрд **IC** томилогддог:

- Хэрэв ажлын цагаар → On-call SRE.
- Хэрэв шөнийн цагаар → On-call → CTO escalate.

IC нь:

1. War room нээх (Slack #incidents-NNN).
2. Status page-ийг update.
3. Stakeholder-уудтай харилцах.
4. Action item-ыг бичиж тарааж, хариуцагч тогтоох.
5. **Resolve хүртэл бусад үүрэгт орохгүй**.

## 3. Стандарт хариу алхам

```
DETECT → TRIAGE → COMMUNICATE → MITIGATE → INVESTIGATE → RESOLVE → POST-MORTEM
```

### 3.1 DETECT

- Source: alert / user report / vendor / researcher
- Action: Acknowledge alert, judge severity

### 3.2 TRIAGE

- Confirm: not false positive
- Identify: scope, affected users, impact
- Severity assignment
- IC assignment (if SEV-0/1)

### 3.3 COMMUNICATE

- Internal: #incidents-NNN Slack
- SEV-0: CTO + CEO + Legal within 1h
- SEV-1: CTO within 4h
- External (if user-facing): status page

### 3.4 MITIGATE

- Stop the bleeding (block IPs, disable feature, ...)
- Restore service
- Avoid PII leakage in logs

### 3.5 INVESTIGATE

- Root cause analysis
- Timeline reconstruction
- Evidence preservation

### 3.6 RESOLVE

- Permanent fix deploy
- Verify with monitoring
- Status page: Resolved

### 3.7 POST-MORTEM (within 14 days for SEV-0/1)

- Blameless post-mortem write-up
- Action items with owners + deadlines
- Public version (if SEV-0)

## 4. Specific scenarios

### 4.1 <<TBD: Critical service outage>>

**Severity: SEV-0**

```
[ ] STOP <<affected component>> immediately:
    <<TBD: command>>
[ ] Notify CTO + CEO (within 1 hour)
[ ] Forensic preservation:
    - <<TBD>>
[ ] Investigate scope:
    - <<TBD>>
[ ] If confirmed → <<TBD: mitigation>>
[ ] <<TBD: recovery procedure>>
```

### 4.2 <<TBD: Backend RCE / unauthorized admin access>>

**Severity: SEV-0**

```
[ ] Isolate: <<TBD>>
[ ] Snapshot containers (NOT delete): <<TBD>>
[ ] Capture memory: <<TBD>>
[ ] Rotate ALL secrets: <<TBD>>
[ ] Audit log review
[ ] Patch deploy
[ ] Post-mortem within 14 days
```

### 4.3 <<TBD: Personal data breach>>

**Severity: SEV-0/1 (depends on volume)**

```
[ ] Stop the leak
[ ] Identify scope
[ ] PDPL notification (within 72h)
[ ] If credentials/tokens leaked → rotate
[ ] Forensic + post-mortem
```

### 4.4 <<TBD: Auth bypass>>

**Severity: SEV-1**

```
[ ] Reproduce internally
[ ] Disable affected attack vector at backend
[ ] Patch backend
[ ] Notify affected users
```

### 4.5 <<TBD: API key compromise>>

**Severity: SEV-1**

```
[ ] Rotate API key
[ ] Audit log review for unauthorized usage
[ ] Notify partner/customer
```

### 4.6 <<TBD: Service down>>

**Severity: SEV-1**

```
[ ] Check container: <<TBD>>
[ ] Restart: <<TBD>>
[ ] Check logs: <<TBD>>
[ ] If persistent: investigate <<TBD>>
[ ] During outage: <<TBD: status page update>>
```

### 4.7 <<TBD: DB connection storm>>

**Severity: SEV-2**

```
[ ] Check pool stats: <<TBD>>
[ ] Identify long-running queries: <<TBD>>
[ ] Kill problematic
[ ] Restart backend if pool stuck
[ ] Tune pool size if recurring
```

### 4.8 <<TBD: Disk full>>

**Severity: SEV-1**

```
[ ] df -h — find culprit
[ ] Common: <<TBD>>
[ ] Cleanup: <<TBD>>
[ ] Increase disk or rotate logs more aggressively
```

### 4.9 <<TBD: Total host outage>>

**Severity: SEV-0**

→ See `disaster-recovery-plan.md`

### 4.10 <<TBD: External dependency down>>

**Severity: SEV-2**

```
[ ] Check vendor status page
[ ] Notify users via status page
[ ] Workaround: <<TBD>>
```

## 5. Post-mortem template

[`templates/post-mortem.md`](./post-mortem.md)

Save to: `08-audit-evidence/post-mortems/YYYY-MM-DD-<title>.md`.

## 6. Status page

`<<TBD: status URL>>`. Update during incident: minute-by-minute.

## 7. Communication templates

### 7.1 Subscriber notification (email)

```
Subject: <<TBD>> — Үйлчилгээний доголдол [SEV-N]

Сайн байна уу,

[YYYY-MM-DD HH:MM]-аас [HH:MM] хүртэл доголдол гарсан.

Юу болсон:
<<simple explanation>>

Та нөлөөлсөн үү:
<<scope>>

Бид юу хийсэн:
<<mitigation summary>>

Дэлгэрэнгүй: <<status URL>>
Холбоо: <<email>>

Хүндэтгэсэн,
<<organization>>
```

### 7.2 Partner / RP webhook

```json
{
  "event": "platform.incident.notice",
  "incident_id": "INC-YYYY-NNN",
  "severity": "SEV-1",
  "started_at": "...",
  "ended_at": "...",
  "affected_components": [...],
  "summary": "...",
  "url": "..."
}
```

## 8. Evidence preservation

```
incidents/INC-YYYY-NNN/
├── timeline.md
├── decisions.md
├── logs/
├── snapshots/
├── communications/
└── post-mortem.md
```

Retention: 7 жил.
