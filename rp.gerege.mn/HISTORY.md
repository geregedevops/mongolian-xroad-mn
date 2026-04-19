# rp.gerege.mn — operational history

## 2026-04-19 — Original Ubuntu reinstall (24.04) so we could reuse cached debs

**Context:** First install attempt on Ubuntu 22.04 stalled when the NIIS apt download hit a slow mirror (`xroad-securityserver` package partially fetched, repeated `apt install` retries hung at ~35MB).

**Decision:** Reinstall the OS to Ubuntu 24.04 so the cached `xroad-*.deb` files from `mgmt.gerege.mn` (also Ubuntu 24.04) could be reused without going through apt at all.

**Procedure:**
```bash
ssh mgmt.gerege.mn 'sudo tar -C /var/cache/apt/archives -czf - $(ls /var/cache/apt/archives/xroad-*.deb | xargs -n1 basename)' \
  | ssh rp.gerege.mn 'cat > /tmp/xroad-debs.tar.gz && sudo tar -C /var/cache/apt/archives -xzf /tmp/xroad-debs.tar.gz'
ssh rp.gerege.mn 'sudo apt-get install -y xroad-securityserver'  # now resolves dependencies from local cache
```

**Watch out:** If the next member SS goes onto a different Ubuntu major (e.g. 26.04), this trick won't work because the .deb dependencies won't match. Bring up a fresh apt mirror or use `apt-get download` from a known-good source instead of fighting NIIS's flaky CDN.

## 2026-04-19 — Initial Configuration Wizard

Member identity `MN/COM/6235972/RP-SS-1`. Server code chosen so the rp prefix is obvious in CS UI.

After wizard completion, the SS has zero subsystems (just the owner client). Subsystems get added later via Add subsystem.

## 2026-04-19 — CSR signing oddities at gerege.mn portal

**Symptom 1:** Both AUTH and SIGN CSRs came back from the portal with the same filename `<x>.sign.cer`.

**Root cause:** The portal frontend defaulted "profile" dropdown to `sign` regardless of which CSR was being signed. Operators were ticking the wrong dropdown.

**Fix:** Patched `eid-gerege-web/src/app/dashboard/organizations/page.tsx` to auto-detect profile from CSR filename:
```js
if (n.includes("auth_") || n.includes("auth-") || n.includes("securityserver")) setXroadProfile("auth");
else if (n.includes("sign_") || n.includes("sign-") || n.includes("member")) setXroadProfile("sign");
```

**Symptom 2:** Cert import returned `error_code.core.internal_error` on the SS UI.

**Root cause:** Go x509 backend was reconstructing the subject from parsed RDN components and dropping the `businessCategory` OID (2.5.4.15), which X-Road requires for SIGN certs.

**Fix:** `eid-gerege-backend/internal/service/xroad_csr.go` patched to keep the original DER subject:
```go
Subject:    csr.Subject,
RawSubject: csr.RawSubject, // preserve businessCategory
```

**Watch out:** Both fixes are committed in the `gerege-mn-eid` repo. If a CSR signing flow ever returns wrong-profile certs or `internal_error`, suspect (a) profile-detection regression or (b) raw-subject preservation regression first.

## 2026-04-19 — `Invalid X.509 certificate` on cert import

**Symptom:** After CSR signing, importing the signed cert into rp UI returned "Invalid X.509 certificate".

**Root cause:** Globalconf on rp had not refreshed since the new Issuing CA cert was added on CS — so rp didn't recognize the cert's issuer as "approved".

**Fix:** `sudo systemctl restart xroad-confclient && sudo systemctl restart xroad-signer`.

**Watch out:** Any time the CA chain is touched on CS side, give every member SS a confclient restart cycle before troubleshooting their cert imports.

## 2026-04-19 — Auth cert was active=false even though registered

**Symptom:** UI showed AUTH cert in `registered` status but produced `Security server has no valid authentication certificate` when calling out.

**Root cause:** SS's `keyconf.xml` had `<cert active="false">` for the AUTH cert. Some manual step (clicking a row?) had toggled it off, or it was never activated after import.

**Fix:** UI → Keys and Certificates → expand AUTH key → click cert → Activate.

**Watch out:** After importing a cert, ALWAYS verify it is both `registered` AND `active`. The SS gives no warning when it's only registered.

## 2026-04-19 — `ssl_authentication_failed: Client 'SUBSYSTEM:MN/COM/6235972/GEREGE-ID' has no IS certificates`

**Symptom:** When a TEST-DEMO consumer hit GEREGE-ID, rp.gerege.mn rejected the call before reaching its IS.

**Root cause:** GEREGE-ID's published OpenAPI3 services use `https://ca.gerege.mn/xroad/v1/...` URLs. Provider-side TLS validation requires the IS cert to be uploaded.

**Fix:** Internal Servers → Information System TLS certificate → Add → upload the Let's Encrypt fullchain for ca.gerege.mn (`/etc/letsencrypt/live/ca.gerege.mn-0001/fullchain.pem`).

**Watch out:** Let's Encrypt certs renew every ~90 days. If the auto-renew rotates the cert chain (root CA rotation), this upload becomes stale. Build a cron / monitoring alert for IS cert expiry separate from nginx's own renewal.

## 2026-04-19 — GEREGE-ID Register pending forever, then `no_timestamping_provider_found`

**Symptom:** Click Register, sit on PENDING, eventually fail with TSP error.

**Root cause:** TSP entry was missing on rp.gerege.mn. Same problem as on mgmt — Initial Config Wizard does not pre-fill the timestamping service.

**Fix:** UI → Settings → System Parameters → Timestamping Services → Add → TimeServer.mn.

**Watch out:** Just like mgmt SS, EVERY member SS needs this. Add it as the first thing after the wizard, before troubleshooting any registration flow.

## Watch list for the next operator

- **Three OpenAPI3 services published** (auth-svc, sign-svc, cert-svc) backed by static YAML at `https://ca.gerege.mn/xroad/openapi/`. If the YAML moves or the URL changes, refresh the description in UI → Services → click the OPENAPI3 row → Edit.
- **Service-clients ACL** is per-operation, not per-service. When adding a new partner subsystem, expand each service description and tick all operations. The yellow lock vs green lock indicator is the easiest way to spot a missed grant.
- **No backend DB sync per partner** (revised 2026-04-19). The earlier `xroad_subsystems` mirror table was DROPPED. The backend now has exactly one `relying_parties` row — the X-Road Gateway — and trusts every caller arriving via /xroad/v1 (nginx IP-pinned + shared token). Granting Service-client access on this UI is the ONLY step needed. Per-subsystem identity flows via `X-Road-Client` header into `sessions.xroad_client`.
