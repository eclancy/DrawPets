# Android: building, installing and debugging

The plan for getting DrawPets onto real phones and tablets and finding what breaks there.
**In progress** (2026-10-11): everything on the PC is set up and both presets export signed APKs
(`build/drawpets-debug.apk`, `build/drawpets-demo.apk`, ~49 MB) with the right manifest and every
`pivots.json` and voice file inside. Next: a device. Nothing has run on a phone yet - everything
so far has been tested only on Windows with a mouse standing in for a finger.

## What is already in place

- Landscape on any phone or tablet (`window/handheld/orientation` = sensor landscape), the
  1280x720 design stretched with `canvas_items` / `expand`.
- GL Compatibility renderer (runs on cheap tablets), GDScript only (no .NET runtime to ship).
- The back gesture goes home instead of quitting (`config/quit_on_go_back=false` +
  `NOTIFICATION_WM_GO_BACK_REQUEST`).
- **Saves when the app is put in the background** (`NOTIFICATION_APPLICATION_PAUSED`): Android may
  kill a backgrounded app without warning, so a home saves its pets right then.
- Microphone input enabled (`audio/driver/enable_input`), and `RECORD_AUDIO` asked for only
  when a kid first records.
- Screenshots go to `user://shots` outside the editor (res:// is read-only on a phone), and
  logging to a file is on for mobile too (`debug/file_logging/enable_file_logging`).

## Step 1 - tools on this PC

| what | where | status |
|---|---|---|
| **JDK 17** (Eclipse Temurin 17.0.20.1) | `C:\Users\ericc\AppData\Local\Programs\Eclipse Adoptium\jdk-17.0.20.1+1` | installed |
| **Android SDK**: cmdline-tools, platform-tools (adb), build-tools 35.0.1, platform 35 | `C:\Users\ericc\Android\Sdk` | installed |
| **Android export template** `android_debug.apk` (CRC-checked) | `%APPDATA%\Godot\export_templates\4.5.1.stable.mono\` | installed |
| the debug keystore | `%APPDATA%\Godot\keystores\debug.keystore` | made |
| the editor's paths | Editor Settings > Export > Android > Java SDK Path, Android SDK Path | **Eric sets these in the editor** |

What was learned setting it up:
- **The SDK is not under AppData on purpose.** Windows redirects new folders that the Claude
  desktop app (a packaged app) makes under `AppData` into the app's private storage
  (`AppData\Local\Packages\Claude_...\LocalCache`), where Godot and a normal terminal cannot see
  them. `C:\Users\ericc\Android\Sdk` is outside AppData, so everything sees the same files.
- **`sdkmanager` is deprecated** in the 2026 command-line tools: `android sdk install <pkg>` (in
  `cmdline-tools\latest\bin\android.exe`) replaces it, with package names like
  `build-tools/35.0.1`, and there is no separate licence step. Always pass `--no-metrics`.
- **The installed .NET export templates are Windows-only.** Android needs `android_debug.apk` from
  the Godot 4.5.1 .NET templates (`Godot_v4.5.1-stable_mono_export_templates.tpz`, 1.28 GB). It is
  the first file in that zip, so it can be fetched alone (~118 MB) with one byte-range request.
  `android_release.apk` (~97 MB) waits for a release build; `android_source.zip` is only for
  Gradle builds, which DrawPets does not use.
- **The .NET editor is fine** for a project without C#: the export only adds .NET when there is a
  C# project, and the game runs without it. The standard editor would also work; there is no
  reason to install a second one.
- The editor settings file is shared by every open Godot window, so set the paths in the editor
  (or with every Godot window closed) - an open editor rewrites the file and loses a hand edit.
- **Exporting from the command line without touching those settings:** Godot finds its settings
  folder through `APPDATA`, so a private copy with the right paths works for one run. Claude keeps
  one in its scratchpad (`godot_cfg/Godot/`: `editor_settings-4.5.tres` with the two paths and the
  real keystore path, plus `export_templates/4.5.1.stable.mono/`):
  `APPDATA=<that folder> "$GODOT_BIN" --headless --path . --export-debug "Android" build/drawpets-debug.apk`.
  Once the paths are set in the editor, the plain command works.
- **The silent export failure:** Godot refuses to export for Android unless
  `rendering/textures/vram_compression/import_etc2_astc` is on, and from the command line it says
  only ".NET on Android is experimental" (the editor shows a "Fix Import" button instead). It is
  on now. DrawPets' textures import lossless, so it changes nothing you can see.

## Step 2 - the export presets (done, `export_presets.cfg`)

**Android** - the game, debug-signed:
- **Package** `dev.ecec.drawpets`, to match ecec.dev. Version 0.0.1, code 1.
- **Architectures**: arm64-v8a (every phone from the last ~8 years); armeabi-v7a only if an old
  tablet needs it.
- **Permissions**: `RECORD_AUDIO` only. No internet until sharing exists.
- **Include filter: `*.json, *.f32`** - critical. Godot only packs files it knows how to import;
  without this, `art/*/pivots.json` is missing (every drawing lands at the wrong spot) and
  `sfx/voices/*.f32` is missing (every pet is silent). Godot skips folders starting with a dot,
  and the excludes keep `tools/`, `docs/`, `build/` and `.claude/` out anyway.
- **Backup off** (`user_data_backup/allow=false`): Android's automatic backup would copy the
  saves - drawings and voice recordings - to the family's Google account. Nothing a child recorded
  leaves the device.
- **Icon**: `python tools/app_icon.py` crops Zorp, the demo kid's creature, from the Fix screen
  of a demo run (`.shots/demo_NN_fix_hub.png`) into `icon/` - the project icon, the 192px launcher
  icon, and the two 432px adaptive layers (the crop on paper). A real frame, never drawn
  separately (the DrawFight rule).
- Immersive (no status bar), and the boot splash is plain paper rather than Godot's dark grey.

**Android Demo** - the same, with Extra Args `--demo --quit`: the scripted kid plays the whole game
on the device, screenshotting every step. **It is its own app, `dev.ecec.drawpets.demo`**, because
the demo plays on top of whatever save it finds - it redraws the first pet in the first home and
lets the last one go. As a separate package it has its own save and installs beside the real game,
so it can never touch a kid's pets.

## Step 3 - the device

- Settings > About > tap Build number seven times; then Developer options > **USB debugging** on.
- Plug in, accept "Allow USB debugging" on the phone, check `adb devices` lists it.
- Wireless works too (Android 11+): Developer options > Wireless debugging > pair with code, then
  `adb pair <ip:port>` and `adb connect <ip:port>`.
- Test on **two devices if possible**: a cheap or old tablet (the slowest case - flood fill and
  voice rendering are GDScript) and a phone (the smallest screen, and a notch).

## Step 4 - the loop

From the editor: with the device plugged in, the Android button (top right) installs and starts
it in one click. Turn on **Debug > Deploy with Remote Debug** first: then `print`s, errors and
warnings appear in the editor's Debugger, the remote scene tree shows what is on screen, and the
Monitors tab shows FPS, frame time, memory and draw calls live from the phone.

From the command line (what Claude can run from here once the tools exist):
```
"$GODOT_BIN" --headless --path . --export-debug "Android" build/drawpets-debug.apk
adb install -r build/drawpets-debug.apk
adb shell am start -n dev.ecec.drawpets/com.godot.game.GodotApp
adb logcat -s godot:V                     # the game's prints and errors, live
adb exec-out run-as dev.ecec.drawpets cat files/logs/godot.log > godot.log

# the demo: a fresh save every time, then pull its screenshots
"$GODOT_BIN" --headless --path . --export-debug "Android Demo" build/drawpets-demo.apk
adb install -r build/drawpets-demo.apk
adb shell pm clear dev.ecec.drawpets.demo
adb shell am start -n dev.ecec.drawpets.demo/com.godot.game.GodotApp
adb exec-out run-as dev.ecec.drawpets.demo cat files/shots/demo_21_place.png > demo_21_place.png
```
`adb` is `C:\Users\ericc\Android\Sdk\platform-tools\adb.exe` (not on PATH).
`run-as` works on debug builds, so the log file and every screenshot (and the saves in
`files/pets/`) can be pulled off the device without rooting it. A crash outside the game's code
shows in plain `adb logcat`.

## Step 5 - what to check, in order

**First, the things most likely to be broken:**
1. The include filter: do drawings sit right (pivots) and do pets make sounds (voices)?
2. The demo preset runs to the end on the device and its screenshots match the PC's.
3. Saving: background the app mid-play, swipe it away, reopen - are the pets, stars and homes
   all there?

**Then, speed** (the PC is many times faster than a cheap tablet):
4. **Paint bucket** - a fill on a 512 px sheet runs a GDScript flood fill. Time it (add a `print`
   of the milliseconds). Over ~300 ms feels broken; the fixes are a "filling..." moment, a smaller
   working sheet, or moving the fill to a compute shader or a small GDExtension.
5. **Voice rendering** - 20-150 ms per sound on the PC, so up to ~1 s on a slow tablet when a
   slider changes. Versions are cached, so it matters in the sound maker most. Fixes: a coarser
   alignment search, rendering on a `WorkerThreadPool` thread, or a GDExtension.
6. **Frame rate** in a home with six pets and a lot of furniture, and in each competition (four
   racers, each a rig of parts). Watch the Monitors tab.
7. **Loading a home** - every pet's drawings become textures; look for a hitch.

**Then, touch** (a mouse does none of this):
8. Drawing feel: are strokes smooth at finger speed, does a resting palm draw, does a second
   finger make a mess? (The game reads the first finger only today.)
9. **Scrolling lists of buttons** (the shop, item pickers, the drawing grids): does a drag to
   scroll press a button by mistake?
10. Dragging food, toys and furniture out of the drawers; flinging a toy (the flick speed comes
    from finger samples); tug of war; the hold-to-let-go button; the sliders.
11. Back gesture on every screen; what happens mid-drawing (it currently goes home - a kid could
    lose a half-drawn pet: decide whether to ask first).

**Then, the screen:**
12. Small phone: are labels and buttons big enough? Is anything under a camera notch or rounded
    corner? (Godot reports the safe area: `DisplayServer.get_display_safe_area()`.)
13. Tablet: does anything look stretched or tiny at 4:3?

**Then, sound and the mic:**
14. Tap latency, the crayon scratch following the finger, music and ambience crossfades, the
    hardware volume buttons.
15. The mic flow: first Record asks yes/no; Android then asks permission; deny it (the game must
    say so and carry on); allow it, record 3 seconds, check it plays back and saves.

Every problem found goes in as a test the demo kid can repeat, where it can be.

## Found on the Pixel 9 (2026-10-11, Android 17)

Installed over wireless debugging (`adb pair` with the code from Developer options > Wireless
debugging > Pair device; `adb mdns services` finds the phone's address and ports by itself).
- Runs: OpenGL ES 3.2 on a Mali-G715, every sound loads, no script errors.
- **Fixed:** `!is_inside_tree()` from `can_process` on taps - a lifted finger is a mouse release
  then a touch release, and steps removed from the tree in between made Godot complain. `UI.retire`.
- **Fixed:** the pet card was taller than the room above the drawer bar (Fix, Voice, Move and Let
  go were under it) - now two columns, and drawn above the bar.
- The screen is 2424 x 1080 (2.24:1), so the 1280 x 720 design widens to about 1616 x 720.
- **Hardened:** springy parts (ears, horns, antennae) took one step per frame, so a long frame
  (a voice being worked out, a screen loading) could overshoot them - now small fixed steps,
  capped. Prompted by "the pig's ears are all over the place"; not yet confirmed as the cause.

## Later

- A release keystore (kept out of git, like DrawFight's) and a release preset.
- Sideloading for the family vs the Play Store: the Play Store means a developer account, a
  privacy policy and the Families policy (the players are under 13 - see `sharing.md`).
- iOS: needs a Mac with Xcode and an Apple developer account.
