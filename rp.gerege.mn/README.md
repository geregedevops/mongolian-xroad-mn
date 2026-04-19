# rp.gerege.mn — Producer Security Server (GEREGE-ID services)

**Public IP:** 38.180.251.163
**Owner:** Gerege Systems LLC (`MN/COM/6235972`)
**Member-server code:** `RP-SS-1`
**X-Road version:** 7.8.0 (Ubuntu 24.04)
**Role:** X-Road producer SS that publishes the GEREGE-ID identity services as REST/OpenAPI3.

## Subsystems on this SS

| Subsystem code | Status     | Purpose                                                   |
|----------------|------------|-----------------------------------------------------------|
| (owner)        | REGISTERED | Gerege Systems LLC owner client (no services published)   |
| `GEREGE-ID`    | REGISTERED | Real auth/sign/cert services backed by gerege.mn backend  |

## Published REST services (OpenAPI3)

Service descriptions are hosted as static YAML at `https://ca.gerege.mn/xroad/openapi/{auth,sign,cert}.yaml` and added to GEREGE-ID via UI → Services → Add REST → OpenAPI 3 Description.

| Service code | OpenAPI URL                                          | Operations                                                                                       |
|--------------|------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| `auth-svc`   | `https://ca.gerege.mn/xroad/openapi/auth.yaml`       | `POST /auth/initiate`, `GET /auth/session/{id}`                                                  |
| `sign-svc`   | `https://ca.gerege.mn/xroad/openapi/sign.yaml`       | `POST /sign/initiate`, `GET /sign/session/{id}`                                                  |
| `cert-svc`   | `https://ca.gerege.mn/xroad/openapi/cert.yaml`       | `POST /certificate/validate`, `GET /certificate/lookup/{national_id}`                            |

## Information System (the gerege backend)

GEREGE-ID forwards every X-Road call to `https://ca.gerege.mn/xroad/v1/...`. The producer SS expects a TLS server cert it trusts, so the Let's Encrypt cert for `ca.gerege.mn` is uploaded under **Internal Servers → Information System TLS certificate**. Connection type for the producer role is inferred from the OpenAPI server URL scheme — `https` here, which is why the IS cert is required.

## Access control

Granted via Services tab → expand each operation → Add subjects:

| Subject (subsystem)            | Granted on                                   |
|--------------------------------|----------------------------------------------|
| `MN/COM/6884857/TEST-DEMO`     | all operations of `auth-svc`, `sign-svc`, `cert-svc` |

X-Road defaults to deny — any new partner subsystem (e.g. a bank's payment app) must be added explicitly here. That's the ONLY authorization step (no backend DB write needed; see HISTORY 2026-04-19 X-Road Gateway refactor).

## Required prerequisites — these lessons were earned the hard way

1. **TSP entry** in Settings → System Parameters → Timestamping Services → TimeServer.mn. Without it, even the SS-internal log-timestamper backs off and refuses incoming requests with `no_timestamping_provider_found`.
2. **AUTH cert + SIGN cert** issued by the Gerege CA (xroad_auth + xroad_sign profiles in `gerege.mn/xroad-ca/xroad-extensions.cnf`). Both must be in `registered` state on CS, both must be `active` in `keyconf.xml`. The SIGN cert may need to be activated manually after issuance.
3. **OCSP responder must be reachable AND fresh.** `incorrect_validation_info: OCSP response is too old` means the `gerege-ocsp` container hasn't refreshed its responses against the configured 3600s freshness window — restart the container and `xroad-signer` here.
4. **CS-side UFW** must `allow from 38.180.251.163 to any port 4001 proto tcp` and the same for `4002` so this SS can fetch globalconf and submit `clientReg`.

## What lives in this folder

- `xroad/configuration-anchor.xml` — the same anchor distributed by CS to every member SS.
- `xroad/conf.d-local.ini` — sanitized.
- `xroad/etc-listing.txt` — listing of `/etc/xroad/conf.d` and `/etc/nginx/sites-enabled` so future operators know what to grep for.
