"""Adds the GPS probe to a built Capacitor .app: logs every position the web view receives
(console, forwarded by Capacitor), and an eval hook inside the app bundle's closure.
Usage: python3 patch_app.py <App.app>"""
import pathlib, sys
app = pathlib.Path(sys.argv[1]); idx = app / "public" / "index.html"
h = idx.read_text()
probe = (pathlib.Path(__file__).parent / "geoprobe.js").read_text()
hook_at = '(function(){"use strict";'
if hook_at in h:
    h = h.replace(hook_at, hook_at + "window.__ev=function(s){return eval(s)};", 1)
else:
    print("eval hook not added: bundle start not found (app state will not be logged)")
i = h.find("<head>")
if i < 0:
    sys.exit("no <head> in index.html")
h = h[:i + 6] + "<script>" + probe + "</script>" + h[i + 6:]
idx.write_text(h)
print("probe added to", idx)
