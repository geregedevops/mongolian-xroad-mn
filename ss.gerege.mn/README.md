# ss.gerege.mn — Consumer Security Server (Gerege Core LLC)

**Public IP:** 66.181.175.134
**Owner:** Gerege Core LLC (`MN/COM/6884857`)
**Member-server code:** `CORE-SS-1`
**X-Road version:** 7.8.0
**Role:** Consumer-side Security Server. Its information systems call X-Road producer services (currently GEREGE-ID on rp.gerege.mn).

## Subsystems on this SS

| Subsystem code | Status     | Purpose                                                                          |
|----------------|------------|----------------------------------------------------------------------------------|
| (owner)        | REGISTERED | Gerege Core LLC owner client                                                     |
| `TEST-DEMO`    | REGISTERED | Live demo consumer used by `test.gerege.mn`. Connection type **HTTP** (port 80). |

## How the consumer call works

1. Internal IS (e.g. `test.gerege.mn` backend) sends:
   ```
   POST /r1/MN/COM/6235972/GEREGE-ID/auth-svc/auth/initiate
   Host: ss.gerege.mn
   X-Road-Client: MN/COM/6884857/TEST-DEMO
   Content-Type: application/json
   { ...request body... }
   ```
2. ss.gerege.mn signs the message with the Gerege Core LLC SIGN cert, opens an mTLS X-Road connection to rp.gerege.mn:5500 using its AUTH cert, and forwards.
3. rp.gerege.mn validates the SS-side AUTH cert against globalconf, authorizes per Service-clients ACL, then proxies to the IS at `https://ca.gerege.mn/xroad/v1/...` which is the gerege backend.

## Inbound HTTP port for IS clients

The SS exposes the consumer REST gateway on **`80/tcp`** (custom from the X-Road default of 8080) and 443/tcp. Currently UFW allows port 80 from:

- `38.180.242.76` (`x-road.mn` host running test.gerege.mn).

When onboarding a new consumer IS, add a firewall rule for its public IP.

## Required configuration order

Same playbook as rp.gerege.mn:
1. Add TSP entry → TimeServer.mn.
2. Generate AUTH + SIGN keys + CSRs, sign at the Gerege CA, import + activate.
3. Register the SS with cs.gerege.mn (mgmt-service flow).
4. Add subsystem (e.g. `TEST-DEMO`) → Register.
5. Subsystem → Internal Servers → Connection type. For `TEST-DEMO` it is HTTP because `test.gerege.mn` calls the SS over HTTP from its docker network.

## What lives in this folder

- `xroad/configuration-anchor.xml`
- `xroad/conf.d-local.ini` — sanitized

## Renewal note

If the AUTH cert OCSP "good" cache lapses (default 3600s window in shared-params), every outgoing call to rp.gerege.mn fails with `Security server has no authentication certificate`. Restarting `xroad-signer` after `gerege-ocsp` container restart on gerege.mn is the standard fix.
