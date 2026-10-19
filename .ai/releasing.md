# Releasing

Decided 2026-10-18. How a downloadable copy of DrawPets gets to people on Windows and Android,
and how it stays up to date. The same design as DrawFight's, Wizard Wars' and Wizard Survivors'
(their `.ai/releasing.md`), plus an Android APK.

**In one line:** `bash tools/release/release.sh X.Y.Z` makes a GitHub Release. The next time a
Windows copy starts it updates itself; an Android copy says on its home screen that a grown-up
can get the new one.

**Live since 2026-10-19** with 0.1.0: the repo went public (its history checked for keys,
passwords and personal details first), and the download page, the nginx redirects and the game
page went out on ecec.dev.

## Where things live

| What | Where | Why |
|---|---|---|
| The download page | `ecec.dev/drawpets/download` (`public/drawpets/download/` in the EricClancyEngineeringAndCrafts repo) | the page people are sent. Both buttons; a phone sees Android first |
| The game files | GitHub Releases on `eclancy/DrawPets` | GitHub serves release downloads free with no bandwidth limit |
| The update check | `ecec.dev/drawpets/version.json` | an nginx 302 to `github.com/eclancy/DrawPets/releases/latest/download/version.json` |

The update address is on ecec.dev, not GitHub, because it is the one address compiled into every
copy ever downloaded (`UpdateScreen.VERSION_URL`). The download buttons link to GitHub's
`releases/latest/download/...`, so **neither the page nor ecec.dev needs a deploy for a release**.

## What a release contains

- **`DrawPets-Setup.exe`**: the Windows installer, and what a new Windows player downloads. Inno
  Setup builds it from `tools/release/installer.iss`, out of the `build/windows/` export.
- **`DrawPets.apk`**: the Android game, signed with the release key (below).
- **`DrawPets-windows.zip`**: the whole Windows export in a `DrawPets/` folder, with a
  `How to play.txt` - the portable version.
- **`DrawPets-patch.zip`**: `DrawPets.pck` alone - every script, picture and sound (DrawPets is
  all GDScript, so there is no DLL). The rest of the full zip is the Godot engine.
- **`version.json`**: the version, the Godot version it was built with, and the URLs of the
  patch, the full zip, the installer and the APK.

`tools/release/package.py` makes the zips and `version.json`; `release.sh` does the rest.

## The installer

Per user, into `%LOCALAPPDATA%\Programs\DrawPets`, with no admin prompt
(`PrivilegesRequired=lowest`), so the folder stays writable and the game can update itself.
**Its `AppId` GUID is fixed and must never change** - it is how Windows knows a new installer is
an upgrade of the copy already there. The uninstaller removes the install folder and **never
touches the kid's pets**, which live in `%APPDATA%\Godot\app_userdata\DrawPets\`.

## How a Windows copy updates

`UpdateScreen` (`scripts/update_screen.gd`) is the first screen of an exported Windows build. It
never runs in the editor, from `godot --path .`, with `--demo`, or with `--no-update`.

1. It fetches `version.json` (5-second timeout) and compares versions number by number, so
   0.10.0 beats 0.9.0. The game's own version is `application/config/version` in
   `project.godot`, which the release script sets. Settings shows it.
2. If the release was built with the same Godot version as this copy, it downloads the patch;
   otherwise the full zip. It unpacks to `user://update/`.
3. Windows will not let a running program overwrite its own files, so the game writes
   `apply.cmd`, starts it, and quits. The script waits for the game to close, `robocopy`s the new
   files over the old ones, and starts the game again.

Anything that goes wrong - no internet, GitHub down, a folder it cannot write to - just goes on
into the game. **An update is never worth not being able to play.**

## Android

A game cannot replace itself on Android, so `UpdateScreen.check_quietly` only finds out, in the
background, once per launch. If there is a newer version the home screen says "A new DrawPets is
out! Ask a grown-up to get it from ecec.dev/drawpets/download" - plain text, not a link: nothing
in the game sends a kid out to the web. Installing the new APK over the old one keeps every pet.

That only works because every release is **signed with the same release key** and has a higher
**version code** (release.sh sets it from the version: 1.2.3 -> 10203).

**The release key** lives outside the repo, in `C:\Users\ericc\.drawpets-release\`:
`drawpets-release.keystore` and `release.env` (its password, and the three
`GODOT_ANDROID_KEYSTORE_RELEASE_*` variables Godot's export reads). release.sh reads
`release.env` (or the file named by `DRAWPETS_RELEASE_KEYS`) and refuses an APK still signed with
the debug key. **Back that folder up somewhere safe.** Lose it, and a phone with DrawPets can only
get a new version by uninstalling first - which deletes every pet on it.

A phone with a **debug** build (from development, `.ai/android.md`) cannot install the release
APK over it - different key. Uninstalling the debug build deletes its pets; for testing, use the
Android Demo package (`dev.ecec.drawpets.demo`) or a phone without DrawPets.

## Making a release

```sh
bash tools/release/release.sh 0.2.0 "A new pet food: noodles. Walks find more presents."
bash tools/release/release.sh 0.2.0 --build-only     # build into build/release/, nothing else
```

The quoted text is what players see under "What's new" on `ecec.dev/games/drawpets` - write it
for them, one change a line. It needs a clean working tree (not for `--build-only`). The script
sets the version, exports Windows and Android, packages, compiles the installer, commits
"Release v0.2.0", tags it, pushes, and runs `gh release create`. About ten minutes; the Android
Gradle build and the installer's maximum compression are most of it.

Version numbers: bump the last number for fixes, the middle one for something new to do.

**One-time setup on a new machine:** Godot's export templates for the exact editor version
(`windows_*` and `android_*` in `%APPDATA%\Godot\export_templates\<version>.stable.mono\`), Inno
Setup 6 (`winget install JRSoftware.InnoSetup`), the Android setup in `.ai/android.md`, and the
release key folder restored from its backup.

**Testing an update without publishing:** export an older version to `build/test/`, serve a
`version.json` that points at local zips with any web server, and run the old copy with
`DRAWPETS_UPDATE_URL` set to it.

## Things to know

- **Windows SmartScreen** warns "Windows protected your PC" the first time, because neither the
  exe nor the installer is code-signed. The page and `How to play.txt` say to click "More info",
  then "Run anyway".
- **Android's Play Protect** may say it does not recognise the app, because it does not come from
  the Play Store. The page says to tap "More details", then "Install anyway". A grown-up also has
  to allow their browser to install apps.
- **Upgrading Godot** changes the engine version, so every Windows copy downloads the full zip
  once. Install the new export templates before releasing.
- **What the game sends over the internet:** the update check - a plain request for
  `version.json` with `DrawPets/<version>` as its user agent, nothing about the player. Swapping
  pets never uses the internet (`.ai/sharing.md`).
- On Windows there is no Nearby and no camera scanner: the big swap button uses the Wi-Fi way, and
  a PC can show a swap code for a phone to scan.
