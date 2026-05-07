#!/bin/bash
# Usage: sign-xroad-csr.sh <csr-file> <sign|auth>
set -e
CSR="$1"; PROFILE="$2"
[ -f "$CSR" ] || { echo "CSR file not found: $CSR"; exit 1; }
[ "$PROFILE" = "sign" ] || [ "$PROFILE" = "auth" ] || { echo "profile must be 'sign' or 'auth'"; exit 1; }

CA_CERT=/opt/gerege-mn-eid/eid-gerege-backend/config/pki/issuing-ca.pem
CA_KEY=/opt/gerege-mn-eid/eid-gerege-backend/config/pki/issuing-ca.key
EXT=/opt/xroad-ca/xroad-extensions.cnf

OUT="${CSR%.csr}.${PROFILE}.cer"
# Random 16-byte serial
SERIAL=$(openssl rand -hex 16 | sed 's/^/0x/')

openssl x509 -req \
    -in "$CSR" \
    -CA "$CA_CERT" -CAkey "$CA_KEY" -set_serial "$SERIAL" \
    -days 825 \
    -sha256 \
    -extfile "$EXT" -extensions "xroad_${PROFILE}" \
    -out "$OUT"

echo
echo "=== Signed: $OUT ==="
openssl x509 -in "$OUT" -noout -subject -issuer -startdate -enddate -ext keyUsage,extendedKeyUsage,authorityInfoAccess,crlDistributionPoints
