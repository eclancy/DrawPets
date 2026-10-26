# -*- coding: utf-8 -*-
"""Turn the exports in build/windows/ and build/linux/ into the files a GitHub Release carries.

    python tools/release/package.py 0.1.0

Writes build/release/:

  DrawPets-windows.zip   everything, in a DrawPets/ folder - the portable version (the
                         installer is what a new player downloads)
  DrawPets-patch.zip     just DrawPets.pck: every script, picture and sound. A fraction of the
                         full zip, because the engine only changes when Godot is upgraded.
  DrawPets-web.zip       the web version (build/web/, made by tools/web_build.sh): ecec.dev's
                         deploy unpacks the newest release's copy into /drawpets/play/
  DrawPets-linux.tar.gz  the Linux version, in a DrawPets/ folder with install.sh (which puts it
                         in ~/.local/share and on the app menu) - from build/linux/
  DrawPets-linux-patch.zip  the Linux patch: the Linux export's DrawPets.pck
  version.json           what the game's update check reads (scripts/update_screen.gd)

release.sh adds the other two files from the same commit: DrawPets-Setup.exe (Inno Setup,
installer.iss) and DrawPets.apk (the Android export, signed with the release key);
version.json carries both URLs.

Normally run by tools/release/release.sh rather than by hand. See .ai/releasing.md.
Python 2.7, like every other tool in this repo.
"""
from __future__ import print_function

import io
import json
import os
import sys
import tarfile
import time
import zipfile

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
EXPORT = os.path.join(ROOT, "build", "windows")
LINUX = os.path.join(ROOT, "build", "linux")
WEB = os.path.join(ROOT, "build", "web")
OUT = os.path.join(ROOT, "build", "release")
REPO = "eclancy/DrawPets"
NAME = "DrawPets"
FULL_ZIP = NAME + "-windows.zip"
PATCH_ZIP = NAME + "-patch.zip"
INSTALLER = NAME + "-Setup.exe"
APK = NAME + ".apk"
WEB_ZIP = NAME + "-web.zip"
LINUX_TAR = NAME + "-linux.tar.gz"
LINUX_PATCH = NAME + "-linux-patch.zip"

# The engine the export was made with. A patch is only offered to a copy on the same engine;
# anything else downloads the full zip. Read from the editor binary's name rather than
# hard-coded, so upgrading Godot cannot leave this behind.
GODOT = os.environ.get("GODOT_BIN", "")

# What the patch carries: everything that changes when the game changes and the engine does not.
# DrawPets is all GDScript, so that is the .pck alone.
PATCH = [NAME + ".pck"]

HOW_TO_PLAY = u"""DrawPets
========

Draw a creature part by part - a head, legs, wings, a tail, anything - and it comes alive. Then
it is yours to look after: feed it, play with it, take it on walks and give it a home.

1. Double-click DrawPets.exe.

2. The first time, Windows may say "Windows protected your PC". That is because this game
   is not from a big company that paid for a signature. Click "More info", then "Run anyway".

3. The mouse is your finger: click to tap, and hold the button down to draw, drag and stroke
   your pet.

Everything you make stays on this computer. The game updates itself: every time it starts, it
checks for a new version and installs it. Keep this folder somewhere you can write to, like
Documents or the Desktop, so it can.

Made at https://ecec.dev - download page: https://ecec.dev/drawpets/download
"""


HOW_TO_PLAY_LINUX = u"""DrawPets
========

Draw a creature part by part - a head, legs, wings, a tail, anything - and it comes alive. Then
it is yours to look after: feed it, play with it, take it on walks and give it a home.

1. Open a terminal in this folder and run:  ./install.sh
   That puts the game in ~/.local/share/DrawPets and adds it to your app menu.
   (Or just run ./DrawPets.x86_64 from here - keep the folder somewhere you can write to.)

2. The mouse is your finger: click to tap, and hold the button down to draw, drag and stroke
   your pet.

Everything you make stays on this computer. The game updates itself: every time it starts, it
checks for a new version and installs it.
To remove it: ~/.local/share/DrawPets/install.sh --uninstall  (your pets are kept)

Made at https://ecec.dev - download page: https://ecec.dev/drawpets/download
"""


def add_tar_file(t, data, name, executable=False):
    info = tarfile.TarInfo(name)
    info.size = len(data)
    info.mode = 0o755 if executable else 0o644
    info.mtime = int(time.time())
    t.addfile(info, io.BytesIO(data))


def linux_package():
    """The Linux download and patch. Every file gets its permissions set here, on Windows: the
    game binary and install.sh executable, the rest readable."""
    t = tarfile.open(os.path.join(OUT, LINUX_TAR), "w:gz")
    for dirpath, _dirs, files in os.walk(LINUX):
        for f in sorted(files):
            full = os.path.join(dirpath, f)
            rel = os.path.relpath(full, LINUX).replace(os.sep, "/")
            with open(full, "rb") as fh:
                add_tar_file(t, fh.read(), NAME + "/" + rel, executable=rel == NAME + ".x86_64")
    with open(os.path.join(ROOT, "tools", "release", "install.sh"), "rb") as fh:
        add_tar_file(t, fh.read().replace(b"\r\n", b"\n"), NAME + "/install.sh", executable=True)
    with open(os.path.join(ROOT, "icon", "icon.png"), "rb") as fh:
        add_tar_file(t, fh.read(), NAME + "/icon.png")
    add_tar_file(t, HOW_TO_PLAY_LINUX.encode("utf-8"), NAME + "/How to play.txt")
    t.close()

    z = zipfile.ZipFile(os.path.join(OUT, LINUX_PATCH), "w", zipfile.ZIP_DEFLATED)
    for rel in PATCH:
        z.write(os.path.join(LINUX, rel), rel)
    z.close()


def engine_version():
    name = os.path.basename(GODOT)
    # Godot_v4.5.1-stable_mono_win64_console.exe -> 4.5.1
    if name.startswith("Godot_v"):
        return name[len("Godot_v"):].split("-")[0]
    raise SystemExit("set GODOT_BIN to the Godot editor, so the engine version is known")


def add_tree(z, src, prefix):
    for dirpath, _dirs, files in os.walk(src):
        for f in sorted(files):
            full = os.path.join(dirpath, f)
            rel = os.path.relpath(full, src).replace(os.sep, "/")
            z.write(full, prefix + rel)


def main(argv):
    if not argv:
        print(__doc__)
        return 1
    version = argv[0]
    # Before writing anything, so a missing GODOT_BIN cannot leave half a release behind.
    engine = engine_version()
    for rel in PATCH + [NAME + ".exe"]:
        if not os.path.isfile(os.path.join(EXPORT, rel)):
            raise SystemExit("no %s in build/windows - run the Godot export first" % rel)
    if not os.path.isfile(os.path.join(WEB, "index.pck")):
        raise SystemExit("no web build in build/web - run tools/web_build.sh first")
    if not os.path.isdir(OUT):
        os.makedirs(OUT)

    full = os.path.join(OUT, FULL_ZIP)
    z = zipfile.ZipFile(full, "w", zipfile.ZIP_DEFLATED, allowZip64=True)
    add_tree(z, EXPORT, NAME + "/")
    z.writestr(NAME + "/How to play.txt", HOW_TO_PLAY.replace(u"\n", u"\r\n").encode("utf-8"))
    z.close()

    patch = os.path.join(OUT, PATCH_ZIP)
    z = zipfile.ZipFile(patch, "w", zipfile.ZIP_DEFLATED)
    for rel in PATCH:
        z.write(os.path.join(EXPORT, rel), rel)
    z.close()

    # The web version, files at the top of the zip: they go straight into /drawpets/play/.
    web = os.path.join(OUT, WEB_ZIP)
    z = zipfile.ZipFile(web, "w", zipfile.ZIP_DEFLATED, allowZip64=True)
    add_tree(z, WEB, "")
    z.close()

    linux = os.path.isfile(os.path.join(LINUX, NAME + ".pck"))
    if linux:
        linux_package()

    base = "https://github.com/%s/releases/download/v%s/" % (REPO, version)
    info = {
        "version": version,
        "engine": engine,
        "patch": base + PATCH_ZIP,
        "full": base + FULL_ZIP,
        # Built by release.sh after this script runs. The Windows updater does not read them; they
        # are there for anything that wants this release's installer or APK by URL.
        "installer": base + INSTALLER,
        "android": base + APK,
        "web": base + WEB_ZIP,
    }
    # A Linux copy reads its own pair; Windows copies never look at it.
    if linux:
        info["linux"] = {"patch": base + LINUX_PATCH, "full": base + LINUX_TAR}
    with io.open(os.path.join(OUT, "version.json"), "w", encoding="utf-8") as f:
        f.write(unicode(json.dumps(info, indent=2, sort_keys=True)) + u"\n")

    for name in [FULL_ZIP, PATCH_ZIP, WEB_ZIP, "version.json"] + ([LINUX_TAR, LINUX_PATCH] if linux else []):
        print("%-30s %6.1f MB" % (name, os.path.getsize(os.path.join(OUT, name)) / 1048576.0))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
