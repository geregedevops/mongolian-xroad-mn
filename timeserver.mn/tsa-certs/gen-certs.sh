#!/bin/bash
set -e

# 1. Root CA
openssl ecparam -genkey -name prime256v1 -noout -out root-key.pem
openssl req -new -x509 -key root-key.pem -sha256 -days 3650 \
  -subj "/C=MN/O=TimeServer.mn/CN=TimeServer.mn Root CA" \
  -extensions v3_ca -out root-cert.pem \
  -config <(cat <<EOF
[req]
distinguished_name = req_dn
x509_extensions = v3_ca
[req_dn]
[v3_ca]
basicConstraints = critical, CA:TRUE, pathlen:1
keyUsage = critical, keyCertSign, cRLSign
subjectKeyIdentifier = hash
EOF
)

# 2. Intermediate CA
openssl ecparam -genkey -name prime256v1 -noout -out intermediate-key.pem
openssl req -new -key intermediate-key.pem -sha256 \
  -subj "/C=MN/O=TimeServer.mn/CN=TimeServer.mn Intermediate CA" \
  -out intermediate-csr.pem

openssl x509 -req -in intermediate-csr.pem -CA root-cert.pem -CAkey root-key.pem \
  -CAcreateserial -sha256 -days 1825 \
  -extfile <(cat <<EOF
basicConstraints = critical, CA:TRUE, pathlen:0
keyUsage = critical, keyCertSign, cRLSign
extendedKeyUsage = critical, timeStamping
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always
EOF
) -out intermediate-cert.pem

# 3. Leaf (TSA signer)
openssl ecparam -genkey -name prime256v1 -noout -out leaf-key.pem
openssl req -new -key leaf-key.pem -sha256 \
  -subj "/C=MN/O=TimeServer.mn/CN=TimeServer.mn TSA Signer" \
  -out leaf-csr.pem

openssl x509 -req -in leaf-csr.pem -CA intermediate-cert.pem -CAkey intermediate-key.pem \
  -CAcreateserial -sha256 -days 365 \
  -extfile <(cat <<EOF
basicConstraints = critical, CA:FALSE
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, timeStamping
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always
EOF
) -out leaf-cert.pem

# 4. Create chain file (leaf, intermediate, root)
cat leaf-cert.pem intermediate-cert.pem root-cert.pem > certchain.pem

echo "Certificate chain created successfully!"
openssl verify -CAfile root-cert.pem -untrusted intermediate-cert.pem leaf-cert.pem
