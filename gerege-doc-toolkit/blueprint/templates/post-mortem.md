---
title: Post-mortem — <<TBD: Incident title>> (<<YYYY-MM-DD>>)
owner: <<TBD: IC>>
priority: P1
version: 1.0.0
status: draft
last_reviewed: 2026-MM-DD
classification: internal
incident_id: INC-YYYY-NNN
severity: SEV-N
---

# Post-mortem: <<TBD: Incident title>> (<<YYYY-MM-DD>>)

## Summary

<<TBD: 1-2 өгүүлбэрээр incident-ийг тайлбарлах>>

## Impact

| Зүйл | Утга |
|---|---|
| Severity | SEV-N |
| Started at | YYYY-MM-DD HH:MM UTC |
| Detected at | YYYY-MM-DD HH:MM UTC |
| Mitigated at | YYYY-MM-DD HH:MM UTC |
| Resolved at | YYYY-MM-DD HH:MM UTC |
| Total duration | HH:MM:SS |
| Time to detect (TTD) | MM:SS |
| Time to mitigate (TTM) | HH:MM |
| Users affected | ~XXXX |
| Revenue impact (if applicable) | <<TBD>> |
| Affected services | <<TBD>> |

## Timeline (UTC)

```
HH:MM  Detect via <<source>>
HH:MM  IC assigned (<<name>>)
HH:MM  <<TBD: first significant event>>
HH:MM  <<TBD: mitigation deployed>>
HH:MM  <<TBD: monitoring confirmed>>
HH:MM  Resolved
HH:MM  Status page updated to "operational"
```

## Root cause

<<TBD: Технологийн root cause тайлбар>>

```
<<TBD: тус code диpff эсвэл log snippet
showing the trigger>>
```

## Resolution

<<TBD: Шууд хариу үйлдэл (band-aid)>>

```bash
<<TBD: command / hotfix that mitigated>>
```

<<TBD: Permanent fix>>

```
<<TBD: PR/commit links>>
```

## What went well

- <<TBD: positive 1>>
- <<TBD: positive 2>>
- <<TBD: positive 3>>

## What went badly

- <<TBD: negative 1>>
- <<TBD: negative 2>>
- <<TBD: negative 3>>

## Where we got lucky

- <<TBD: lucky thing 1>>
- <<TBD>>

## Action items

| # | Item | Type | Owner | Due | Priority |
|---|---|---|---|---|---|
| 1 | <<TBD: process improvement>> | Process | <<TBD>> | YYYY-MM-DD | P0 |
| 2 | <<TBD: monitoring добавить>> | Detection | <<TBD>> | YYYY-MM-DD | P1 |
| 3 | <<TBD: code fix>> | Code | <<TBD>> | YYYY-MM-DD | P0 |
| 4 | <<TBD: test нэмэх>> | Test | <<TBD>> | YYYY-MM-DD | P1 |
| 5 | <<TBD: документ update>> | Docs | <<TBD>> | YYYY-MM-DD | P2 |

Type-уудын утга:
- **Detection** — иим incident-ийг хурдан илрүүлэх
- **Prevention** — иим incident гарахаас сэргийлэх
- **Mitigation** — иим incident-ийг хурдан зогсооно
- **Process** — coordination / communication улам сайжруулах
- **Code** — кодын fix
- **Test** — regression test нэмэх
- **Docs** — runbook / playbook шинэчлэх

## Lessons learned

<<TBD: 2-3 пунктэн lesson — future incident-уудад apply хийх ёстой>>

1. <<TBD>>
2. <<TBD>>
3. <<TBD>>

## Acknowledgments

| Role | Person |
|---|---|
| Detector | <<TBD>> |
| Incident Commander | <<TBD>> |
| Responders | <<TBD>>, <<TBD>> |
| Customer comms | <<TBD>> |

## Public disclosure

- ☐ Public post-mortem published at <<URL>>
- ☐ Subscriber notification sent
- ☐ Partner / RP webhook fired
- ☐ Status page updated
- ☐ Press release (if SEV-0 with regulatory implications)

## Sign-off

| Role | Name | Date |
|---|---|---|
| Incident Commander | <<TBD>> | YYYY-MM-DD |
| SRE Lead | <<TBD>> | YYYY-MM-DD |
| CTO | <<TBD>> | YYYY-MM-DD |
| (SEV-0 only) CEO | <<TBD>> | YYYY-MM-DD |
