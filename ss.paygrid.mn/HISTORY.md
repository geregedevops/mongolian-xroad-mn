# ss.paygrid.mn — operational history

## 2026-05-06 — Fresh install of `xroad-securityserver` 7.8.0 on Ubuntu 24.04

First deployment of the paygrid Member Security Server. Provisioned as a
new VM (Datacamp/QEMU, KVM) with a directly-routed public IPv4
`38.180.254.231` on `eth0` — no NAT, unlike ss.gerege.mn which sits at
`10.0.0.27` behind a router.

### Host preparation

| Step                | Command / file                                                  | Notes                                                                  |
|---------------------|-----------------------------------------------------------------|------------------------------------------------------------------------|
| Hostname            | `hostnamectl set-hostname ss.paygrid.mn`                        | Was `a545500032.local` (cloud-provider default).                       |
| Timezone            | `timedatectl set-timezone Asia/Ulaanbaatar`                     | Project convention since commit 622f5ea (2026-04-19).                  |
| Locale              | `locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8`      | Inherited shell env had `LC_CTYPE=UTF-8` (truncated) — fixed.          |
| `/etc/hosts`        | `127.0.1.1 ss.paygrid.mn ss` + IPv6 stanza                      | Cloud default `38.180.254.231 a545500032.local` removed.               |
| SSH key             | `~/.ssh/ss_paygrid_mn` (ed25519, no passphrase) on operator mac | Operator-side Host alias added to `~/.ssh/config`.                     |
| Resources           | 15 GiB RAM, 6 vCPU, 79 GB disk (4.7 GB used)                    | Comfortably above NIIS minimum (4 GB / 2 CPU / 10 GB).                 |
| UFW                 | inactive at install time                                        | To be enabled in Phase 2 with explicit per-port rules (see README).    |

DNS is already live: `ss.paygrid.mn → 38.180.254.231` resolves at
`8.8.8.8`. No `/etc/hosts` workaround needed for FQDN-based callbacks.

### NIIS apt repository

```
deb [arch=amd64 signed-by=/usr/share/keyrings/xroad-niis.gpg] \
    https://artifactory.niis.org/xroad-release-deb noble-current main
```

Public key fetched from
`https://artifactory.niis.org/api/gpg/key/public`, dearmored to
`/usr/share/keyrings/xroad-niis.gpg` (mode 0644). `apt-cache policy
xroad-securityserver` confirmed candidate
`7.8.0-1.ubuntu24.04` — exact-match with `cs.gerege.mn`, `rp.gerege.mn`,
`ss.gerege.mn`, `mgmt.gerege.mn`.

### debconf pre-seed (for non-interactive install)

```
xroad-common	xroad-common/admin-username	string	xrd
xroad-common	xroad-common/database-host	string	127.0.0.1:5432
xroad-common	xroad-common/skip-cs-cert-validation	boolean	false
xroad-base	xroad-base/cert-distinguished-name	string	/CN=ss.paygrid.mn
xroad-base	xroad-base/cert-altnames	string	ss.paygrid.mn,38.180.254.231
xroad-securityserver	xroad-securityserver/admin-username	string	xrd
```

`xrd` is the X-Road admin Linux user (assigned the
`xroad-security-officer` group). After install, set the UI login
password with `passwd xrd`. The first-login wizard at port 4000
prompts for instance, member class, member code, server code, and
software-token PIN.

### Slow-download detour and the cross-host cache trick

**Symptom:** `apt-get install -y xroad-securityserver` from
`artifactory.niis.org` (Estonia) crawled at ~16 KB/s — `xroad-signer.deb`
(88 MB) took 22 minutes to reach 56 MB. End-to-end completion would
have been ~3 hours.

**Root cause:** Network throughput from `38.180.254.231` to
`artifactory.niis.org` was capped at ~93 KB/s (verified with `curl
--max-time 20`). Same host downloaded from
`archive.ubuntu.com` at 4.4 MB/s, so it was the artifactory side
(geographic distance / per-source rate-limit), not the Mongolian leg.

**Fix:** Cross-host apt cache reuse. `rp.gerege.mn` already had every
SS package cached from its own 2026-04-18 install:

```
xroad-addon-{messagelog,metaservices,proxymonitor,wsdlvalidator}
xroad-base
xroad-confclient
xroad-database-local
xroad-monitor
xroad-proxy
xroad-proxy-ui-api
xroad-securityserver  ← meta-package (generic, NO `-ee` country profile)
xroad-signer
```

Copied to `/tmp/xroad-debs/` on rp.gerege.mn (sudo + chmod 644),
then `scp -3` from the operator mac transferred them in-Mongolia to
`ss.paygrid.mn:/tmp/xroad-debs/`. Final step: `mv` into
`/var/cache/apt/archives/` so apt's checksum-match logic skips the
download and uses the local copies.

**Watch out:** Do NOT pull from `ss.gerege.mn` instead — it has
`xroad-securityserver-ee` (Estonian country profile, picked up
because the original install used the `-ee` apt name). For paygrid we
want the generic `xroad-securityserver` package since instance MN is
independent of any RIA/NIIS country verification rules. `rp.gerege.mn`
is the right source — it has only the generic profile.

### Install outcome

Second-pass `apt-get install -y xroad-securityserver` finished in **45
seconds** end-to-end (vs the projected 3 hours over the direct
artifactory link). Apt resolved every `xroad-*` deb against the now-
populated cache; only OpenJDK 21 + transitive Ubuntu deps came over
the network at archive.ubuntu.com's 4 MB/s. Liquibase applied
`serverconf` and `messagelog` schemas cleanly (including the
7.x `separate-admin-user` migration).

**Installed package set (12, all `7.8.0-1.ubuntu24.04`):**

```
xroad-base xroad-confclient xroad-database-local xroad-signer
xroad-monitor xroad-proxy xroad-proxy-ui-api xroad-securityserver
xroad-addon-messagelog xroad-addon-metaservices
xroad-addon-proxymonitor xroad-addon-wsdlvalidator
```

No country-profile suffix (`-ee`/`-fi`/`-is`/`-fo`) — generic profile,
matches `rp.gerege.mn`. **Differs from `ss.gerege.mn`** which has
`xroad-securityserver-ee + xroad-opmonitor + xroad-addon-opmonitoring`
(Estonian-profile + opmonitor stack, picked up by its 2026-04 install
script). Op-monitor can be added later if paygrid wants
service-level metrics; for now the lighter generic stack is enough.

**Services running (`systemctl is-active`):**

```
xroad-proxy           active    (java pid 11605, ports 5500/5577/8080/8443)
xroad-proxy-ui-api    active    (java pid 11449, port 4000)
xroad-signer          active
xroad-confclient      active
xroad-monitor         active
xroad-addon-messagelog active
xroad-base            active (oneshot, exited)
```

**Self-signed admin TLS cert (`/etc/xroad/ssl/proxy-ui-api.crt`):**

```
subject=CN = ss.paygrid.mn
issuer =CN = ss.paygrid.mn
SAN    = IP:38.180.254.231, DNS:ss.paygrid.mn, DNS:ss
```

The CN/SAN match the debconf preseed exactly — confirms the
`xroad-base/cert-distinguished-name` and
`xroad-base/cert-altnames` keys were honored by the postinst.

### Firewall — UFW enabled with closed admin UI

UFW was inactive immediately after install, leaving `:4000` (admin UI)
listening on `0.0.0.0` and externally reachable. This is the exact
exposure the 4-server audit on 2026-04-22 (commits `8fc52a0`,
`1e327e7`) closed across cs/mgmt/rp/ss. Avoided the same pre-prod
showcase mistake here by enabling UFW immediately after the
package install with explicit per-port rules:

```
ufw default deny incoming / allow outgoing
ufw allow 22/tcp                       # ssh
ufw allow 5500/tcp                     # X-Road SS-SS message
ufw allow 5577/tcp                     # X-Road OCSP responder
ufw enable
```

Port `4000` (admin UI), `8080`, `8443` (IS gateway) are intentionally
NOT opened — admin UI uses `ssh -L 14006:localhost:4000`, IS gateway
will be opened per-IS host once paygrid IS source is decided.

External `nc` probes from the operator mac confirmed:

```
38.180.254.231:22    succeeded
38.180.254.231:5500  succeeded
38.180.254.231:5577  succeeded
38.180.254.231:4000  TIMEOUT  ✓ (UFW)
38.180.254.231:8080  TIMEOUT  ✓ (UFW)
```

### Admin user `xrd` and the missing role groups

Created the Linux admin user matching the `xroad-securityserver/admin-username`
preseed:

```
adduser --gecos "X-Road admin" --disabled-password xrd
```

**Gotcha (worth flagging for next operator):** the 5 NIIS role groups
that `xroad-proxy-ui-api` PAM-checks are NOT created by any
postinst script in 7.8.0 — `xroad-base.postinst` only creates the
`xroad` system user. Verified the working pattern on
`ss.gerege.mn` (groups `xroad-security-officer`,
`xroad-registration-officer`, `xroad-service-administrator`,
`xroad-system-administrator`, `xroad-securityserver-observer` exist
with `xrd` as member of all 5). Reproduced on this host:

```
for g in xroad-security-officer xroad-registration-officer \
         xroad-service-administrator xroad-system-administrator \
         xroad-securityserver-observer; do
  groupadd "$g"
done
usermod -aG xroad-security-officer,xroad-registration-officer,\
xroad-service-administrator,xroad-system-administrator,\
xroad-securityserver-observer xrd
```

**Watch out:** if these 5 groups are absent, the UI login appears to
work (PAM accepts the password) but every UI action returns 403
because the proxy-ui-api authority check fails. The error in the
network trace is generic — easy to misdiagnose as a wrong
password.

**Password is NOT set in this session.** Operator must run
`ssh ss.paygrid.mn 'passwd xrd'` interactively to set their own
admin password. Per project policy, the password value is not
written to the repo or the conversation log; only "where to set it"
lives in `reference_*.md`-style operator memories.

### Admin UI reachability

Internal probe (`curl -k https://localhost:4000`) returns HTTP 200
with the expected NIIS Vue/Spring single-page app shell. From the
operator mac, use:

```bash
ssh -L 14006:localhost:4000 ss.paygrid.mn
# then open https://localhost:14006/ in the browser
# (browser will warn about self-signed cert — expected;
#  pinned by SAN ss.paygrid.mn, IP 38.180.254.231)
```

Port `14006` matches the per-host SSH-tunnel allocation pattern in
`docs/topology.md` (cs=14000, mgmt=14005, rp=14003, ss=14004,
new ss.paygrid.mn = 14006).

## 2026-05-06 — Phase 2 ran in the same session: wizard + certs + CS-registration

After the package install completed, the operator drove the
first-login wizard through the browser at `https://localhost:14006/`
(SSH tunnel `-L 14006:localhost:4000`). The full provisioning
sequence finished in one sitting; flagged here are the answers + the
state CS now holds.

### Wizard answers

| Field | Value |
|---|---|
| Configuration Anchor | downloaded from `https://cs.gerege.mn:4000` (Settings → System Settings → Configuration Anchor → Download), uploaded as-is. Identical bytes to `ss.gerege.mn/xroad/configuration-anchor.xml`. |
| Member Name | `Gerege Smart Metering` *(auto-resolved by CS — confirms member was pre-registered on CS as `centerui.security_server_clients` id=18)* |
| Member Class | `COM` |
| Member Code | `7181609` |
| Server Code | `PAYGRID-SS-1` |
| Token PIN | 16-char alphanumeric, set out-of-band; stored in operator memory only |

### Identity surprise

The repo's pre-install README/HISTORY assumed the owning legal entity
would be "Paygrid LLC". CS auto-fill on wizard step 2 corrected this
to **Gerege Smart Metering** (member code `7181609`) — paygrid.mn is
a brand domain, not a separate company. This is similar to how
`ss.gerege.mn` is operated by Gerege Core LLC (`6884857`) with the
domain `gerege.mn` shared across the umbrella. The repo docs were
updated in the same commit (this entry) to reflect the corrected
identity.

### TSP entry

Added via UI → Settings → System Parameters → Timestamping Services
→ Add → `https://tsa.timeserver.mn/`. CS-distributed
`shared-params.xml` lists `TimeServer.mn TSA Signer` (EC P-256 leaf,
Gerege-rooted) as the only approved TSA — same as every other SS in
this instance. Stored as `serverconf.tsp` row id=4.

### Cert flow (AUTH + SIGN)

UI → Keys and Certificates → on the auto-created software token
`softToken-0`:

- **AUTH key** `FDC3B8E0EAFF92867C0B5DECD2C0FAEA8E9FAC40` (RSA-2048).
  CSR generated with subject `CN=ss.paygrid.mn, serialNumber=7181609,
  C=MN, O=Gerege Smart Metering`, signed at the Gerege Issuing CA
  using the `xroad_auth` profile (`gerege.mn/xroad-ca/xroad-extensions.cnf`).
  Validity 2026-05-06 → 2028-08-08. AIA → `https://ocsp.gerege.mn/ocsp`,
  CDP → `https://crl.gerege.mn/issuing-ca.crl`. Imported and
  **activated** (manual click — wizard imports inactive).

- **SIGN key** `4859B35EB72758B468C90BF0FC20C0CA47B88344` (RSA-2048).
  CSR signed with `xroad_sign` profile; subject CN=`Gerege Smart Metering`,
  memberId `MN/COM/7181609`. Same Gerege Issuing CA chain. Imported
  and activated.

Watch out trap from ss.gerege.mn HISTORY (2026-04-19) — both certs
must show `active="true"` in `/etc/xroad/signer/keyconf.xml`. The
"Activate" click is easy to forget and produces no obvious UI
warning when skipped.

### CS-side registration of AUTH cert

Submitted from SS UI → Keys and Certificates → expand AUTH key →
Register. The auth-cert-reg request hit `cs.gerege.mn:4001`
(centerregistration-service); operator approved on the CS UI under
Management Requests. CS now lists this SS in
`centerui.security_servers` as id=7, server_code=`PAYGRID-SS-1`,
owner_id=18, address=`ss.paygrid.mn`. AUTH cert keyconf status
flipped from `registration in progress` to `registered`.

### CS UFW

Opened CS UFW for `38.180.254.231` on port `4002` (mgmt service
backend) to mirror the existing per-SS pattern (`mgmt.gerege.mn`,
`rp.gerege.mn`, `ss.gerege.mn` already had this rule). Port `4001`
(auth-cert reg) was already `ALLOW IN Anywhere` so the AUTH
cert reg flow worked immediately. Verified post-rule with curl from
ss.paygrid.mn:

```
http://cs.gerege.mn:4001/      → 400 Bad Request (TCP open, request rejected = OK)
https://cs.gerege.mn:4002/     → 403 Forbidden (TCP open, TLS+cert auth required = OK)
```

Before the rule was added the latter was a 5-second timeout — UFW
was dropping the SYN. Standard pattern for adding a new member SS
to instance MN.

## 2026-05-07 — First subsystem `PAYGRID-CORE` registered

Operator chose `PAYGRID-CORE` as the first subsystem code on this SS.
NIIS REST API is locked behind a CSRF-pattern session that needed an
API key to drive remotely (BasicAuth returns 401, form-login
JSESSIONID + X-XSRF-TOKEN still 403); rather than fight the auth
flow, the registration was driven through the UI in five clicks:

```
Clients → Add client → Subsystem
   Member Name : Gerege Smart Metering   (auto-fill from owner)
   Member Class: COM                     (auto)
   Member Code : 7181609                 (auto)
   Subsystem Code: PAYGRID-CORE
[Add] → status `saved`
[Register] on the new row → CS-side approval by opsadmin → status `REGISTERED`
```

Display name on CS UI: "PayGrid Core System" (free-form label, does
NOT change the X-Road identifier). The technical identifier is and
remains `MN/COM/7181609/PAYGRID-CORE`.

Final state, both sides:

```
ss.paygrid.mn  serverconf.client                id=6  status=registered  type=SUBSYSTEM
                                                 MN/COM/7181609/PAYGRID-CORE
cs.gerege.mn   centerui.security_server_clients id=19 type=Subsystem    name="PayGrid Core System"
cs.gerege.mn   centerui.server_clients          id=14 server=7 (PAYGRID-SS-1) → client=19
```

The `clientReg` request transited the standard mgmt-service path:

```
ss.paygrid.mn proxy
  → X-Road peer message MN/COM/7181609/(owner) → MN/COM/6235972/MANAGEMENT/clientReg
  → mgmt.gerege.mn:5500
  → mgmt SS proxies to https://cs.gerege.mn:4002/managementservice/manage/
  → CS centerregistration-service inserts into centerui.requests
  → opsadmin clicks Approve in CS UI
  → server_clients row materialised, request_processings closed
```

This is the canonical NIIS flow — **not** the legacy direct
`SS → CS:4002` shortcut. `ss.paygrid.mn` was added to the CS
`4002` UFW allow-list yesterday (2026-05-06) for completeness, but
the `clientReg` itself never used that path because it is wrapped in
an X-Road peer message and only mgmt SS opens a TCP connection to
CS:4002.

## 2026-05-07 — Service-client grant on `EIDMONGOL` (NOT GEREGE-ID)

Gerege Systems LLC opsadmin added `MN/COM/7181609/PAYGRID-CORE` to
the access list of `auth-svc` + `sign-svc` on
`MN/COM/6235972/EIDMONGOL` (rp.gerege.mn UI → Clients → EIDMONGOL →
Services → expand each operation → Add subjects). Visible in
rp.gerege.mn `serverconf.accessright` with `rightsgiven =
2026-05-07 09:55:27.33`.

**Important framing correction.** The early ss.paygrid.mn drafts
assumed paygrid would consume `GEREGE-ID` (the legacy stack on
ca.gerege.mn). The operator clarified mid-session that paygrid will
use **e-ID Mongolia v2** instead — the newer subsystem on the same
rp.gerege.mn SS, backed by `api.eidmongol.mn`. The grant correctly
landed on `EIDMONGOL`, not `GEREGE-ID`. All other v2 consumers
follow the same pattern (auth-svc + sign-svc, no cert-svc) — see
the full ACL in `rp.gerege.mn/README.md`.

**Why `cert-svc` is omitted in v2.** GEREGE-ID v1 exposed
`POST /certificate/validate` and
`GET /certificate/lookup/{national_id}`. The v2 stack folds those
into the auth callback (the IS receives the validated user info as
part of the auth-flow result), which removes the bulk-lookup
harvest surface. Don't request `cert-svc` for new v2 consumers
unless there's a specific use case the auth callback can't satisfy.

## 2026-05-07 — Added to `monitor.x-road.mn` Prometheus stack

Same-day onboarding of this SS into the existing observability stack
at `monitor.x-road.mn` (see `reference_xroad_monitor.md`):

1. **node_exporter on ss.paygrid.mn**:
   `apt install -y prometheus-node-exporter` — Ubuntu archive only,
   no NIIS download needed.
   Listens on `*:9100`, systemd unit `prometheus-node-exporter`
   active.
2. **UFW** on ss.paygrid.mn:
   `ufw allow from 38.180.242.76 to any port 9100/tcp` — source-pinned
   to the monitor host. Standard pattern (cs/mgmt/rp/gerege.mn/
   timeserver all use the same source-pin).
3. **prometheus.yml** on `x-road.mn:/opt/xroad-monitor/`:
   - `xroad-nodes` job: added `ss.paygrid.mn:9100` with labels
     `{ role: member-ss, host: ss.paygrid.mn,
        member: gerege-smart-metering }`. The `member: ...` label is
     new — first SS where it's worth distinguishing the owner since
     paygrid is the first non-Gerege-Systems / non-Gerege-Core
     member SS in this instance.
   - `xroad-tcp-probe` job: added `ss.paygrid.mn:5500` and
     `ss.paygrid.mn:5577` (parity with mgmt / rp / ss.gerege.mn).
   - File rewritten end-to-end via heredoc, NOT `sed -i` — the
     monitor memory specifically warns about an indent-corruption
     incident from in-place sed on this YAML.
   - Backup left at `/opt/xroad-monitor/prometheus.yml.bak.*`.
4. **Validate + reload**:
   ```
   docker exec xr-prometheus promtool check config /etc/prometheus/prometheus.yml
   docker kill -s HUP xr-prometheus
   ```
   `promtool` reported the config valid (1 rule file, 13 rules).
5. **Verify targets**:
   ```
   xroad-nodes      ss.paygrid.mn:9100  health=up
   xroad-tcp-probe  ss.paygrid.mn:5500  health=up
   xroad-tcp-probe  ss.paygrid.mn:5577  health=unknown (first cycle, becomes up)
   ```
   Unlike `ss.gerege.mn` this host is NOT behind NAT — direct
   public IP, no autossh tunnel. Prometheus scrapes directly on
   `ss.paygrid.mn:9100` over the internet, gated by the UFW
   source-pin on the SS side.

No alert-rule changes needed — the existing `xroad-host-health` and
`xroad-service-health` groups in `/opt/xroad-monitor/alerts/xroad.yml`
match by job, so the new target is automatically covered.

## 2026-05-07 — IS↔SS mTLS set up per NIIS world-standard pattern

`PAYGRID-CORE` Internal Servers → Connection Type stayed at the
NIIS default **`HTTPS`** (mutual-TLS). Following the canonical
NIIS UG-SS guidance and the Estonian RIA / Suomi.fi pattern: any
IS-to-SS connection that crosses a host boundary should be
mTLS-encrypted, with the IS authenticating itself via a TLS client
certificate that the SS holds in its pinned-cert list.

The Mongolian-X-Road precedent here is `ss.gerege.mn` /
`TEST-DEMO` — but that one was **deliberately downgraded** to
plain HTTP on port 80 because `test.gerege.mn` calls the SS from
inside its own docker network on the same physical host (HISTORY
2026-04-19). For paygrid the IS sits on a different VM
(`paygrid.mn`, 38.180.254.229) so the same downgrade is not
appropriate.

### IS client cert (paygrid.mn)

Generated on the IS host and stored at
`/etc/paygrid/xroad-is-tls/`:

```
paygrid-is-client.key   ECDSA P-256, mode 0600 root:root
paygrid-is-client.crt   self-signed leaf, CA:FALSE, EKU=clientAuth
                        CN=paygrid.mn-is-client
                        O=Gerege Smart Metering, C=MN, serialNumber=7181609
                        SAN=DNS:paygrid.mn
                        validity 2026-05-07 → 2031-05-06 (5 years)
                        SHA256 fingerprint:
                          B0:6C:EB:CB:A8:2B:4D:CE:A8:FC:EA:11:B0:2D:D0:9B:FF:4D:5C:20:F2:08:31:3A:A2:0A:4A:A6:59:FB:66:9F
```

NIIS pins the cert by **exact bytes match**, not chain validation
— self-signed leaf is correct (a CA chain would just be checked
for the leaf hash anyway). EKU `clientAuth` and CA:FALSE are still
set for cert hygiene and to satisfy strict TLS client libraries
that reject `CA:TRUE` leaves.

### SS-side configuration

1. **Upload** the leaf cert via UI → Clients → `PAYGRID-CORE` →
   Internal Servers tab → Information system TLS certificates →
   Add → upload `paygrid-is-client.crt`. Verify the displayed
   SHA256 fingerprint matches `B0:6C:EB:…:69`.
2. **Connection type** stays at `HTTPS` (default — equals "mTLS
   required" in NIIS terminology).
3. **UFW** on ss.paygrid.mn: `ufw allow from 38.180.254.229 to any
   port 8443 proto tcp`. Source-pinned to the IS host only — even
   with mTLS we don't expose the consumer-REST gateway to the open
   internet.

```
$ ufw status numbered (paygrid SS)
[5] 8443/tcp  ALLOW IN  38.180.254.229  # paygrid.mn IS client
```

### End-to-end smoke test ✅ passed 2026-05-07

After the operator uploaded `paygrid-is-client.crt` to the SS UI
and verified the SHA256 hash matched, ran the canonical
`listMethods` smoke test from the IS host:

```bash
curl --cert /etc/paygrid/xroad-is-tls/paygrid-is-client.crt \
     --key  /etc/paygrid/xroad-is-tls/paygrid-is-client.key \
     -k \
     -H 'X-Road-Client: MN/COM/7181609/PAYGRID-CORE' \
     https://ss.paygrid.mn:8443/r1/MN/COM/6235972/EIDMONGOL/listMethods
```

**Result:** HTTP 200, 839 ms, 563 bytes JSON. The response listed
exactly the two services PAYGRID-CORE has been granted access to:

```json
{"service":[
  {"member_class":"COM","member_code":"6235972",
   "subsystem_code":"EIDMONGOL","service_code":"sign-svc",
   "endpoint_list":[{"method":"POST","path":"/sign/initiate"},
                    {"method":"GET","path":"/sign/session/*"}],
   "object_type":"SERVICE","service_type":"OPENAPI",
   "xroad_instance":"MN"},
  {"member_class":"COM","member_code":"6235972",
   "subsystem_code":"EIDMONGOL","service_code":"auth-svc",
   "endpoint_list":[{"method":"POST","path":"/auth/initiate"},
                    {"method":"GET","path":"/auth/session/*"}],
   "object_type":"SERVICE","service_type":"OPENAPI",
   "xroad_instance":"MN"}
]}
```

This single call proves all five layers of the integration:

1. paygrid.mn IS → `ss.paygrid.mn:8443` **mTLS** handshake (the
   uploaded client cert is recognised by NIIS' pinned-cert
   matcher).
2. ss.paygrid.mn → `rp.gerege.mn:5500` X-Road peer-SS message
   (auth + sign certs both `active` + CS-registered).
3. rp.gerege.mn ACL check on `MN/COM/7181609/PAYGRID-CORE` for
   each EIDMONGOL service (yesterday's grants).
4. EIDMONGOL `listMethods` filtered by ACL — returns 2 services
   (auth-svc + sign-svc), no cert-svc, exactly as expected for
   the v2 pattern.
5. Reverse path back to the IS over the same channels.

`listMethods` is **ACL-aware** — if the grants were missing the
response would be an empty `service` array. Useful diagnostic
for debugging future ACL / cert / routing problems: the call
returns *something* if ANY layer below the ACL check works, and
the contents tell you whether the ACL did or didn't.

**Round-trip 839 ms is the cold-path number** (first-time TLS
session, confclient cache miss, peer-SS handshake). Subsequent
calls reuse session + cached globalconf and should land
< 300 ms.

### IS-side wiring (Phase 4 — paygrid backend team)

The paygrid Go backend (`/opt/paygrid-mn/paygrid-go/`) makes outbound
X-Road calls for EIDMONGOL auth + sign. Its HTTP client must
present the client cert + key when calling
`https://ss.paygrid.mn:8443/r1/MN/COM/6235972/EIDMONGOL/...`.
Reference for the Go backend (a `tls.Config` with
`Certificates: []tls.Certificate{cert}` and
`InsecureSkipVerify: true` on the SS's self-signed server cert,
or a custom RootCAs list pointing at the SS's
`/etc/xroad/ssl/proxy-ui-api.crt`).

### Why no SS→IS cert upload on the producer direction (yet)

When/if PAYGRID-CORE starts publishing services (e.g. payment
APIs back to partner banks), the SS must validate the IS server
cert when forwarding inbound X-Road requests to
`https://paygrid.mn/v1/...`. paygrid.mn runs Let's Encrypt for
its public TLS, and Java's default truststore already trusts LE,
so no extra "Internal Servers → Information System TLS server
certificate" upload is needed for the producer flow. Compare to
`rp.gerege.mn` which has the LE cert for `ca.gerege.mn` already
trusted by the same pathway.

## Open loops (Phase 3 — remaining)

1. ~~Service-client grants on rp.gerege.mn~~ ✅ done — see entry
   above. EIDMONGOL auth-svc + sign-svc granted to PAYGRID-CORE.
2. **PAYGRID-CORE Internal Servers connection type** — defaults to
   HTTPS-with-cert. If paygrid IS calls this SS over plain HTTP from
   inside its own docker network, switch to `HTTP` to avoid the
   `Client (SUBSYSTEM:MN/COM/7181609/PAYGRID-CORE) specifies HTTPS
   but did not supply TLS certificate` error.
3. **Producer-side OpenAPI3** — if paygrid eventually publishes
   metering APIs, host the YAML on a public TLS URL (mirror
   `https://ca.gerege.mn/xroad/openapi/...`) and add via UI →
   Services → Add REST → OpenAPI 3 Description on PAYGRID-CORE.
4. **Add to `monitor.x-road.mn`** (see `reference_xroad_monitor.md`):
   - install `prometheus-node-exporter` on this host
   - UFW allow `from 38.180.242.76 to any port 9100/tcp`
   - append target to `/opt/xroad-monitor/prometheus.yml`
     `xroad-nodes` job
   - direct public IP, no autossh tunnel needed (unlike ss.gerege.mn).
