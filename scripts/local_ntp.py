#!/usr/bin/env python3
"""
local_ntp.py — Standalone lightweight NTP server for offline STB time synchronization.

Provides current PC time to the STB over UDP port 123 so that the STB's clock
is set to the present year (2026) without exposing the STB to the internet or Jio servers.
"""
import socket
import struct
import time
import sys

NTP_DELTA = 2208988800  # seconds between 1900-01-01 and 1970-01-01

def run_ntp_server(host="0.0.0.0", port=123):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.bind((host, port))
    except Exception as e:
        print(f"\n[!] Could not bind to {host}:{port}: {e}")
        print("\n  Windows Time Service (w32time) is currently holding UDP port 123.")
        print("  To free it, open PowerShell as Administrator and run:")
        print("      Stop-Service w32time\n")
        print("  Then run this script again:\n      python jhs/local_ntp.py\n")
        sys.exit(1)

    print(f"\n[*] Local NTP Server listening on {host}:{port}")
    print("[*] Serving current PC time to offline STB...")
    print("[*] Keep this running until the STB connects.\n")
    while True:
        try:
            data, addr = s.recvfrom(1024)
            if len(data) < 48:
                continue

            client_tx = data[40:48]
            now = time.time() + NTP_DELTA
            sec = int(now)
            frac = int((now - sec) * (2**32))

            header = struct.pack(
                '!BBBb11I',
                0x24, 1, 4, -20,
                0, 0,
                int.from_bytes(b'LOCL', 'big'),
                sec, frac,
                int.from_bytes(client_tx[:4], 'big'), int.from_bytes(client_tx[4:], 'big'),
                sec, frac,
                sec, frac
            )

            s.sendto(header, addr)
            print(f"[✓] NTP sync reply sent to {addr[0]}:{addr[1]} -> time synced to {time.ctime()}", flush=True)
        except KeyboardInterrupt:
            print("\nNTP server stopped.")
            break
        except Exception as e:
            print(f"[!] Error: {e}", flush=True)

if __name__ == "__main__":
    run_ntp_server()

