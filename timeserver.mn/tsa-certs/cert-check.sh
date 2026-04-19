#!/bin/bash
# Check leaf cert expiry - warn at 30 days
CERT="/opt/tsa-certs/leaf-cert.pem"
ALERT="/opt/tsa-certs/alert.sh"
EXPIRY=$(openssl x509 -in "$CERT" -noout -enddate | cut -d= -f2)
EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
NOW_EPOCH=$(date +%s)
DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))

if [ "$DAYS_LEFT" -lt 7 ]; then
    $ALERT CRITICAL "TSA leaf cert expires in $DAYS_LEFT days ($EXPIRY)"
elif [ "$DAYS_LEFT" -lt 30 ]; then
    $ALERT WARNING "TSA leaf cert expires in $DAYS_LEFT days ($EXPIRY)"
fi
