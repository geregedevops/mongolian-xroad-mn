# ss.gerege.mn — operational history

## 2026-04 — Pre-existing install (Gerege Core LLC)

Was the first member SS deployed for the Mongolia X-Road instance after CS came up. Owner client `MN/COM/6884857` (Gerege Core LLC) registered via the standard mgmt-service flow.

## 2026-04-19 — Adding TEST-DEMO subsystem hit `Member 'SUBSYSTEM:MN/COM/6884857/TEST-DEMO' has no suitable certificates`

**Symptom:** Clicking Register on the new TEST-DEMO subsystem gave this error from `signer.internal_error`.

**Root cause:** Same OCSP staleness issue we saw on rp — the `gerege-ocsp` container had an old response (~1.5h) and the X-Road freshness window is 3600s. The signer dropped the SS's SIGN cert from its "suitable" set, so any new client request that needs to be signed fails.

Stack trace from `/var/log/xroad/signer.log`:
```
incorrect_validation_info: OCSP response is too old (thisUpdate: 2026-04-19T03:10:25Z)
  at OcspVerifier.verifyValidityAt(OcspVerifier.java:193)
  at OcspClientWorker.queryCertStatus(OcspClientWorker.java:278)
```

**Fix:**
```bash
ssh gerege.mn 'docker restart gerege-ocsp'
ssh ss.gerege.mn 'sudo systemctl restart xroad-signer'
```

After that the signer's OCSP refresh job logged "OCSP-response refresh cycle successfully completed" and the cert was suitable again. Retried Register → REGISTERED in seconds.

**Watch out:** This pattern (OCSP age > freshness → certs become "unsuitable") will hit ANY signing-cert use, not just registration. If you ever see "no suitable certificates", restart the OCSP container first, then the signer here.

## 2026-04-19 — `Security server has no valid authentication certificate` after the above fix

**Symptom:** Right after the OCSP/signer dance, retrying Register surfaced this new error.

**Root cause:** AUTH cert had `active="false"` in `keyconf.xml`. Same as on rp.gerege.mn — the Initial Config Wizard imports the cert as registered but does not auto-activate it.

**Fix:** UI → Keys and Certificates → expand AUTH key → click cert → Activate.

**Watch out:** Activate AUTH AND SIGN certs immediately after import. The UI gives no big red warning if either is inactive.

## 2026-04-19 — Consumer call to GEREGE-ID returned `Client (SUBSYSTEM:MN/COM/6884857/TEST-DEMO) specifies HTTPS but did not supply TLS certificate`

**Symptom:** From an internal IS (test.gerege.mn backend) calling `http://localhost/r1/MN/COM/6235972/GEREGE-ID/auth-svc/auth/initiate` with `X-Road-Client: MN/COM/6884857/TEST-DEMO`, got HTTP 500 with this message.

**Root cause:** TEST-DEMO subsystem's "Internal Servers → Connection type" was the default HTTPS (with auth). The IS (test.gerege.mn) was calling over plain HTTP from inside its docker network, so no client TLS cert was offered.

**Fix:** UI → Clients → TEST-DEMO → Internal Servers → Connection type → HTTP → Save.

**Watch out:** For a CONSUMER subsystem this knob controls how the local IS reaches the SS. For a PRODUCER subsystem the knob is irrelevant — provider-role connection type is inferred from the published service URL. Don't confuse the two.

## 2026-04-19 — UFW closed port 80 to test.gerege.mn host

**Symptom:** `curl http://ss.gerege.mn/r1/...` from `x-road.mn` (38.180.242.76) failed with timeout.

**Root cause:** UFW had explicit rules for `5500/tcp` (SS-SS message) and `5577/tcp` (OCSP) but not for the local consumer REST gateway on `80/tcp`.

**Fix:**
```bash
sudo ufw allow from 38.180.242.76 to any port 80 proto tcp comment "test.gerege.mn IS"
```

**Watch out:** This SS uses ports `80/tcp` and `443/tcp` for the consumer REST gateway (custom — X-Road defaults are 8080/8443). Any new IS host needs an explicit UFW rule. Don't open port 80 to public — anyone with network access can send X-Road requests as TEST-DEMO and consume our quota.

## Watch list for the next operator

- **Member ownership.** This SS is owned by Gerege Core LLC, not Gerege Systems LLC. They are separate legal entities even though both are "Gerege". The member identity in `keyconf.xml` and `serverconf.client` reflects this. Don't merge them.
- **TEST-DEMO is for live demo only** (test.gerege.mn landing page). Don't deprecate it without notice — the demo URL is publicly visible at https://test.gerege.mn and is part of the X-Road launch story.
- **Backups.** Same xroad-proxy daily backup → `/var/lib/xroad/backup/`. GPG backup keyid is REDACTED in the repo; real value in `reference_cs_secrets.md`.
