# timeserver.mn — operational history

## 2026-04 — Initial install (Sigstore TSA + self-signed chain)

Sigstore Timestamp Authority installed from upstream releases as `/usr/local/bin/timestamp-server`, run under systemd as `timestamp-authority.service`. Cert chain shipped from Sigstore's `gen-certs.sh` template:

```
TimeServer.mn Root CA            (self-signed, EC P-384)
└── TimeServer.mn Intermediate CA (CA:TRUE pathlen:0, EKU critical timeStamping)
    └── TimeServer.mn TSA Signer  (leaf, EC P-256, KU+EKU per RFC 3161)
```

That worked fine in isolation but every Mongolian X-Road SS distrusted it because the TSA root wasn't in their `shared-params.xml` approved-CA list.

## 2026-04-19 — Rebuilt the chain to root in Gerege Root CA

**Goal:** Make the TSA leaf chain back to the same Gerege Root CA that anchors every other cert in the Mongolia X-Road network. Without this, every X-Road SS would reject TSP responses or have to maintain a separate trust anchor for the TSA.

**Procedure executed (from CCleaner log):**
1. Added `[xroad_tsa]` profile to `gerege.mn:/opt/xroad-ca/xroad-extensions.cnf` (KU critical digitalSignature, EKU critical timeStamping, AIA + CRL extensions).
2. Generated CSR on timeserver.mn from existing `leaf-key.pem` (no new key — reuse the same private key, just re-issue cert):
   ```bash
   openssl req -new -key /opt/tsa-certs/leaf-key.pem \
     -subj "/C=MN/O=Gerege Systems LLC/CN=TimeServer.mn TSA Signer" \
     -out /tmp/tsa-gerege.csr
   ```
3. **First attempt:** signed with Gerege Issuing CA + xroad_tsa profile. Sigstore TSA refused to start with `panic: certificate must have extended key usage timestamping set`.
4. **Diagnosis:** Sigstore TSA validates that EVERY non-root cert in `certchain.pem` has `id-kp-timeStamping` EKU. Gerege Issuing CA has no EKU restriction so it doesn't qualify.
5. **Fix:** Created a dedicated `Gerege TSA Issuing CA` intermediate signed by Root CA with `EKU critical timeStamping` in addition to `keyCertSign+CRLSign`. Re-signed the leaf under THIS intermediate.
6. Replaced `/opt/tsa-certs/leaf-cert.pem` and `/opt/tsa-certs/certchain.pem` (= leaf + tsa-issuing + root). `systemctl restart timestamp-authority`. Started cleanly.

**Watch out:** Don't try to sign the TSA leaf directly under Gerege Issuing CA. Even though it's "the obvious thing", Sigstore will reject. Always use the dedicated `Gerege TSA Issuing CA`.

## 2026-04-19 — CS shared-params still pointed at the old leaf cert hash

After the rebuild, every X-Road SS started getting `mlog.tsp_certificate_not_found` because shared-params held the OLD leaf cert (hash `40359...`) but the live TSA was signing with a NEW leaf cert (hash `BE6E60...`).

**Fix:** CS UI → Trust Services → Timestamping Services → delete the old `TimeServer.mn Root CA` row → add new entry with URL `https://tsa.timeserver.mn/` and the new leaf cert (`/opt/tsa-certs/leaf-cert.pem`). Wait ~60s for confclient on each member SS to refresh; restart `xroad-signer xroad-proxy` everywhere to clear caches.

**Watch out:** Whenever the leaf is rotated (annually-ish via `renew-leaf.sh`), repeat this CS-side update OR reuse the same leaf private key + cert (re-issuing the cert with the same key keeps the SignerID stable and avoids the CS-side change).

## 2026-04-19 — `cert-check.sh` cron added

Daily cron checks leaf cert expiry and alerts via email if < 14 days left. The `renew-leaf.sh` script automates the re-sign + restart but **does not** push the updated cert to CS — that's still a manual UI step.

**Watch out:** If `renew-leaf.sh` runs at 3am via cron and the operator doesn't notice for a week, every X-Road SS will start failing TSA verification. Either disable auto-renew or add a final step to the script that scp's the new leaf to a known location and pings an operator.

## Watch list for the next operator

- **`leaf-key.pem`** is the entire trust of the TSA. Backed up encrypted off-host but never duplicated to other servers. If lost, every previously-issued timestamp token becomes "unverifiable from this TSA" once we issue a new key — which is fine forensically (the old responses already include the old cert) but means we can't re-sign anything with the lost key.
- **NTP sync** is monitored via `ntpsync.yaml` — Sigstore TSA refuses to issue tokens if local clock is too far from upstream. If it ever stops issuing, check `chronyc tracking` first.
- **nginx HTTP-to-HTTPS redirect** intentionally exempts `/.well-known/acme-challenge/` so Let's Encrypt renewal works. Don't simplify by stripping this exemption.
- **Sigstore TSA version pinning** — we pin `timestamp-server v2.0.6`. Newer releases sometimes change the certchain validation rules; test in a sandbox before upgrading.
