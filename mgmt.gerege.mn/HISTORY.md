# mgmt.gerege.mn — operational history

## 2026-04 — Install + initial registration

Standard `xroad-securityserver` install on Ubuntu 24.04. Wizard run with member identity `MN/COM/6235972/MGMT-SS-1`, anchor downloaded from cs.gerege.mn.

AUTH + SIGN keys generated locally, CSRs taken to gerege.mn, signed via `/opt/xroad-ca/sign-xroad-csr.sh` (auth + sign profiles), certs imported back, both activated. clientReg approved on CS.

## 2026-04-19 — clientReg from rp.gerege.mn returned `Unknown service: SERVICE:MN/COM/6235972/MANAGEMENT/clientReg`

**Symptom:** rp.gerege.mn tried to register its GEREGE-ID subsystem; mgmt SS rejected with `Unknown service`.

**Root cause:** The MANAGEMENT subsystem on this SS had **zero services published** when first installed. Initial Configuration Wizard creates the MANAGEMENT subsystem entry but does not publish the services WSDL.

**Fix:** UI → Clients → MANAGEMENT → Services → Add WSDL → `http://cs.gerege.mn/managementservices.wsdl`. After enable, all 10 management services (addressChange, authCertDeletion, clientDeletion, clientDisable, clientEnable, clientReg, clientRename, maintenanceModeDisable, maintenanceModeEnable, ownerChange) became visible. Then "Apply to all in WSDL" with URL `https://cs.gerege.mn:4002/managementservice/manage/`. Then expand each service (or Service clients tab) and add `security-server-owners` global group as the access subject — without this every call returns `service_failed.access_denied`.

**Watch out:** This four-step setup (TSP → WSDL → URL → ACL) is the SAME on every Management Services SS. There is no "Initial config" UI flow that does it for you. The full checklist lives in `feedback_subsystem_register_checklist.md` (operator local memory) and is summarized in `mgmt.gerege.mn/README.md`.

## 2026-04-19 — `addressChange` service alone showed yellow padlock when others were green

**Symptom:** After adding `security-server-owners` access on the published WSDL, 9 services had a green padlock icon and `addressChange` had a yellow one.

**Diagnosis:** Yellow lock in X-Road UI = "no access rights configured for this operation". When access was added at the Service-clients tab (Add subjects → security-server-owners → tick all services), the row for `addressChange` was unchecked because the dialog's filter or scroll skipped it. Just expanded that row and added the subject manually.

**Watch out:** When granting access to many services in one go, double-check after by visually scanning the lock icons. A single unchecked service is invisible from any error message — the failure only surfaces when a partner tries to call it.

## 2026-04-19 — `mlog.no_timestamping_provider_found` even though TSA was alive at https://tsa.timeserver.mn/

**Symptom:** rp.gerege.mn `clientReg` returned this error. The error came back from the *response* of mgmt SS (look for `ClientMessageProcessor.checkResponse` in stack trace).

**Root cause:** mgmt SS had **zero TSP entries** in `serverconf.tsp` table. The Initial Config Wizard does not pre-fill timestamping services.

**Fix:** UI → Settings → System Parameters → Timestamping Services → Add → TimeServer.mn (URL `https://tsa.timeserver.mn/`). Service code stored as id=41 in this case.

**Watch out:** EVERY new SS in the network needs this entry. The X-Road message log requires a successful timestamp before the request flows through, and a brand-new SS has no defaults.

## 2026-04-19 — `ssl_authentication_failed: Client 'SUBSYSTEM:MN/COM/6235972/MANAGEMENT' has no IS certificates`

**Symptom:** clientReg from rp.gerege.mn produced this on mgmt SS. Connection type for MANAGEMENT was already HTTPS NO AUTH (consumer-side), but the error was on the **provider** side connection from mgmt SS to its IS at `cs.gerege.mn:4002`.

**Root cause:** When the published service URL is `https://cs.gerege.mn:4002/...`, X-Road requires an IS TLS certificate to validate the IS server cert. cs.gerege.mn:4002 nginx serves a self-signed cert (`CN=cs.gerege.mn`) issued at install time by the X-Road CS install scripts.

**Fix:** Fetched the cert with `echo | openssl s_client -connect cs.gerege.mn:4002 -servername cs.gerege.mn 2>/dev/null | openssl x509 -outform PEM`, uploaded under MANAGEMENT → Internal Servers → Information System TLS certificate.

**Watch out:** This cert is self-signed and thus will not auto-renew via Let's Encrypt. If cs.gerege.mn is reinstalled (or just regenerates its internal cert), repeat the upload.

## Watch list for the next operator

- The owner of mgmt SS must always be `Gerege Systems LLC` (`MN/COM/6235972`). Do not change ownership; the entire instance authorization model assumes the management services are signed by Gerege Systems' SIGN cert.
- Don't disable the MANAGEMENT subsystem — every member SS depends on it being reachable to manage their own clients. If you must take this SS down, schedule a maintenance window and put up a notice.
- `xroad_proxy_ui_api_admin_user` ssh users are listed in `/etc/xroad/conf.d` (host system users). Adding new admins requires creating the OS user AND tagging it with the `xroad-system-administrator` group, then `systemctl restart xroad-proxy-ui-api`.
