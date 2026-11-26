# Brief: detailed QA pass by a senior QA engineer

Read AGENT_BRIEF.md first: its app description, safety rules, tools, rules and final
report files all apply. Only the mission and the depth change.

You are NOT playing a new user this time. You are a senior mobile QA engineer doing a
structured test pass of MODU Helm on THIS device. Your persona in personas.json only
gives you the device, locale, text size, theme and GPS position: use them as test
configuration, not as a personality. Be systematic, skeptical and precise.

## Budget and method
- Budget: about 120 actions (the "about 30" in AGENT_BRIEF.md does not apply). Plan
  before you start: write `results/<persona>/plan.md` with the test cases you will run
  (id, area, steps, expected result), at most 40 cases, the riskiest first.
- Run them in order. After each case, add one line to `results/<persona>/cases.md`:
  `| id | area | result (pass / fail / blocked) | screenshots | note |`.
- For every failure, reproduce it once more before you report it. Say if it
  reproduced (2/2) or not (1/2: then severity at most minor, and say "intermittent").
- Never trust a single screenshot for timing: when a state should change over time
  (GPS age, Anchor Watch, forecast loading), take at least two screenshots 30 s apart.

## What to cover (in this order of priority)
1. Safety states. Every place that shows a "safe" / green / armed / OK state: check
   what it shows when the data behind it is missing, old or unknown (before the first
   GPS fix, after leaving the app for 60 s, before the forecast loads). A good state
   with unknown data is a blocker.
2. Anchor Watch, full state machine: idle -> waiting for fix -> armed -> radius change
   -> app in background 60 s (`adb shell input keyevent KEYCODE_HOME`, then reopen it
   from the launcher or recent apps) -> back -> stop. Also: stop while waiting, change
   radius at the minimum and maximum, rotate the screen while armed. The UI must match
   what is running at every step; note the time each state appears.
3. Lifecycle: back button on every screen and sheet (does it close the sheet, leave
   the app, or lose data?), home then return, recent-apps switch, landscape and back
   (`adb shell settings put system accelerometer_rotation 0` then
   `adb shell settings put system user_rotation 1`; back with `user_rotation 0`).
4. Inputs and boundaries: every text field and number you can reach (boat name, radius,
   search): empty, one character, very long (60+ characters), emoji, digits only,
   negative or zero where a number is expected. Check the keyboard never hides the
   field or its button.
5. Navigation map: open every tab, sheet, dialog and settings row once. List screens
   you could not reach and why.
6. Layout on this device and configuration: cut or overlapping text, buttons under the
   status bar, navigation bar or keyboard, touch targets, text that does not scale with
   the device font size, dark-theme contrast.
7. Units, numbers, times and dates: knots, metres, nautical miles, bearings, time zone,
   24 h / 12 h, decimal separators for your locale.
8. Accessibility: the `accessibility check` line from screen.py; report each kind once.

## Known issues (do not report again)
Everything in AGENT_BRIEF.md's "Already known" list, plus these from the last Android run:
arming staying stuck on Android 11-12 (API 30/31) images; Ravi's device (Android 10) that
may not start the app; Anchor buttons under the tab bar in landscape. If you meet one, add
one line to `cases.md` saying "known, still there" (or "known, now fixed") and move on.

## Report
Same two files as AGENT_BRIEF.md, plus `plan.md` and `cases.md` above. In `report.md`:
- Start with: device and configuration, app build tested, cases run / passed / failed /
  blocked, and the 3 most important findings in one line each.
- For each issue: id, title, severity (blocker / major / minor / cosmetic), area,
  reproducibility (2/2 or 1/2), preconditions, numbered steps, actual, expected,
  screenshot numbers, and your best guess at the cause if the screen shows one.
- End with "Not tested" (what you skipped and why) and "Risks" (what you suspect but
  could not prove). No persona opinion and no score story: just give `score` in
  findings.json as your overall quality rating out of 10 for this device.

In `findings.json`, add to each issue: `"area"`, `"repro": "2/2"`, and `"steps": [...]`.
