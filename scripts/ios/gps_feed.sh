#!/usr/bin/env bash
# Live GPS on an iOS Simulator: a fresh position every second, the boat swinging about 3 m at anchor,
# like the Android geo-fix loop. Runs until the file $GPS_STOP exists (or it is killed).
# A 'simctl location start' route does not do this on iOS 18: web views got one fix, then nothing.
# Usage: UDID=... bash scripts/ios/gps_feed.sh "lat,lon" &
set -u
: "${UDID:?}"
GEO=$1; LAT=${GEO%,*}; LON=${GEO#*,}; STOP=${GPS_STOP:-/tmp/stop-gps-$UDID}; rm -f "$STOP"
n=0
while [ ! -f "$STOP" ]; do
  P=$(awk -v a="$LAT" -v o="$LON" -v n=$n 'BEGIN{d=0.00003*sin(n/10); printf "%.6f,%.6f", a+d, o+d}')
  xcrun simctl location "$UDID" set "$P" >/dev/null 2>&1
  n=$((n + 1)); sleep 1
done
