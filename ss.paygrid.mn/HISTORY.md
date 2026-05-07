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

## Open loops (Phase 3)

1. **Service-client grants on rp.gerege.mn** — ask Gerege Systems
   LLC to add `MN/COM/7181609/PAYGRID-CORE` to the access list of
   `auth-svc`, `sign-svc`, `cert-svc` on `GEREGE-ID` (rp.gerege.mn UI
   → Clients → GEREGE-ID → Services → expand each service → Add
   subjects). Until then every paygrid call to GEREGE-ID is denied
   with `Service-clients ACL denied`.
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
