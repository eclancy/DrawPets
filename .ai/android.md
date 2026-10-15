# Android: building, installing and debugging

The plan for getting DrawPets onto real phones and tablets and finding what breaks there.
**In progress** (2026-10-11): everything on the PC is set up and both presets export signed APKs
(`build/drawpets-debug.apk`, `build/drawpets-demo.apk`; ~103 MB since 2026-10-15, when exports
moved to Gradle for the Nearby plugin) with the right manifest and every `pivots.json` and voice
file inside. Next: a device. Nothing has run on a phone yet - everything
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
| the editor's paths | Editor Settings > Export > Android > Java SDK Path, Android SDK Path | set (2026-10-11) |

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
  `android_release.apk` (~97 MB) waits for a release build. `android_source.zip` (the Gradle
  build template, 210 MB, the third file; CRC `e92cef23`) was fetched the same way on 2026-10-15,
  when exports moved to Gradle for the Nearby plugin (see "Phone-to-phone swapping" below).
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
  The paths are set now, so the plain command works too (and the editor's own export).
- **The silent export failure:** Godot refuses to export for Android unless
  `rendering/textures/vram_compression/import_etc2_astc` is on, and from the command line it says
  only ".NET on Android is experimental" (the editor shows a "Fix Import" button instead). It is
  on now. DrawPets' textures import lossless, so it changes nothing you can see.

## Step 2 - the export presets (done, `export_presets.cfg`)

**Android** - the game, debug-signed:
- **Package** `dev.ecec.drawpets`, to match ecec.dev. Version 0.0.1, code 1.
- **Architectures**: arm64-v8a (every phone from the last ~8 years); armeabi-v7a only if an old
  tablet needs it.
- **Permissions**: `RECORD_AUDIO`, and `INTERNET` for the pet swap's LAN fallback (sockets on the
  home Wi-Fi - nothing goes to a server). The Nearby plugin adds its own (see below).
- **Gradle build** (`gradle_build/use_gradle_build=true`): needed for Android plugins.
- **Include filter: `*.json, *.f32`** - critical. Godot only packs files it knows how to import;
  without this, `art/*/pivots.json` is missing (every drawing lands at the wrong spot) and
  `sfx/voices/*.f32` is missing (every pet is silent). Godot skips folders starting with a dot,
  and the excludes keep `tools/`, `docs/`, `build/` and `.claude/` out anyway.
- **Backup off** (`user_data_backup/allow=false`): Android's automatic backup would copy the
  saves - drawings and voice recordings - to the family's Google account. Nothing a child recorded
  leaves the device.
- **Icon**: `python tools/app_icon.py` crops Zorp, the demo kid's creature, from its journal's
  front page in a demo run (`.shots/demo_NN_journal.png`) into `icon/` - the project icon, the 192px launcher
  icon, and the two 432px adaptive layers (the crop on paper). A real frame, never drawn
  separately (the DrawFight rule).
- Immersive (no status bar), and the boot splash is plain paper rather than Godot's dark grey.

**Android Demo** - the same, with Extra Args `--demo --quit`: the scripted kid plays the whole game
on the device, screenshotting every step. **It is its own app, `dev.ecec.drawpets.demo`**, because
the demo plays on top of whatever save it finds - it redraws the first pet in the first home and
lets the last one go. As a separate package it has its own save and installs beside the real game,
so it can never touch a kid's pets.

## Phone-to-phone swapping: the DrawPetsNearby plugin (2026-10-15)

Kids swap pets phone to phone over Google's Nearby Connections (Bluetooth and Wi-Fi Direct; no
internet, no server). GDScript cannot reach it, so this is DrawPets' one piece of native code: a
Godot v2 Android plugin in Java. The game finds it with `Engine.get_singleton("DrawPetsNearby")`
(only on Android, and only in a Gradle export).

- **Source** - `android_plugin/`, a small Gradle project (committed; `.gdignore` keeps Godot out
  of it): `plugin/src/main/java/dev/ecec/drawpets/nearby/DrawPetsNearby.java` (every method and
  signal) and `plugin/src/main/AndroidManifest.xml` (the permissions, and the
  `org.godotengine.plugin.v2.DrawPetsNearby` entry Godot looks for). Gradle 8.11.1 (the wrapper)
  and Android Gradle Plugin 8.6.1 - the same as Godot 4.5.1's build template, so one download
  serves both. Java 17, minSdk 24, compileSdk 35, build-tools 35.0.1. It compiles against
  `org.godotengine:godot:4.5.1.stable` (compileOnly - Godot is already in the app) and
  `com.google.android.gms:play-services-nearby:19.5.1`.
- **Building it** - only after changing the Java or its manifest:
  ```
  cd android_plugin
  JAVA_HOME="C:/Users/ericc/AppData/Local/Programs/Eclipse Adoptium/jdk-17.0.20.1+1" \
  ANDROID_HOME="C:/Users/ericc/Android/Sdk" ./gradlew assemble
  ```
  (from cmd: set the same two variables, then `gradlew.bat assemble`). It builds both variants and
  copies them to `addons/drawpets_nearby/bin/DrawPetsNearby-debug.aar` and `-release.aar`, which
  are **committed**, so an export never needs this step. The first run downloads Gradle into
  `C:\Users\ericc\.gradle` and the Maven libraries (~7 minutes); after that ~1-2 minutes.
- **How it gets into an export** - `addons/drawpets_nearby/` is an editor plugin, enabled in
  `project.godot` (`[editor_plugins]`). Its `EditorExportPlugin`, for Android only, hands the
  export the AAR (`_get_android_libraries`) and the Maven coordinate of play-services-nearby
  (`_get_android_dependencies` - an AAR does not carry its dependencies, so the game's Gradle
  build fetches it). Gradle merges the plugin's manifest into the game's. **The Nearby version is
  written twice**: `nearbyVersion` in `android_plugin/plugin/build.gradle` and `NEARBY` in
  `addons/drawpets_nearby/drawpets_nearby.gd` - change both.
- **Exports now use Gradle.** Godot builds the APK from `android/build/` (gitignored: generated
  on each machine from `android_source.zip`). Install it once with the first export:
  `GRADLE_OPTS=-Dorg.gradle.daemon=false "$GODOT_BIN" --headless --path . --install-android-build-template --export-debug "Android" build/drawpets-debug.apk`
  (in the editor: Project > Install Android Build Template). **The first Gradle export downloads**
  Gradle, the Kotlin plugin, AndroidX, Play services and build-tools 35.0.0 (the template wants
  exactly that version) - 10-15 minutes. Later exports take ~5 minutes. The NDK is not needed.
  Reinstall the template after a Godot upgrade (`android/.build_version` must match).
- **From the command line, turn Gradle's daemon off**: `GRADLE_OPTS=-Dorg.gradle.daemon=false
  "$GODOT_BIN" --headless --path . --export-debug ...`. Otherwise the daemon Gradle leaves
  running inherits the console's output, and `_console.exe` sits after `[ DONE ] export` (the
  APK is already finished) until the daemon idles out hours later. The editor's own export is
  not affected.
- **APK size**: ~100 MB instead of ~49 MB, because Gradle stores `libgodot_android.so`
  uncompressed (Android's recommended way: it loads straight from the APK, so the installed app
  is no bigger). `gradle_build/compress_native_libraries=true` in a preset would shrink the
  download back if that ever matters.

**Permissions** (in the plugin's manifest; the dangerous ones are asked for by
`request_permissions()`, only those this Android version needs):

| Android | asked for at run time | declared only |
|---|---|---|
| 7-9 (API 24-28) | `ACCESS_COARSE_LOCATION` | `BLUETOOTH`, `BLUETOOTH_ADMIN`, Wi-Fi state |
| 10-11 (29-30) | `ACCESS_FINE_LOCATION` (+ coarse) | the same |
| 12-12L (31-32) | `BLUETOOTH_SCAN`, `_ADVERTISE`, `_CONNECT`, `ACCESS_FINE_LOCATION` (+ coarse) | Wi-Fi state |
| 13+ (33+) | `BLUETOOTH_SCAN`, `_ADVERTISE`, `_CONNECT`, `NEARBY_WIFI_DEVICES` | Wi-Fi state |

Location is declared only up to API 32; `BLUETOOTH_SCAN` and `NEARBY_WIFI_DEVICES` carry
`neverForLocation`, so a phone on Android 13+ never asks a child for location at all. Also
declared on every version: `ACCESS_WIFI_STATE`, `CHANGE_WIFI_STATE`, `CHANGE_WIFI_MULTICAST_STATE`
(the LAN fallback's UDP broadcast); play-services adds `ACCESS_NETWORK_STATE`. Bluetooth, BLE,
Wi-Fi and location are `uses-feature required="false"` - swapping is optional, so a store must
not hide the game from a tablet without one of them.

**How the plugin behaves** (what the GDScript side can rely on):
- Methods run on Godot's thread; Nearby answers on Android's main thread; every signal is handed
  back to Godot's render thread (`runOnRenderThread`), so it arrives between frames like any
  other signal - never in the middle of a GDScript function, never synchronously inside the call
  that caused it (even `request_permissions()` with nothing missing answers a frame later).
- `start()` advertises and discovers at once (`P2P_POINT_TO_POINT`) and is safe to call again.
  **Once connected, the plugin stops advertising and discovering by itself** - one friend at a
  time, and searching on would hold back Nearby's upgrade from Bluetooth to Wi-Fi. Call `start()`
  again to look for someone else.
- `send_bytes()` writes the bytes to `cache/nearby_out/` and sends them as a FILE payload (BYTES
  payloads stop at ~32 KB); the file is deleted when the send ends either way. A received file is
  read into memory and deleted at once, so nothing another child sent stays on the phone as a
  file. Anything over 64 MB is refused (`error`). `transfer_progress` comes at most every 100 ms,
  plus a final `done == total`.
- `disconnect_endpoint()` and `stop()` are silent: `disconnected` is only for the other side
  leaving or the link dropping (Nearby's own rule).
- Android's permission answer also reaches `get_tree().on_request_permissions_result`, once per
  permission (Godot forwards every answer), so a one-shot listener waiting for `RECORD_AUDIO`
  should check the permission name before it disconnects.
- `acquire_multicast_lock()` / `release_multicast_lock()` work without Play services; the lock is
  released when the app closes.

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
export GRADLE_OPTS=-Dorg.gradle.daemon=false   # or the console export never returns (see above)
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
- **The camera hole** is an 84 px circle centred on one short edge - in landscape, the middle of
  the left or right edge, whichever way the phone is held; Android reports a 173 px unsafe band
  on that side. The game draws edge to edge, so GameRoot reads `DisplayServer.get_display_safe_area()`
  twice a second (turning the phone moves the hole) and keeps every menu and the home's buttons
  inside it (`UI.fit_safe`, `UI.safe_insets`); a place's world still runs to the edge. The extra
  width of a 2.24:1 screen means this costs nothing. Zero on a computer.
- **Timing**: `[timing] fill`, `[timing] voice` and `[timing] home` lines in the log
  (`adb logcat -s godot`). On the PC a fill takes 84-132 ms and a voice 5-32 ms; a fill over
  ~300 ms on a phone is the sign to move the flood fill out of GDScript.
- **Hardened:** springy parts (ears, horns, antennae) took one step per frame, so a long frame
  (a voice being worked out, a screen loading) could overshoot them - now small fixed steps,
  capped. Prompted by "the pig's ears are all over the place"; not yet confirmed as the cause.

## Later

- A release keystore (kept out of git, like DrawFight's) and a release preset.
- Sideloading for the family vs the Play Store: the Play Store means a developer account, a
  privacy policy and the Families policy (the players are under 13 - see `sharing.md`).
- iOS: needs a Mac with Xcode and an Apple developer account.
