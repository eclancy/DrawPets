# -*- coding: utf-8 -*-
"""The app icon: the launcher on a phone, the Godot project manager, the taskbar.

Run:
    "$GODOT_BIN" --path . -- --demo --quit     -> .shots/demo_NN_journal.png among the rest
    python tools/app_icon.py                   -> icon/*.png

IT IS A CROP OF A REAL FRAME OF THE GAME, not a drawing made for the icon (the DrawFight rule):
an icon drawn separately is a second answer to "what does this game look like", and it drifts
the moment the game changes. This one is Zorp - the creature the demo kid draws, stroke by
stroke, through the real screens - in its portrait on the front page of its journal, the same
pose every run. When a real kid's pet should be the face of the game, point SHOT_NAME at a frame
of it.

Look at the result before committing it - if the demo's drawing or the journal's layout moves
Zorp, adjust PET below.

Android adaptive icons are two 432px layers: the launcher masks them to a circle or squircle
showing only the middle 288px, and may slide the front one about. So the front layer is the
crop at 320px (a little more than the 288 the mask shows, so no paper peeks in) and the back is
plain paper.

Only Python 2.7 with PIL is needed.
"""
import os
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, ".."))

# Found by name: the demo numbers its shots in order, so the number moves as steps are added.
SHOTS = os.path.join(ROOT, ".shots")
SHOT_NAME = "_journal.png"
OUT = os.path.join(ROOT, "icon")

# Zorp on the 1280x720 journal page: centre x, centre y, square side. Tail tip to ears, wing tips
# to feet, stopping above the words under the portrait.
PET = (191, 250, 290)

PAPER = (246, 243, 236)    # project.godot default_clear_color - the paper every screen sits on

ADAPTIVE = 432
ADAPTIVE_ART = 320


def main():
    found = []
    if os.path.isdir(SHOTS):
        found = sorted(f for f in os.listdir(SHOTS) if f.startswith("demo_") and f.endswith(SHOT_NAME))
    if not found:
        raise SystemExit("no .shots/demo_*%s - run the --demo command in this file's docstring"
                         % SHOT_NAME)
    shot = Image.open(os.path.join(SHOTS, found[-1])).convert("RGB")
    if shot.size != (1280, 720):
        raise SystemExit("expected a 1280x720 demo screenshot, got %dx%d" % shot.size)

    cx, cy, side = PET
    half = side // 2
    pet = shot.crop((cx - half, cy - half, cx - half + side, cy - half + side))

    if not os.path.isdir(OUT):
        os.makedirs(OUT)

    # A smooth resample, not nearest: the frame is anti-aliased marker, not pixel art.
    def write(name, img):
        img.save(os.path.join(OUT, name))
        print("wrote icon/%s  %dx%d" % (name, img.size[0], img.size[1]))

    write("icon.png", pet.resize((256, 256), Image.LANCZOS))
    write("android_main.png", pet.resize((192, 192), Image.LANCZOS))

    front = Image.new("RGBA", (ADAPTIVE, ADAPTIVE), (0, 0, 0, 0))
    at = (ADAPTIVE - ADAPTIVE_ART) // 2
    front.paste(pet.resize((ADAPTIVE_ART, ADAPTIVE_ART), Image.LANCZOS), (at, at))
    write("android_front.png", front)
    write("android_back.png", Image.new("RGB", (ADAPTIVE, ADAPTIVE), PAPER))


if __name__ == "__main__":
    sys.exit(main())
