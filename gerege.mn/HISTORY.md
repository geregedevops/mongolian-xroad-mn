# gerege.mn — operational history

This host carries more state than any other in the ecosystem (Root + Issuing CA + TSA Issuing CA + OCSP responder + CRL distribution + sign portal + the X-Road IS at /xroad/v1). Most incidents in the network start or end here.

## Pre-2026-04 — PKI hardening (SoftHSM2 + autobackup + serial fix)

The Gerege CA stack was originally a vanilla openssl install. Three hardening passes happened earlier this year:

1. **SoftHSM2 backbone for issuing operations** — issuing CA private key migrated into a SoftHSM2 token so the bare key file is not on disk during signing. Root CA key is still on disk for offline use only.
2. **Daily automatic backup cron** — Issuing CA + Root CA + DB schema → encrypted tarball uploaded off-host.
3. **Leading-zero serial bug** — `gerege-ocsp` used to drop the leading zero byte from positive cert serials, breaking lookups for any cert whose serial happened to start with `0x00`. Patched and verified with hash equality of stored vs returned serial bytes.

**Watch out:** EC-HSM code refactor in `gerege-ocsp/backend` is still pending. Until that lands, the OCSP responder uses an in-memory key copy at startup; if the SoftHSM token is rotated mid-run the responder must be restarted to pick up the new key.

## 2026-04-19 — `/xroad/v1` IS endpoint added behind nginx IP gate

**Goal:** Expose the existing /rp/v1 backend handlers under a separate `/xroad/v1` path so:
- the X-Road consumer flow has clean audit/log boundary vs legacy API-key callers,
- nginx can apply IP gating + token injection independently of the API-key auth,
- future deprecation of /rp/v1 doesn't ripple into the X-Road path.

**What was added:**
- `eid-gerege-backend/internal/middleware/xroad_auth.go` → new `XRoadOnly` middleware that requires `X-Gerege-SS-Token` to match the env-configured value AND `X-Road-Client` header to be set. No API-key fallback.
- `eid-gerege-backend/cmd/server/main.go` → registers `/xroad/v1` route group with `XRoadOnly`, reusing the same `rp.RegisterRoutes(g, svc)`.
- `nginx/ca.gerege.mn.conf` → new `location /xroad/v1/` block that returns 403 unless `$remote_addr == 38.180.251.163` (rp.gerege.mn), then injects `proxy_set_header X-Gerege-SS-Token "..."` before proxying to backend.
- `XROAD_SS_TOKEN` env var → `openssl rand -hex 32` → written into `/opt/gerege-mn-eid/eid-gerege-backend/.env` AND into the nginx proxy_set_header. Both must match exactly.

**Watch out:** When rotating `XROAD_SS_TOKEN`, update BOTH the nginx config and the backend `.env` in the same atomic deploy (otherwise requests will 401 for a window). The token literal value lives only on this host — repo only references the env var name.

## 2026-04-19 — `gerege-ocsp` cache freshness keeps biting

**Symptom:** Periodically (especially after long idle periods or container restart) every X-Road SS sees `incorrect_validation_info: OCSP response is too old`.

**Root cause:** `gerege-ocsp` caches signed OCSP responses for `freshness * 0.7` seconds. The X-Road default freshness window is 3600s, so a cached response older than ~42 minutes will still be served by the responder but rejected by every consumer.

**Workaround:** `docker restart gerege-ocsp` flushes the cache and triggers a fresh sign.

**Real fix (TODO):** Make `gerege-ocsp` compute thisUpdate/nextUpdate dynamically each request (re-sign on demand) instead of caching a frozen response. There's a stub for this in the gerege-ocsp repo but it is not yet wired into the request handler.

**Watch out:** If you set up monitoring, alert on "OCSP response age > 1800s as observed by xroad-signer.log on any member SS". That gives a 30-min warning before the 60-min hard fail.

## 2026-04-19 — Cyrillic national_id failed via X-Road but worked via direct curl

**Symptom:** `GET /xroad/v1/certificate/lookup/МА74101813` via X-Road returned `{"has_certificate":false}` even though the user existed and had certs.

**Root cause:** X-Road producer SS forwards URL paths URL-encoded (`%d0%9c%d0%90...`). Fiber v2's `c.Params("national_id")` does NOT auto-decode percent-encoded segments. The DB query `WHERE national_id = '%d0%9c%d0%9074101813'` of course missed the user whose stored value is the decoded UTF-8 string `МА74101813`.

**Fix:** `eid-gerege-backend/internal/handler/rp/routes.go::certLookup` patched to wrap with `url.PathUnescape(c.Params("national_id"))`.

**Watch out:** Any handler that takes a path parameter and queries the DB by it has the same trap. Audit the codebase for `c.Params(...)` and add `url.PathUnescape` wherever the value can contain non-ASCII.

## 2026-04-19 — Sigstore TSA refused to start with non-Gerege intermediate

When we first tried to chain the TimeServer.mn TSA leaf under the existing Gerege Issuing CA, Sigstore TSA panicked at startup:
```
panic: certificate must have extended key usage timestamping set to sign timestamping certificates
```

**Root cause:** Sigstore TSA validates that EVERY non-root cert in `certchain.pem` carries `id-kp-timeStamping` EKU. The general-purpose Gerege Issuing CA has no EKU restriction, so a leaf signed under it gets the chain rejected by Sigstore at startup.

**Fix:** Carved out a dedicated `Gerege TSA Issuing CA` intermediate signed directly by the Root CA (`/opt/xroad-ca/tsa-issuing/`). Its profile (`tsa_issuing_ca` in `xroad-extensions.cnf`) is `CA:TRUE pathlen:0` with `EKU critical timeStamping`. The leaf is then signed under this intermediate.

**Watch out:** Don't sign any other type of leaf under `Gerege TSA Issuing CA` — its EKU restriction means any non-timeStamping cert issued from it would be silently rejected by validators that walk the chain (per RFC 5280 §4.2.1.12). It's a single-purpose CA.

## 2026-04-19 — `CertificateLookup` only returned `{has_certificate, kyc_level, expires_at}`, not the cert PEM

**Goal:** test.gerege.mn's PAdES build code needed the user's SIGN cert PEM up-front to compute the signed-attributes hash before requesting a signature.

**Fix:** Extended `eid-gerege-backend/internal/service/certificate.go::CertificateLookup` to return a `certificates[]` array with `{type, pem, serial_number, valid_until}` for each active cert. Backwards-compatible — the old fields are still there.

**Watch out:** Returning the full PEM means the cert lookup endpoint is now in scope for PII / privacy review. We mitigated by also swapping the `national_id` field's value to the user's `civil_id` (public) instead of regnum (private) — see next entry.

## 2026-04-19 — `national_id` field swap from regnum (private) to civil_id (public)

**Background:** In Mongolia the `регистрийн дугаар` (regnum, e.g. `МА74101813`) is considered personally sensitive and should not be returned to relying parties. The `civil_id` (e.g. `111949212017`) is the public identifier printed on the ID card.

**Fix:** In `routes.go::authSession` and `routes.go::signSession`, the `identity.national_id` field's *value* is now `*user.CivilID` when present (with regnum fallback). `service/certificate.go::CertificateLookup` does the same for its `national_id` response field.

The field NAME is unchanged for backwards-compat with consumers; only the value semantics shifted.

**Watch out:** Anything that joins on the API-returned `national_id` in a downstream system needs to know it is now a civil_id, not a regnum. Document this in partner onboarding material.

## 2026-04-19 — X-Road Gateway as single RP refactor (no per-partner DB writes)

**Goal:** Eliminate the parallel allowlist in eid-gerege-backend that mirrored every Service-clients grant on rp.gerege.mn. The user's directive: rp.gerege.mn's Service-clients ACL is the single source of truth — granting access there must be enough, with no INSERT into the backend DB.

**Procedure:**
1. Migration `013_xroad_gateway_rp.sql`: inserted ONE relying_parties row `00000001-0000-4000-8000-000000000000` "rp.gerege.mn X-Road Gateway"; added `sessions.xroad_client TEXT` and `audit_logs.xroad_client TEXT` columns.
2. `internal/middleware/xroad_auth.go::applyXRoadIdentity` rewritten — no more `repo.GetXRoadSubsystem` lookup; just sets `c.Locals("rp_id") = XRoadGatewayRPID` and `c.Locals("xroad_client") = header`. Constant `XRoadGatewayRPID` exposed for service-layer reuse.
3. `internal/service/session.go::AuthInitiate/SignInitiate` gained `xroadClient string` param; persisted to session row + audit details JSONB via `xroadClientDetails()` helper.
4. `internal/service/webauth.go::WebAuthInitiate/WebSignInitiate` and `internal/service/organization.go` org-register sign — switched from `GetRPByDomain("gerege.mn")` to `gatewayRPID()` + hardcoded `geregeWebXRoadClient = "MN/COM/6235972/GEREGE-WEB"` for in-process attribution.
5. Deleted: `internal/domain/xroad_subsystem.go`, `internal/repository/xroad_subsystem.go`, `Repository.GetRPByDomain`, migration `012_xroad_subsystems.sql`. Dropped table `xroad_subsystems`.
6. Wiped `sessions`, `audit_logs`, `tsa_logs` (pre-launch — no real customers, hash chain reset). Deleted Gerege Web/SSO/Sign/TestDemo rows from relying_parties.

**Onboarding playbook for new partners (post-refactor):**
1. Partner registers their subsystem via clientReg → CS approves
2. rp.gerege.mn UI → Clients → GEREGE-ID → Service clients → Add subjects → `MN/<class>/<code>/<subsystem>` → Save
3. Smoke test from partner's IS — that's it. No SQL on backend side.

**Watch out:** This means any subsystem with a Service-clients grant on rp.gerege.mn can call backend operations. The trust radius now encompasses the entire X-Road approval flow + nginx IP gate. If the IP gate is ever misconfigured (e.g. allows wider than rp.gerege.mn's IP), an attacker who can spoof the X-Gerege-SS-Token header would gain access. The shared token MUST stay secret + the IP gate MUST stay tight.

## 2026-04-19 — Cookie + Bearer dual-mode session auth on /web/*

`/web/*` endpoints now sit behind `WebSessionAuth` middleware (`eid-gerege-backend` commit 1d4986e). Browser flows receive an HttpOnly + Secure + SameSite=Lax cookie (`gid_sess`); native clients (Windows .NET, macOS Swift) receive the same opaque token in JSON via `POST /web/auth/session/:id/token` and send it as `Authorization: Bearer …`. Single Redis-backed session store, 1h rolling TTL.

Closes the IDOR vulnerability that let any caller read user data by passing `?user_id=<national_id>` in the URL. All `?user_id=` query params and `user_national_id` body fields removed end-to-end; dashboard/org/cloud routes now derive identity from the session token alone.

Pattern matches e-Estonia (TARA), island.is (Duende BFF), Suomi.fi, NemLog-in (MitID), BankID — every peer national-eID portal uses HttpOnly cookies + per-platform secret store, never JWT-in-localStorage. See `eid-gerege-backend/internal/middleware/web_session.go` and `desktop-apps/{macos,windows}-app/`. Auth-related code commits: 1d4986e (backend + web + desktop).

## 2026-04-19 — gerege-ocsp cache dropped — re-sign every request

Earlier this evening every-X-Road-call started failing with `Security server has no authentication certificate / clientproxy.ssl_authentication_failed` after roughly an hour of inactivity. Same incident hit Anicar Tasker subsystem registration earlier in the day, and mgmt SS the day before. Root cause finally diagnosed and committed (33f04ab on `gerege-mn-eid`):

`gerege-ocsp` had an in-memory LRU cache with `OCSP_CACHE_TTL_HOURS=4`. Cached responses had `thisUpdate` frozen at insert time. X-Road consumers' default freshness window is 3600s — so any cached response > 1h old was rejected by every consumer-side `OcspVerifier.verifyValidity` call, breaking SS-to-SS mTLS handshakes.

Fix: dropped the in-memory cache lookup entirely in `gerege-ocsp/internal/ocsp/responder.go::HandleRequest`. Every request now re-signs with `thisUpdate=now`. ECDSA P-256 sign is sub-millisecond; trivial vs the X-Road call latency budget.

`OCSP_CACHE_TTL_HOURS` env var is now dead config — only feeds the `nextUpdate` field, no caching happens. Future cleanup pass should remove the unused `cache` field and env var.

**Watch out (deprecated):** the operational dance `docker restart gerege-ocsp + systemctl restart xroad-signer` no longer needed. If "OCSP response is too old" recurs, the bug is probably in xroad-signer's own refresh schedule — not in our responder.

## 2026-04-19 — TSA cert fingerprint pinned + device HMAC key rotation backend

Two mobile-security improvements landed (commits 013b742 backend + d7894be docs):

- **TSA fingerprint pin** — `TSA_CERT_FINGERPRINT=be6e60c500aad60eda59ce3da3164305da622e5c058f69c60c7461a0221b7829` set in `.env`. The validator in `eid-gerege-backend/internal/tsa/client.go` now enforces fingerprint match instead of the previous warn-and-continue. Every leaf rotation (annual via `renew-leaf.sh`) MUST update this env value — see `timeserver.mn/HISTORY.md`.

- **Device HMAC key rotation** — `POST /mobile/device/rotate-key` accepts old-HMAC-signed request with new key in body, atomic UPDATE. Migration `014_device_key_rotation.sql` adds `key_rotated_at` column. Mobile-side flow (60-day cadence, Secure Enclave key gen, atomic local swap) designed but TODO — see `docs/mobile-security-roadmap.md`.

Two more designs await mobile build cycles: TLS cert pinning (recommend ISRG Root X1 + X2 SPKI dual-pin) and biometric-bound step-up auth on sign (Secure Enclave P-256, ECDSA over server-issued nonce).

## Watch list for the next operator

- **Root CA private key** is on disk at `/opt/gerege-mn-eid/eid-gerege-backend/config/pki/root-ca.key` and used only to sign new intermediate CAs. Move to offline storage when not actively in use; never commit.
- **Issuing CA private key** lives in SoftHSM2 token. PIN is in `reference_cs_secrets.md` (operator local memory). Rotating the PIN requires re-importing every cert reference — not a low-risk operation.
- **`xroad-ca/sign-xroad-csr.sh`** is a wrapper around openssl x509 -req. It accepts profiles `sign | auth | tsa`. If you add a new profile (e.g. for a new service role), update both `xroad-extensions.cnf` and the script's profile-validation line.
- **Let's Encrypt for ca.gerege.mn** — auto-renewed by certbot (cron). After renewal, rp.gerege.mn's IS TLS cert needs to be re-uploaded if the cert chain changed. Build a cron alert to remind you.
