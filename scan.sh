#!/bin/sh
# scan.sh — find devices that are "home" on your network
# by trying to open a TCP connection to each address.

# 1) The first three numbers of your network.
#    From iOS Settings > Wi-Fi > tap the (i). If your phone's
#    IP is .168.1.37, then SUBNET is "192.168.1".
SUBNET="10.0.0"

# 2) Which addresses to check. Start small to confirm it works;
#    we'll widen this to 1–254 once it's fast.
START=1
END=20

# 3) Doors to knock on. 80/443 = web, 22 = remote login,
#    62078 = the port iPhones/iPads quietly listen on.
PORTS="80 443 22 62078"

echo "Scanning $SUBNET.$START to $SUBNET.$END ..."

HOST=$START
while [ "$HOST" -le "$END" ]; do
  IP="$SUBNET.$HOST"

  FOUND=""
  for PORT in $PORTS; do
    if nc -w 1 "$IP" "$PORT" </dev/null >/dev/null 2>&1; then
      FOUND="$PORT"
      break
    fi
  done

  if [ -n "$FOUND" ]; then
    echo "  UP   $IP   (answered on port $FOUND)"
  fi

  HOST=$((HOST + 1))
done

echo "Done."
