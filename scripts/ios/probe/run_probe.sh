#!/usr/bin/env bash
# GPS probe, no AI agent: the testers' moving GPS route on one simulator, the app with a probe that
# logs every position its web view receives, the permission prompts answered like the testers did.
# Phases: first launch (no permission yet), leave 20 s and return, relaunch, then Safari as a control.
# Everything goes to results/gps-probe/ (encrypted by the workflow).
set -uo pipefail
: "${UDID:?}" "${APP_ID:?}" "${GEO:?}"
R=results/gps-probe; mkdir -p "$R"; D=scripts/ios/probe
T0=$(date +%s); at() { while [ $(( $(date +%s) - T0 )) -lt "$1" ]; do sleep 1; done; }
mark() { echo "$(date -u +%H:%M:%S) +$(( $(date +%s) - T0 ))s $*" | tee -a "$R/timeline.txt"; }
shot() { xcrun simctl io "$UDID" screenshot --type=png "$R/$1.png" >/dev/null 2>&1; mark "screenshot $1"; }

APP=$(find app -maxdepth 2 -name '*.app' -type d | head -1)
python3 "$D/patch_app.py" "$APP" > "$R/patch.txt" 2>&1
xcrun simctl spawn "$UDID" log stream --style compact \
  --predicate '(process == "App" OR process == "MobileSafari" OR process == "locationd") AND (eventMessage CONTAINS[c] "locat" OR eventMessage CONTAINS[c] "geoloc")' \
  > "$R/system-location-log.txt" 2>&1 &
LOGP=$!

# The testers' GPS feed (scripts/ios/run_agent.sh); GPS_FEED=route for the old route, to compare
if [ "${GPS_FEED:-set}" = route ]; then
  xcrun simctl location "$UDID" set "$GEO"
  WP=$(awk -v g="$GEO" 'BEGIN{split(g,p,","); for(i=0;i<720;i++){d=(i%2)?0.00003:0; printf "%.6f,%.6f ", p[1]+d, p[2]+d}}')
  xcrun simctl location "$UDID" start --speed=0.5 --interval=1 $WP > "$R/route.txt" 2>&1
else
  export GPS_STOP="$RUNNER_TEMP/stop-gps"; bash scripts/ios/gps_feed.sh "$GEO" & GPS=$!
fi
mark "GPS feed started (${GPS_FEED:-set})"
xcrun simctl install "$UDID" "$APP" || { mark "install failed"; exit 1; }
BID=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Info.plist" 2>/dev/null); [ -n "$BID" ] && APP_ID=$BID

mark "phase 1: first launch, permission not granted yet"
python3 "$D/tap_prompts.py" 170 > "$R/taps-1.txt" 2>&1 &
TP=$!
xcrun simctl launch --console-pty "$UDID" "$APP_ID" > "$R/console-1.txt" 2>&1 &
LP=$!
for t in 15 40 70 110 170; do at $t; shot "1-launch-${t}s"; done
wait $TP 2>/dev/null

mark "phase 2: home screen for 20 s, then back"
axe button home --udid "$UDID" >/dev/null 2>&1
at 195; xcrun simctl launch "$UDID" "$APP_ID" >/dev/null 2>&1; mark "app opened again"
python3 "$D/tap_prompts.py" 60 > "$R/taps-2.txt" 2>&1 &
for t in 205 230 260; do at $t; shot "2-return-$((t - 195))s"; done

mark "phase 3: relaunch (terminate + launch, as gesture.sh relaunch)"
kill $LP 2>/dev/null; xcrun simctl terminate "$UDID" "$APP_ID" >/dev/null 2>&1; sleep 1
python3 "$D/tap_prompts.py" 150 > "$R/taps-3.txt" 2>&1 &
TP=$!
xcrun simctl launch --console-pty "$UDID" "$APP_ID" > "$R/console-2.txt" 2>&1 &
LP=$!
for t in 280 310 350 420; do at $t; shot "3-relaunch-$((t - 265))s"; done
wait $TP 2>/dev/null
kill $LP 2>/dev/null; xcrun simctl terminate "$UDID" "$APP_ID" >/dev/null 2>&1

mark "phase 4: Safari control page (plain watchPosition counter)"
python3 -m http.server 8765 --bind 127.0.0.1 --directory "$D" > /dev/null 2>&1 &
HP=$!
sleep 2
python3 "$D/tap_prompts.py" 150 "Allow" "Allow While Using App" "Continue" "Not Now" > "$R/taps-4.txt" 2>&1 &
TP=$!
xcrun simctl openurl "$UDID" "http://localhost:8765/geotest.html"
for t in 450 480 530 580; do at $t; shot "4-safari-$((t - 430))s"; done
wait $TP 2>/dev/null
kill $HP $LOGP 2>/dev/null; [ -n "${GPS_STOP:-}" ] && touch "$GPS_STOP"
grep -a "GEOPROBE" "$R"/console-*.txt | sed 's/.*GEOPROBE/GP/' > "$R/probe-lines.txt" || true
mark "done"
