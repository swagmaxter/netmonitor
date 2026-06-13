#!/bin/sh
# scan.sh — find devices on your network by trying to open a
# TCP connection to each address. v2: scans the whole range and
# checks many addresses at once so it finishes quickly.

SUBNET="10.0.0"
START=1
END=254
PORTS="80 443 22 8080 53 62078"

# Scratch folder to collect results from the parallel checks.
OUT="/tmp/scan_results"
rm -rf "$OUT"; mkdir -p "$OUT"

echo "Scanning $SUBNET.$START to $SUBNET.$END ..."

# How to check ONE address. Writes a file only if something answers.
check() {
  IP="$1"
  for PORT in $PORTS; do
    if nc -w 1 "$IP" "$PORT" </dev/null >/dev/null 2>&1; then
      echo "$IP  (answered on port $PORT)" > "$OUT/$IP"
      return
    fi
  done
}

# Walk the range, launching checks in the background (the & does that),
# but only ~20 at a time so we don't overwhelm the phone.
HOST=$START
RUNNING=0
while [ "$HOST" -le "$END" ]; do
  check "$SUBNET.$HOST" &
  RUNNING=$((RUNNING + 1))
  if [ "$RUNNING" -ge 20 ]; then
    wait        # pause until this batch finishes
    RUNNING=0
  fi
  HOST=$((HOST + 1))
done
wait            # wait for the final batch

echo "--- Devices that answered ---"
if [ -n "$(ls -A "$OUT" 2>/dev/null)" ]; then
  cat "$OUT"/*
else
  echo "(none)"
fi
echo "Done."
