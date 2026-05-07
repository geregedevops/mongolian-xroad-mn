---
title: Threat Model — <<TBD: System / Service нэр>>
owner: CISO / CTO
priority: P1
version: 1.0.0
status: draft
last_reviewed: 2026-04-29
next_review: 2026-10-29
classification: internal
---

# Threat Model — <<TBD: System / Service>>

> STRIDE загвараар threat enumeration. Per service / per component.
> S=Spoofing, T=Tampering, R=Repudiation, I=Information disclosure,
> D=Denial of service, E=Elevation of privilege.

## 1. Asset inventory

| Asset | Critical level | Хадгалагдаж буй газар |
|---|---|---|
| <<TBD: Asset 1>> | CRITICAL / HIGH / MEDIUM / LOW | <<TBD>> |
| <<TBD: Asset 2>> | <<TBD>> | <<TBD>> |
| <<TBD: Asset 3>> | <<TBD>> | <<TBD>> |
| <<TBD: User PII>> | HIGH | <<TBD: DB + columns>> |
| <<TBD: Crypto secret>> | CRITICAL | HSM only |
| <<TBD: Audit log>> | HIGH | DB hash-chained |
| <<TBD: API key>> | MEDIUM | DB (hashed) |
| <<TBD: Source code>> | MEDIUM | GitHub |

## 2. STRIDE per боундари

### 2.1 <<TBD: Boundary 1 — e.g., Mobile App ↔ Backend>>

| Threat | Likelihood | Impact | Mitigation |
|---|---|---|---|
| **S** <<TBD: Stolen device impersonation>> | Med | High | <<TBD>> |
| **S** <<TBD: Replay attack>> | Low | Med | <<TBD: timestamp + nonce>> |
| **T** <<TBD: Modify request body>> | Low | High | <<TBD: TLS + body HMAC>> |
| **R** <<TBD: User claims didn't sign>> | Low | High | <<TBD: audit log + TSA>> |
| **I** <<TBD: Sniff token>> | Low | Low | <<TBD>> |
| **D** <<TBD: DDoS>> | Med | Med | <<TBD: rate limit>> |
| **E** <<TBD: Compromise device privilege escalation>> | Low | Med | <<TBD>> |

### 2.2 <<TBD: Boundary 2 — RP ↔ Backend>>

| Threat | Likelihood | Impact | Mitigation |
|---|---|---|---|
| **S** <<TBD: Stolen API key>> | Med | High | <<TBD: IP whitelist + rotation + audit>> |
| **S** <<TBD: RP impersonation>> | Low | High | <<TBD>> |
| **T** <<TBD>> | Low | High | <<TBD>> |
| **R** <<TBD>> | Low | Med | <<TBD>> |
| **I** <<TBD: Enumerate users>> | Med | Med | <<TBD: rate limit + generic 404>> |
| **D** <<TBD: DDoS>> | Med | High | <<TBD>> |
| **E** <<TBD: Get sign permission without contract>> | Low | High | <<TBD: explicit permission flag>> |

### 2.3 <<TBD: Boundary 3 — Backend ↔ Database>>

| Threat | Likelihood | Impact | Mitigation |
|---|---|---|---|
| **S** <<TBD: SQL injection>> | Low | CRITICAL | <<TBD: sqlc parameterized>> |
| **T** <<TBD: Modify audit log>> | Med | High | <<TBD: hash chain>> |
| **R** <<TBD>> | Low | Med | <<TBD>> |
| **I** <<TBD: Data leak via backup>> | Low | High | <<TBD: GPG encrypt>> |
| **D** <<TBD: Connection exhaustion>> | Med | Med | <<TBD: pool size + timeout>> |
| **E** <<TBD>> | Low | High | <<TBD>> |

### 2.4 <<TBD: Boundary 4 — Backend ↔ External services>>

| Component | Threat | Mitigation |
|---|---|---|
| <<TBD: Vendor 1>> | <<TBD>> | <<TBD>> |
| <<TBD: Vendor 2>> | <<TBD>> | <<TBD>> |
| <<TBD: TSA>> | <<TBD>> | <<TBD: cert pinning>> |
| <<TBD: Push provider>> | <<TBD>> | <<TBD>> |

## 3. Аж ахуйн нэгжийн анги

### 3.1 Insider threats

| Insider | Threat | Mitigation |
|---|---|---|
| Backend developer | <<TBD: code adds backdoor>> | <<TBD: PR review + signed commits>> |
| SRE | <<TBD: prod DB exfil>> | <<TBD: audit log + RBAC>> |
| <<TBD: HSM Operator>> | <<TBD: alone use HSM>> | <<TBD: 2-of-3 PIN quorum>> |
| <<TBD: Customer Support>> | <<TBD: bogus revoke>> | <<TBD: 2-staff approval>> |

### 3.2 External attacker capabilities

We model adversary as:

- **Network attacker** — observes/modifies TLS traffic (mitigated by <<TBD>>).
- **Phishing attacker** — tricks user (mitigated by <<TBD>>).
- **Compromised partner** — has API key (mitigated by <<TBD>>).
- **Endpoint compromise** — user device malware (mitigated by <<TBD>>).

We do NOT defend against:

- Nation-state with **physical access** to <<TBD>> (out of scope).
- <<TBD: Quantum computer>> (future migration plan).
- Compromise of <<TBD: vendor>> infrastructure.

## 4. Хариу үйлдэл

Шинэ threat ил гарвал:

1. Issue track хийнэ (security@<<TBD>>).
2. Mitigation код / config / process change-аар хэрэгжинэ.
3. Threat model шинэчлэгдэнэ (next_review талбар).
4. Affected документуудыг (CP, CPS, runbook) шинэчлэх.

## 5. Үнэлгээний матриц

```
Likelihood × Impact = Risk

           Low    Med    High   Critical
Low         1      2      4       8
Med         2      4      8      16
High        4      8     16      32
```

Risk ≥ 8 нь P1 mitigate. Risk ≥ 16 нь P0.

## 6. Шинэчлэлт

- Annual full review (next_review).
- After major architectural change.
- After security incident.
- After pen-test findings.

## 7. References

- [STRIDE](https://en.wikipedia.org/wiki/STRIDE_(security))
- [OWASP Top 10](https://owasp.org/Top10/)
- [MITRE ATT&CK](https://attack.mitre.org/)
- <<TBD: NIST SP 800-XX>>
