#!/bin/bash
set -e

CERT_DIR=/opt/tsa-certs
CERT="$CERT_DIR/leaf-cert.pem"
DAYS_THRESHOLD=30

# Check days remaining
EXPIRY=$(openssl x509 -in "$CERT" -noout -enddate | cut -d= -f2)
EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
NOW_EPOCH=$(date +%s)
DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))

if [ "$DAYS_LEFT" -gt "$DAYS_THRESHOLD" ]; then
    echo "$(date -u +%FT%T) Leaf cert OK: $DAYS_LEFT days remaining" >> /var/log/tsa-watchdog.log
    exit 0
fi

echo "$(date -u +%FT%T) Leaf cert renewing: $DAYS_LEFT days remaining" >> /var/log/tsa-watchdog.log

cd "$CERT_DIR"

# Backup current certs
cp leaf-key.pem leaf-key.pem.bak
cp leaf-cert.pem leaf-cert.pem.bak
cp leaf-csr.pem leaf-csr.pem.bak
cp certchain.pem certchain.pem.bak

# Generate new leaf key + cert
openssl ecparam -genkey -name prime256v1 -noout -out leaf-key.pem
openssl req -new -key leaf-key.pem -sha256   -subj "/C=MN/O=TimeServer.mn/CN=TimeServer.mn TSA Signer"   -out leaf-csr.pem

openssl x509 -req -in leaf-csr.pem   -CA intermediate-cert.pem -CAkey intermediate-key.pem   -CAcreateserial -sha256 -days 365   -extfile <(cat <<EOF
basicConstraints = critical, CA:FALSE
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, timeStamping
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always
EOF
) -out leaf-cert.pem

# Rebuild chain
cat leaf-cert.pem intermediate-cert.pem root-cert.pem > certchain.pem

# Verify
if openssl verify -CAfile root-cert.pem -untrusted intermediate-cert.pem leaf-cert.pem; then
    echo "$(date -u +%FT%T) Leaf cert renewed successfully, restarting service" >> /var/log/tsa-watchdog.log
    systemctl restart timestamp-authority
else
    echo "$(date -u +%FT%T) CRITICAL: Leaf cert verification failed, rolling back" >> /var/log/tsa-watchdog.log
    cp leaf-key.pem.bak leaf-key.pem
    cp leaf-cert.pem.bak leaf-cert.pem
    cp leaf-csr.pem.bak leaf-csr.pem
    cp certchain.pem.bak certchain.pem
    systemctl restart timestamp-authority
    exit 1
fi
