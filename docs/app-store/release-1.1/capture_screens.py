"""Capture seeded DEBUG screens from an already booted, installed simulator."""
import subprocess
import sys
import time
from pathlib import Path

device = sys.argv[1]
root = Path(__file__).parent / "raw"
root.mkdir(exist_ok=True)
for mode in ("practice", "hints", "goal", "progress", "grand", "profiles"):
    subprocess.run(["xcrun", "simctl", "launch", "--terminate-running-process", device,
                    "com.higgssoftware.musica", "-demo-screen", mode], check=True,
                   stdout=subprocess.DEVNULL, timeout=30)
    time.sleep(2)
    subprocess.run(["xcrun", "simctl", "io", device, "screenshot", str(root / f"{mode}.png")],
                   check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=30)
    print(f"Captured {mode}", flush=True)
