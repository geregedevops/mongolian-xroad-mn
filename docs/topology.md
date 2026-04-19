# Topology — Mongolia X-Road (instance MN)

Frozen as of 2026-04-19.

## Hosts and X-Road identifiers

| Host                | IP             | xRoadInstance | memberClass | memberCode | subsystemCode | serverCode  | Role                |
|---------------------|----------------|---------------|-------------|-----------:|---------------|-------------|---------------------|
| `cs.gerege.mn`      | 38.180.203.234 | MN            | —           |          — | —             | —           | Central Server      |
| `mgmt.gerege.mn`    | 38.180.255.177 | MN            | COM         |    6235972 | MANAGEMENT    | MGMT-SS-1   | Management SS       |
| `rp.gerege.mn`      | 38.180.251.163 | MN            | COM         |    6235972 | GEREGE-ID     | RP-SS-1     | Producer SS         |
| `ss.gerege.mn`      | 66.181.175.134 | MN            | COM         |    6884857 | TEST-DEMO     | CORE-SS-1   | Consumer SS         |

(`memberCode` 6235972 = Gerege Systems LLC; 6884857 = Gerege Core LLC.)

## Listening ports (after host firewalls)

| Host                | Port     | Service                                    | Reachable from                                                |
|---------------------|---------:|--------------------------------------------|---------------------------------------------------------------|
| cs.gerege.mn        |       80 | Let's Encrypt + landing                    | public                                                        |
| cs.gerege.mn        |      443 | nginx (managementservices.wsdl, public)    | public                                                        |
| cs.gerege.mn        |     4000 | xroad-center UI                            | localhost (use SSH tunnel `-L 14000:localhost:4000`)          |
| cs.gerege.mn        |     4001 | nginx → confclient (globalconf download)   | every member SS                                               |
| cs.gerege.mn        |     4002 | nginx → mgmt service backend               | every member SS that calls mgmt                               |
| mgmt.gerege.mn      |     5500 | xroad-proxy server-proxy (incoming X-Road) | public                                                        |
| mgmt.gerege.mn      |     5577 | xroad-proxy OCSP responder                 | public                                                        |
| mgmt.gerege.mn      |     4000 | xroad-proxy-ui-api (admin UI)              | localhost (`-L 14005:localhost:4000`)                         |
| rp.gerege.mn        |     5500 | xroad-proxy server-proxy                   | public (consumer SSes connect here)                           |
| rp.gerege.mn        |     5577 | xroad-proxy OCSP                           | public                                                        |
| rp.gerege.mn        |     4000 | xroad admin UI                             | localhost (`-L 14003:localhost:4000`)                         |
| ss.gerege.mn        |     5500 | xroad-proxy server-proxy                   | public                                                        |
| ss.gerege.mn        |     5577 | xroad-proxy OCSP                           | public                                                        |
| ss.gerege.mn        |       80 | xroad-proxy IS gateway (consumer REST)     | UFW-allowlisted IS hosts only (test.gerege.mn 38.180.242.76)  |
| ss.gerege.mn        |      443 | xroad-proxy IS gateway with TLS            | (same)                                                        |
| ss.gerege.mn        |     4000 | xroad admin UI                             | localhost (`-L 14004:localhost:4000`)                         |
| gerege.mn           |      443 | nginx (gerege.mn, ca, ocsp, crl, sign)     | public                                                        |
| gerege.mn           |     8080 | eid-gerege-backend (behind ca.gerege.mn)   | nginx only                                                    |
| timeserver.mn       |      443 | nginx → Sigstore TSA (RFC 3161)            | public                                                        |
| timeserver.mn       |     3004 | timestamp-authority (Sigstore)             | localhost only                                                |

## TSA cert chain in `shared-params.xml`

The CS distributes `shared-params.xml` with a single `<approvedTSA>` whose `<cert>` is the LEAF cert (TimeServer.mn TSA Signer, EC P-256). Any TSP response signed by this leaf is accepted; the chain validation up to Gerege Root is not currently performed by `TimestampVerifier` (it matches by signer cert hash against the configured cert).
