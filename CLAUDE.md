# DrawPets - agent instructions

A virtual-pet game (Nintendogs is the model) where every pet is a creature a kid drew, part by
part, inside the game. Sibling of `../DrawFight`, built on its lessons but with no photos, no
cutting and no AI: kids draw each part on its own sheet, drag the parts onto the body, and each
part type's motion recipe brings it to life.

Godot 4.5, **GDScript**, 2D, GL Compatibility renderer. **Android first**, iOS later, landscape.
Players are 10-12. **M0 and M1 are built**: drawing and assembly; homes with several pets,
decorating, food/toys/clothes (drawn, starter kit or shop) described by preset words; six stats
trained by play; gold stars and a shop; a weekly competition calendar with six events and eight
rival pets. Since then: day and night from the clock, mud and the bath, walks with presents to
draw, trick cards taught by swipe, a camera with an album and a journal per pet, and calling
by loudness (`.ai/roadmap.md`).

Everything is built in code; `scenes/Main.tscn` only attaches `GameRoot`. `GameRoot` owns the
screen flow and the family save (`Profile`) and swaps screens as its own children: home ->
creator -> place -> home, home -> shop / calendar -> event -> competition. The creator swaps its
own steps the same way. Gold stars are only ever paid through `GameRoot.reward`, which toasts why.

## Design docs - read before designing

`.ai/` is the design source of truth. Read the relevant doc before any design or content
decision; do not restate it here.

- `.ai/project-overview.md` - the pitch, the five pillars, every decision made so far
- `.ai/creature-pipeline.md` - the red dot, the ghost, auto-layout, body space, motion recipes,
  parts-decide-abilities. **Read before touching DrawCanvas, PetBuilder, Creature or any part.**
- `.ai/pet-life.md` - needs, stats, trust, describing words, favourites, the optional mic.
  **Read before adding any need, stat, word, reaction or reward.**
- `.ai/places.md` - the fourteen places, homes, decorating and furniture behaviour
- `.ai/shop.md` - gold stars, every milestone, the shop, shiny things, room to grow and trust
- `.ai/competitions.md` - the calendar, six events, cups, rivals, the stat-plus-timing rule
- `.ai/art-direction.md` - creatures own black; pencil or marker; shine only for special things
- `.ai/audio-direction.md` - how every sound is made, pet voices and their variation, the mic,
  the mix. **Read before adding or changing any sound.**
- `.ai/android.md` - building, installing and debugging on Android phones and tablets
- `.ai/sharing.md` - ecec.dev sharing, and the child-privacy rules it must follow
- `.ai/roadmap.md` - milestones, the idea backlog, open questions with their defaults

## The rules that are not negotiable

1. **Never smooth, straighten, trace or "improve" a kid's stroke.** Parts only rotate and
   squash about their joint. Mud, hats and the rest are overlays that come off.
2. **Motion belongs to the part type**, never to one creature. A new behaviour is a new recipe
   in `CreaturePart` or a new channel on `Creature`, so every creature gets it.
3. **Gentle care.** No sickness, no running away, no death, no guilt. Needs have a floor.
4. **The game never judges a drawing.** Contests, tastes and reactions read data the kid chose
   (words, stats, care, timing), never the pixels.
5. **Words drive behaviour.** A toy, food, furniture or pet does what its describing words say
   (`Words`) - never what it looks like.
6. **Every made-for-the-game picture is a drawing** - coloured pencil or marker from `Crayon`,
   baked from drawing code. Shine and sparkle (`Shiny`) are only for special, bought things.
7. **No AI**, including speech recognition. The mic is loudness and playback only, and it is
   optional - every mic feature has a touch equivalent.
8. **Nothing a child recorded leaves the device**, and nothing they drew is shared without a
   parent and moderation (`.ai/sharing.md`).

## Build & run

- `"$GODOT_BIN" --headless --path . --import` - parses every script; the quickest check.
- `"$GODOT_BIN" --path .` - run it. Mouse stands in for a finger.
- **`"$GODOT_BIN" --path . -- --demo --quit`** - a scripted kid draws a whole creature through
  the real screens (real strokes, real bucket fills), then feeds it, plays fetch and pets it,
  writing a screenshot of every step to `.shots/demo_*.png`. **This is how changes to drawing,
  assembly, motion or the place get verified** - look at the shots, not just the log.
  It goes on to play with every kind of toy, pet it, decorate, shop, dress up, and play all six
  competitions. **It plays on whatever save it finds**, so give it a fresh one that leaves the
  real save alone: `APPDATA=<an empty folder> "$GODOT_BIN" --path . -- --demo --quit` (Godot puts
  `user://` under `APPDATA`; the shots still go to `.shots/`).
- `--screen=place|create|shop|calendar` boots straight into a screen; `--stars=N` adds stars;
  `--shot=N` screenshots frame N; `--hour=21.5` pretends it is that time (night, dusk, morning);
  F12 grabs a frame.
- **`python tools/audio/build.py --all --sheet`** - regenerates every sound effect
  (`sfx/*.wav`), pet-voice base (`sfx/voices/*.f32`), place ambience (`sfx/ambience/*.wav`) and
  music loop (`music/*.wav`), and draws each as a spectrogram in `.shots/sound_*.png` - look at
  those, since nobody here can listen. Then `--import`. Never hand-edit a sound. `tools/voice_check.gd`
  + `tools/audio/sheet.py` check the voice sliders the same way (`.ai/audio-direction.md`).
- **`"$GODOT_BIN" --path . -s tools/bake_art.gd -- --group=<group> [--only=a,b]`** - groups:
  things, wear, ui, homes, rivals, adopt_a, adopt_b, adopt_c, adopt_d (every
  `scripts/art_<group>.gd`) -
  bakes the game's drawings from `scripts/art_<group>.gd` into `art/<group>/*.png` and
  `pivots.json`, with a contact sheet in `.shots/art_<group>.png` (and the assembled rivals in
  `.shots/art_<group>_assembled.png` for any group with a ROSTER of creatures). Needs a window. Then run `--import` so Godot picks the
  PNGs up. Never hand-edit a baked PNG; change the drawing code.
- **`python tools/app_icon.py`** - the app icon, cropped from a demo screenshot into `icon/`.
- Android export, install and debugging: `.ai/android.md`. The demo has its own preset and
  package (`dev.ecec.drawpets.demo`) so it never plays on a real save.
- `$GODOT_BIN` is set in `.claude/settings.json` (the .NET build, which runs GDScript fine).
  If it is unset or missing, stop and say so rather than guessing a path.
- Saves live in `user://` - on Windows `%APPDATA%\Godot\app_userdata\DrawPets\`:
  `profile.json` (stars, homes, owned things), `pets/<id>/`, and `items/<id>/` (kids' drawn
  toys, food, furniture, clothes). Delete them all for a fresh start.

A clean `--import` does not mean it works: animation and feel have to be looked at. When you
have only parsed, say so and list what still needs checking in a run.

## Conventions

- `scripts/` and `scenes/` are flat. snake_case files, each with a `class_name`.
- Data lives in `const` tables in code (`PartTypes`, `Places`, `Words`, `Items.KIT/SHOP`,
  `Events`, `Stats`), not in `.tres` files, until there is a reason for an editor.
- Items (food, toys, furniture, clothes) go through `Items.get_item(id)` whatever their source.
- A pet in memory is a plain Dictionary shaped like its `pet.json`, plus `_img` and `_tex`.
  Layout is in body space - see `.ai/creature-pipeline.md`.
- Screens take their inputs as fields set before they enter the tree, and report back through a
  `Callable` (`on_done`), not signals to a global.
- UI goes through `UI` (theme, buttons, titles); code-drawn art through `Crayon`.
- Input is mouse events, which Godot also generates from the first finger. Multi-touch will read
  `InputEventScreenTouch` directly.

## Don't

- Name a method after a built-in (`set_size`, `reference`...). GDScript treats it as an
  override and refuses to compile.
- Infer a type from a Dictionary read (`var x := d["k"]`) - it is a parse error. Use `var x: T =`.
- Draw anything outside a creature in black, or a night sky dark.
- Write per-place drawing code. Places are data; new things in them are props in `PlacePainter`.
- Randomise a crayon wobble. Hash it from a seed with `Crayon.noise`.
- Add C#. It would cost the iOS and web exports.
- Change the screen in the middle of a button press - go through `GameRoot.show_screen`, which
  defers the swap.
- Hand a screen that will outlive yours (`on_done`, `on_back`) a lambda or method of your own
  screen: yours is freed by the time it calls, and the kid is stuck. Bind a method of the game
  (`game.go_place.bind(home_id)`, `game.back_to_place.bind(...)`). A screen swapping its own steps or panels throws the old one away with
  `UI.retire`, never `remove_child`: on a phone a lifted finger arrives as a mouse release AND a
  touch release, and Godot errors if the button has left the tree in between.
- Put a multi-line lambda in the middle of an argument list. Assign it to a variable first, or
  use a bound method (`_pick.bind(x)`).
- Connect a static lambda to a long-lived signal (`profile.stars_changed`). Connect a method of
  the node that cares, so the connection dies with it.
- Pay stars anywhere but `GameRoot.reward` / `reward_daily`, or add a repeatable reward without
  a daily cap (`.ai/shop.md`).
- Add volume at a call site to balance a sound. The mix is the peak targets in
  `tools/audio/sfx.py`; change one there and rebuild.
- Store a sound the game must read back (a voice base, a recording) as an imported WAV - Godot
  compresses those and the samples are gone. Raw float `.f32`, like `sfx/voices/`.
- Upload, share or send a recording a child made. Ever.
