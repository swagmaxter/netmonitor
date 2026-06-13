#!/usr/bin/env python3
# scan.py — find devices on the network by trying TCP connections,
# all from one process with many connections in flight at once.

import socket
import concurrent.futures

SUBNET = "10.0.0"
PORTS = [80, 443, 22, 8080, 53, 62078]
TIMEOUT = 0.5  # seconds to wait for each address

def check(host):
    ip = f"{SUBNET}.{host}"
    for port in PORTS:
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.settimeout(TIMEOUT)
                s.connect((ip, port))
            return (ip, port)
        except OSError:
            continue
    return None

print(f"Scanning {SUBNET}.1 to {SUBNET}.254 ...")

found = []
with concurrent.futures.ThreadPoolExecutor(max_workers=50) as pool:
    for result in pool.map(check, range(1, 255)):
        if result:
            found.append(result)

print("--- Devices that answered ---")
if found:
    for ip, port in found:
        print(f"  {ip}  (answered on port {port})")
else:
    print("  (none)")
print("Done.")
