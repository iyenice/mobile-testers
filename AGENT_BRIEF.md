# Mission: test the app as a real new user

You are a QA tester playing ONE persona (find yours in personas.json with the
PERSONA id you were given). You drive a real phone (Android emulator or iOS
Simulator, see PLATFORM) where the app is already installed and open.
Goal: find bugs, crashes and confusing moments, and report them precisely and
verifiably. Play the persona honestly (patience, skills, goal), but stay a tester.

## The app: MODU Helm
A sailing companion for skippers on the Turkish coast and the Mediterranean: a chart with
places (bays, marinas, restaurants), wind / gust / wave forecasts with a safety band for
anchoring, an Anchor Watch with a drag alarm, MOB (man overboard), SOS / Mayday / Pan-Pan
helpers, Buddies and a Rescue Network. There is no account to create. The phone's GPS is
set to your persona's `geo` (a bay or marina). Your boat is at anchor there. GPS is live,
like on open water: a fresh fix every second, swinging a few metres. So "no GPS fix",
"waiting for GPS" or an old "last fix" after the first minute IS a bug: report it.
Do not change the GPS position yourself.

Safety rules for this test (strict):
- Never complete an SOS, Mayday, Pan-Pan, Rescue Network or Buddies send, and never share a
  guest link. You may OPEN those screens to check layout and wording, then go back or cancel.
  The app's server is blocked during the test, so a send failing is expected, not a bug.
- MOB: you may mark a MOB position once to see the screen, then clear it.
- Anchor Watch is fine to start, change and stop. An alarm that sounds when GPS is lost is
  correct behaviour, not a bug.

What matters most, in this order:
1. Anything that shows a good or "safe" state when data is missing, old or unknown
   (forecast not loaded, no GPS fix): this is a blocker.
2. Anchor Watch: start, see the radius, leave the app and come back, stop. The state shown
   must always match what is running.
3. Forecast and safety band for the current bay: a number never without its word and reason.
4. Layout on this device: cut text, overlapping cards, buttons under the home bar or keyboard.
5. Translations and right-to-left, units (knots, metres, nautical miles), times and dates.
Out of scope: online map tiles or place photos that do not load (the network is limited).

Already known (do NOT report these again; one line "still there" in the summary is enough):
the app is English only (no translation, no right-to-left, system dark theme ignored); the second
"localhost would like to use your location" prompt; "Find My Marina by GPS" failing on the first tap;
"Daylight until" 3 h early before the forecast loads; the red "Anchoring N/10 · Shelter Tonight" pill;
the "Choose your home marina" error that stays; usage statistics pre-ticked; the tablet narrow column.
Spend your budget on THIS device instead: every tab and sheet (Home, Weather, Trip, Cruise, Places,
Buddies, Anchor, Settings, More, MOB / SOS screens opened then closed), leave the app and come back,
and check every screen for cut text, overlaps, buttons under the notch, home bar or keyboard, and text
that does not grow with the device's text size. Android only: look at 2-3 screens in landscape
(`adb shell settings put system accelerometer_rotation 0` then `adb shell settings put system
user_rotation 1`; back with `user_rotation 0`). For this run the budget is about 45 actions.
Anchor Watch: if Alarm now arms (it may say it is waiting for a fix first), check its state over
2 minutes, after leaving the app and coming back, and that Stop works.

## Tools (only these)
Android
- See the screen: `python3 scripts/android/screen.py results/<persona> <NN>` (NN = 01, 02...).
  Read the PNG it writes, then the element list (centres in real pixels).
- Tap: `adb shell input tap X Y` - Swipe/scroll: `adb shell input swipe X1 Y1 X2 Y2 400`
- Back: `adb shell input keyevent KEYCODE_BACK` - Type: `python3 scripts/android/type.py "text"`
iOS
- See the screen: `python3 scripts/ios/screen.py results/<persona> <NN>` (positions in points).
- `bash scripts/ios/gesture.sh tap X Y | scroll down | back | dismiss-sheet | enter | relaunch`
- Type: `python3 scripts/ios/type.py "text"` (tap the field first). It pastes: if iOS asks to
  paste from "CoreSimulatorBridge", tap Allow Paste. That alert comes from the tool, not the app.

## Rules
- Take a screenshot after EVERY action and look at it before the next one. Number them in order.
- Never clear app data or reinstall. Never use a real e-mail: use the test address pattern
  given in your persona (`email`), or `success+<persona>@simulator.amazonses.com`.
- A blocked step is a finding, not the end of the test. Write it down, then try what a
  real user would: change ONE thing at a time (another e-mail such as `<persona>@example.com`,
  all lower case, a longer password, scroll, go back, another button) until you get through.
- Before you report that a setting does nothing, leave the screen it changes (back to the
  main screen), open that screen again and look. Many apps read settings only when a screen opens.
- Budget: about 30 actions, then write the report. Use it: stop earlier only if the app
  crashes twice, or after 4 different attempts on the same blocked step.
- Write everything under `results/<persona>/`. Nothing else.

## What to check (adapt to your app)
1. First launch and onboarding until the main screen.
2. The persona's goal (personas.json, `goal`).
3. Layout on THIS device: cut text, buttons hidden by the keyboard, notch or home bar,
   large text sizes, dark mode contrast.
4. Error and empty states: no network answer, empty lists, wrong input.
5. Accessibility: when `screen.py` ends with an `accessibility check` line (controls with no
   name, touch targets under 48 dp / 44 pt), look at those controls on the screenshot. Report
   each kind once, with the screens where you saw it: minor, unless it stops a task.

## Final report
Write both files with the Write tool (writing through the shell is blocked).
1. `results/<persona>/report.md`
   - 5-line summary with the device.
   - Issues, most severe first. For each: screenshot number(s), steps to reproduce,
     actual result, expected result, severity (blocker / major / minor / cosmetic).
   - Device-specific layout problems (same format, shorter).
   - The persona's opinion in their own words: would they keep the app? score /10.
2. `results/<persona>/findings.json`:
   `{"score": 7, "issues": [{"title": "...", "severity": "major", "screen": "Sign-up", "screens": ["05", "06"]}]}`
