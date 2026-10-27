#!/usr/bin/env python3
"""Read the active network without requiring NetworkManager."""

import json
import os
from pathlib import Path
import re
import subprocess


def run(command):
    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=2,
                                env={**os.environ, "LC_ALL": "C", "TERM": "dumb"}, check=False)
        return result.stdout if result.returncode == 0 else ""
    except (OSError, subprocess.TimeoutExpired):
        return ""


def query(command):
    try:
        data = json.loads(run(command))
        return data if isinstance(data, list) else []
    except ValueError:
        return []


def connection_name(device, wireless):
    if wireless:
        # iwctl emits ANSI escapes even when stdout is not a terminal.
        output = re.sub(r"\x1b\[[0-?]*[ -/]*[@-~]", "", run(["iwctl", "station", device, "show"]))
        for line in output.splitlines():
            match = re.match(r"\s*Connected network\s+(.+?)\s*$", line)
            if match:
                return match[1]
    name = run(["nmcli", "--escape", "no", "-g", "GENERAL.CONNECTION", "device", "show", device]).strip()
    return name if name and name != "--" else device


def scan(root=Path("/sys/class/net")):
    interfaces = query(["ip", "-j", "address", "show"])
    active = {}
    for interface in interfaces:
        if interface.get("ifname") == "lo" or "UP" not in interface.get("flags", []):
            continue
        if interface.get("operstate") == "DOWN":
            continue
        addresses = [a for a in interface.get("addr_info", []) if a.get("scope") == "global"]
        if addresses:
            active[interface["ifname"]] = addresses

    routes = query(["ip", "-j", "route", "show", "default"])
    routes += query(["ip", "-j", "-6", "route", "show", "default"])
    routes = sorted((r for r in routes if r.get("dev") in active), key=lambda r: r.get("metric", 0))
    device = routes[0]["dev"] if routes else next(iter(active), "")
    if not device:
        return {"name": "", "ip": "", "device": "", "type": ""}
    addresses = active[device]
    address = next((a for a in addresses if a.get("family") == "inet"), addresses[0])
    wireless = (root / device / "wireless").exists()
    return {"name": connection_name(device, wireless), "ip": address.get("local", ""),
            "device": device, "type": "wifi" if wireless else "ethernet"}


if __name__ == "__main__":
    print(json.dumps(scan()))
