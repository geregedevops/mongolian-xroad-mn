# mgmt.gerege.mn — Management Security Server

**Public IP:** 38.180.255.177
**Owner:** Gerege Systems LLC (`MN/COM/6235972`)
**Member-server code:** `MGMT-SS-1`
**X-Road version:** 7.8.0
**Role:** The "owner SS" of the Mongolia X-Road instance. Runs the `MANAGEMENT` subsystem that publishes the management-service WSDL with all 10 operations (`addressChange`, `authCertDeletion`, `clientDeletion`, `clientDisable`, `clientEnable`, `clientReg`, `clientRename`, `maintenanceModeDisable`, `maintenanceModeEnable`, `ownerChange`).

## How a member SS reaches us

Every member SS that wants to register a subsystem (e.g. `clientReg`) on the central server sends a signed X-Road message with `X-Road-Service: MN/COM/6235972/MANAGEMENT/{operation}`. mgmt SS receives it via its own `5500/tcp` server-proxy port, signs at its end, and proxies the request to the management-service backend hosted on cs.gerege.mn (`https://cs.gerege.mn:4002/managementservice/manage/`).

## Required configuration on this SS — order matters

1. **TSP entry.** Settings → System Parameters → Timestamping Services → Add → TimeServer.mn (URL `https://tsa.timeserver.mn/`). Without this, `clientReg` from any member SS fails with `mlog.no_timestamping_provider_found` — the failure surfaces back at the member, not here, which is confusing.
2. **MANAGEMENT subsystem WSDL.** Clients → MANAGEMENT → Services → Add WSDL → `http://cs.gerege.mn/managementservices.wsdl`. After enable, all 10 services become callable.
3. **Set service URLs to** `https://cs.gerege.mn:4002/managementservice/manage/` for each operation (use "Apply to all in WSDL").
4. **Grant `security-server-owners` access** on every service (Service clients → Add subjects → security-server-owners). Default deny means without this any `clientReg` returns `service_failed.access_denied`.
5. **IS TLS certificate.** Internal Servers → Information System TLS certificate → Add → upload the cert nginx serves on `cs.gerege.mn:4002` (self-signed by X-Road CS install). Without this, the proxy step fails with `ssl_authentication_failed: has no IS certificates`.

## What lives in this folder

- `xroad/configuration-anchor.xml` — the public anchor downloaded from cs.gerege.mn at install time. Distributing this file is what tells `xroad-confclient` where to fetch globalconf.
- `xroad/conf.d-local.ini` — sanitized `/etc/xroad/conf.d/local.ini`. Real backup-encryption-keyids redacted.

## Reminder

Anything that affects the "control plane" of the entire MN instance (member registration, address change, maintenance mode) flows through this SS. Don't disable it casually — every other SS depends on it being reachable to manage their own clients.
