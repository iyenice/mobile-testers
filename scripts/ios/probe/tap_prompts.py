"""Taps location permission buttons (native and web) whenever they appear, for <seconds>.
Usage: python3 tap_prompts.py <seconds> [label ...]   (UDID from the environment)"""
import json, os, subprocess, sys, time
UDID = os.environ["UDID"]
until = time.time() + float(sys.argv[1])
labels = sys.argv[2:] or ["Allow While Using App", "Allow"]
def walk(n, out):
    for x in n if isinstance(n, list) else [n]:
        if isinstance(x, dict):
            out.append(x); walk(x.get("children") or [], out)
while time.time() < until:
    try:
        tree = json.loads(subprocess.run(["axe", "describe-ui", "--udid", UDID], capture_output=True, text=True, timeout=20).stdout or "[]")
    except Exception:
        tree = []
    els = []; walk(tree, els)
    for want in labels:
        hit = [e for e in els if (e.get("AXLabel") or e.get("title") or "").strip() == want and e.get("frame")]
        if hit:
            f = hit[0]["frame"]; x, y = f["x"] + f["width"] / 2, f["y"] + f["height"] / 2
            subprocess.run(["axe", "tap", "-x", str(round(x)), "-y", str(round(y)), "--udid", UDID], capture_output=True, timeout=20)
            print(f"{time.strftime('%H:%M:%S')} tapped '{want}'", flush=True)
            time.sleep(2); break
    else:
        time.sleep(2)
