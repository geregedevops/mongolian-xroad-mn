#!/bin/bash
# Comprehensive health check - can be called by external monitoring
# Returns non-zero exit code if unhealthy

ERRORS=0

# 1. Check timestamp-authority is running
if ! systemctl is-active --quiet timestamp-authority; then
    echo "FAIL: timestamp-authority not running"
    ERRORS=$((ERRORS+1))
fi

# 2. Check nginx is running
if ! systemctl is-active --quiet nginx; then
    echo "FAIL: nginx not running"
    ERRORS=$((ERRORS+1))
fi

# 3. Check TSA responds to ping
if ! curl -sf --connect-timeout 5 http://127.0.0.1:3004/ping > /dev/null; then
    echo "FAIL: TSA ping failed"
    ERRORS=$((ERRORS+1))
fi

# 4. Check NTP sync
NTP_SYNC=$(timedatectl show --property=NTPSynchronized --value 2>/dev/null)
if [ "$NTP_SYNC" != "yes" ]; then
    echo "FAIL: NTP not synchronized"
    ERRORS=$((ERRORS+1))
fi

# 5. Check disk space (warn at 90%)
DISK_USE=$(df / --output=pcent | tail -1 | tr -d ' %')
if [ "$DISK_USE" -gt 90 ]; then
    echo "FAIL: Disk usage at ${DISK_USE}%"
    ERRORS=$((ERRORS+1))
fi

if [ "$ERRORS" -eq 0 ]; then
    echo "OK: All checks passed"
    exit 0
else
    echo "FAIL: $ERRORS check(s) failed"
    exit 1
fi
