# -*- coding: utf-8 -*-
"""The app icon: the launcher on a phone, the Windows exe and installer, the Godot project manager.

Run:
    "$GODOT_BIN" --path . -s tools/bake_art.gd -- --group=brand   -> art/brand/*.png
    python tools/app_icon.py                                      -> icon/*.png, icon/icon.ico

The icon is DrawPets' mascot (scripts/art_brand.gd): a pet a kid drew, close up and smiling,
hugging the coloured pencil it was drawn with. Eric asked for it on 2026-10-19; until then the icon
was a crop of a demo screenshot (DrawFight's rule), which at launcher size read as a small creature
in a field rather than as a face. It is drawing code like every other picture in the game, so
change art_brand.gd and re-bake - never edit these PNGs.

Android adaptive icons are two 432px layers: the launcher masks them to a circle or squircle
showing only the middle 288px, and may slide the front one about. So the front layer is
icon_pet_round - the pet drawn smaller, inside that circle, its body running off the bottom - and
the back is the plain sky square. Everywhere else (the legacy Android icon, Windows, Godot) gets
the close-up icon_pet on the sky, filling the square.

Only Python 2.7 with PIL is needed.
"""
import os
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
ART = os.path.join(ROOT, "art", "brand")
OUT = os.path.join(ROOT, "icon")

ADAPTIVE = 432

# The Windows icon - DrawPets.exe, the installer and the Start menu - at every size Windows asks
# for.
ICO_SIZES = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]


def layer(name):
    path = os.path.join(ART, name + ".png")
    if not os.path.isfile(path):
        raise SystemExit("no art/brand/%s.png - run the bake command in this file's docstring" % name)
    img = Image.open(path).convert("RGBA")
    if img.size != (512, 512):
        raise SystemExit("art/brand/%s.png should be 512x512, got %dx%d" % ((name,) + img.size))
    return img


def main():
    back = layer("icon_back")
    pet = layer("icon_pet")
    round_pet = layer("icon_pet_round")

    full = back.copy()
    full.alpha_composite(pet)
    full = full.convert("RGB")

    if not os.path.isdir(OUT):
        os.makedirs(OUT)

    # A smooth resample, not nearest: the drawing is anti-aliased marker, not pixel art.
    def write(name, img):
        img.save(os.path.join(OUT, name))
        print("wrote icon/%s  %dx%d" % (name, img.size[0], img.size[1]))

    write("icon.png", full.resize((256, 256), Image.LANCZOS))
    write("android_main.png", full.resize((192, 192), Image.LANCZOS))
    write("android_front.png", round_pet.resize((ADAPTIVE, ADAPTIVE), Image.LANCZOS))
    write("android_back.png", back.convert("RGB").resize((ADAPTIVE, ADAPTIVE), Image.LANCZOS))
    # The web version's home-screen icons (an installed web app on a phone, tablet or computer).
    for size in (144, 180, 512):
        write("pwa_%d.png" % size, full.resize((size, size), Image.LANCZOS))
    full.resize((256, 256), Image.LANCZOS).save(os.path.join(OUT, "icon.ico"), sizes=ICO_SIZES)
    print("wrote icon/icon.ico  %s" % ", ".join(str(w) for w, _h in ICO_SIZES))


if __name__ == "__main__":
    sys.exit(main())
