# ss.paygrid.mn — Member Security Server (paygrid.mn)

**Public IP:** `38.180.254.231`
**Owner:** Paygrid LLC — `MN/COM/<TBD-member-code>` *(member class + registry number to be filled in before completing the wizard; see HISTORY 2026-05-06)*
**Member-server code:** `PAYGRID-SS-1`
**X-Road version:** 7.8.0 (`xroad-securityserver`, generic profile, on Ubuntu 24.04 LTS)
**Role:** Member Security Server for the `paygrid.mn` ecosystem on the Mongolian X-Road instance `MN`. Initial direction: **consumer + producer hybrid** — paygrid IS calls partner producers (e.g. GEREGE-ID on rp.gerege.mn) and may publish its own services later. Final role split is part of the Phase-2 onboarding decision.

## Why a separate SS for paygrid

Paygrid runs its own information system stack and is a separate legal entity from Gerege Systems / Gerege Core. Putting paygrid into its own SS gives:

- A distinct member identity (`MN/COM/<paygrid-code>`) on every signed X-Road message — no commingling with `MN/COM/6235972` (Gerege Systems) or `MN/COM/6884857` (Gerege Core).
- Independent AUTH + SIGN cert lifecycle and key custody under paygrid's control.
- A clean firewall + ACL boundary: paygrid's IS hosts can only reach this SS, not the gerege-side SSes.
- Future-proofs paygrid for tri-party governance: when CS ownership shifts to Цахим хөгжлийн яам, paygrid's member registration on CS stays valid because the SS identity is portable.

## Subsystems on this SS *(planned — not yet REGISTERED)*

| Subsystem code        | Status   | Purpose                                                                          |
|-----------------------|----------|----------------------------------------------------------------------------------|
| (owner)               | TBD      | Paygrid LLC owner client                                                         |
| `<TBD-subsystem-1>`   | TBD      | Primary paygrid subsystem (e.g. `PAYGRID-CORE`, `PAYGRID-PAY`) — operator choice |

## Listening ports (post-firewall plan)

| Port    | Service                                    | Reachable from                                              |
|--------:|--------------------------------------------|-------------------------------------------------------------|
| 22      | sshd                                       | admin source-IPs                                            |
| 4000    | xroad-proxy-ui-api (admin UI)              | localhost only — use SSH tunnel `-L 14006:localhost:4000`   |
| 5500    | xroad-proxy server-proxy (SS-SS message)   | public — every peer SS must reach this                      |
| 5577    | xroad-proxy OCSP responder                 | public                                                      |
| 8080    | IS gateway — consumer REST                 | UFW-allowlisted IS hosts only (TBD which paygrid IS host)   |
| 8443    | IS gateway — consumer REST + TLS           | (same)                                                      |

UFW rules will mirror the ss.gerege.mn pattern but pinned to paygrid's IS host(s) and Gerege admin source-IPs. **Do NOT** open port 4000 to public — even briefly. The 2026-04-20 pre-prod showcase exposure on cs/mgmt/rp/ss was rolled back the same week (commits 8fc52a0, 1e327e7) and is not repeated here.

## Required onboarding sequence (Phase 2 — pending)

In the same playbook order as rp.gerege.mn / ss.gerege.mn:

1. **Decide member identity** — member class (almost certainly `COM` for an LLC), member code (paygrid registry number), subsystem code(s).
2. **Run the first-login wizard** at `https://ss.paygrid.mn:4000` after `ssh -L 14006:localhost:4000 ss.paygrid.mn`. Provide:
   - Configuration anchor → uploaded from `https://cs.gerege.mn:4000` *(Settings → System Settings → Configuration Anchor download)*.
   - Software-token PIN — store in operator's local memory store, never in repo.
   - Member class / code, server code (`PAYGRID-SS-1`).
3. **Add TSP entry** → `https://timeserver.mn`. Without it the signer refuses any signed-message flow with `no_timestamping_provider_found`.
4. **Generate AUTH + SIGN keys + CSRs** → sign at the Gerege CA (`xroad_auth` / `xroad_sign` profiles in `gerege.mn/xroad-ca/xroad-extensions.cnf`) → import + activate. Both must be `active="true"` in `keyconf.xml`; the wizard imports them as inactive.
5. **Register member + AUTH cert with CS** via the management-service flow (`mgmt.gerege.mn` MANAGEMENT subsystem). CS-side approval is required (`opsadmin` on cs.gerege.mn).
6. **Add subsystems** → Register each → set Internal Servers connection type. For consumer-side calls from paygrid IS over plain HTTP, set the type to `HTTP` (the same trap that bit ss.gerege.mn TEST-DEMO on 2026-04-19).
7. **Open CS-side UFW** for paygrid SS public IP on cs.gerege.mn ports `4001` (globalconf) + `4002` (mgmt service backend).
8. **Grant access on producer SSes** that paygrid will consume — e.g. add `MN/COM/<paygrid-code>/<subsystem>` as a service-client on rp.gerege.mn → GEREGE-ID services tab.

## What lives in this folder

- `README.md` — this file.
- `HISTORY.md` — install + operational log; every incident, fix, and gotcha.
- `xroad/configuration-anchor.xml` — copied from CS after wizard step 2 (Phase 2).
- `xroad/conf.d-local.ini` — sanitized snapshot of `/etc/xroad/conf.d/local.ini`.
- `xroad/etc-listing.txt` — listing of `/etc/xroad/conf.d` so future operators know what to grep for.

## Watch list for the next operator

- **Direct public IP, no NAT.** Unlike ss.gerege.mn (66.181.175.134, behind NAT to 10.0.0.27), this host has its public IP `38.180.254.231` directly on `eth0`. Means UFW is the only ingress filter — a misconfig here is internet-visible immediately. Default policy: deny incoming, allow established + the explicit per-port rules above.
- **Member identity is permanent.** Once `MN/COM/<code>/<subsystem>` is REGISTERED on CS, every signed X-Road message carries this identity forever. Pick the registry number once and don't change it. NIIS does not support member-code rename without re-registering every cert.
- **OCSP freshness applies.** Same `incorrect_validation_info: OCSP response is too old` trap that hit rp/ss on 2026-04-19. If paygrid's AUTH/SIGN cert ever becomes "unsuitable", restart `gerege-ocsp` on the CA host then `xroad-signer` here.
- **Monitoring.** This SS should be added to `monitor.x-road.mn` as the 7th scrape target — prometheus.yml `xroad-nodes` job + node_exporter on `:9100` (UFW source-pinned to `38.180.242.76`). Same pattern as the existing 6 hosts; no autossh tunnel needed because this SS has a direct public IP.
