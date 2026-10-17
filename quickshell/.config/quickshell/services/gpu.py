#!/usr/bin/env python3
"""Read AMD GPU sysfs counters without running a monitor in the background."""

import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess


def read(path):
    try:
        return path.read_text().strip()
    except OSError:
        return ""


def number(path):
    try:
        value = int(read(path))
        return value if value >= 0 else None
    except ValueError:
        return None


def scan(root=Path("/sys/class/drm")):
    candidates = []
    for card in root.glob("card*"):
        if not re.fullmatch(r"card\d+", card.name):
            continue
        device = card / "device"
        if read(device / "vendor").lower() != "0x1002":
            continue
        busy = number(device / "gpu_busy_percent")
        if busy is not None and busy > 100:
            busy = None
        total = number(device / "mem_info_vram_total") or 0
        used = number(device / "mem_info_vram_used") if total else None
        if busy is None and used is None:
            continue
        connected = any(read(output / "status") == "connected" for output in root.glob(card.name + "-*"))
        boot = read(device / "boot_vga") == "1"
        pci = ""
        for line in read(device / "uevent").splitlines():
            if line.startswith("PCI_SLOT_NAME="):
                value = line.partition("=")[2]
                if re.fullmatch(r"[0-9a-fA-F]{4}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}\.[0-7]", value):
                    pci = value
        candidates.append(((connected, boot, total, card.name), {
            "available": True, "card": card.name, "pci": pci, "busy": busy,
            "vramUsed": min(used, total) if used is not None else None,
            "vramTotal": total,
        }))
    if not candidates:
        return {"available": False, "card": "", "pci": "", "busy": None, "vramUsed": None, "vramTotal": 0}
    return max(candidates, key=lambda item: item[0])[1]


def monitor_command(data, executable):
    command = ["uwsm", "app", "--", "ghostty", "-e", executable, "--dark", "--single"]
    if data["pci"]:
        command += ["--pci", data["pci"]]
    return command


def open_monitor():
    executable = shutil.which("amdgpu_top")
    local = Path.home() / ".local/bin/amdgpu_top"
    if not executable and local.is_file() and os.access(local, os.X_OK):
        executable = str(local)
    if not executable:
        subprocess.run(["notify-send", "GPU monitor", "Install amdgpu_top to open the AMD GPU monitor."], check=False)
        return 1
    os.execvp("uwsm", monitor_command(scan(), executable))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", nargs="?", choices=("scan", "open"), default="scan")
    parser.add_argument("--root", type=Path, default=Path("/sys/class/drm"))
    args = parser.parse_args()
    if args.action == "open":
        return open_monitor()
    print(json.dumps(scan(args.root)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
