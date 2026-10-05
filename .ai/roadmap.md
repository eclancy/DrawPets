# Roadmap

Milestones in build order, the idea backlog, and the questions still open.

## M0 - Draw it, it lives (built)

Part picker; drawing sheets with crayon, gap-jumping bucket, eraser, undo; the red dot and the
ghost; auto-layout; assembly; procedural motion for 16 part types; walk / hop / fly / swim from
the parts; sizes and places; pet, feed, fetch; gentle needs; save and load; `--demo`.

## M1 - A life to live (built)

- **Faces**: eyes and a mouth required; mouths drawn open, shut at rest, opening to eat, pant,
  grin, bark and yawn.
- **Describing words** for toys, food, furniture, clothes, pets and places, driving behaviour.
- **Items**: one system for food, toys, furniture and clothes - drawn, free starter kit, or shop.
  Favourite food and toy picked or drawn.
- **Homes**: plots and rooms, several pets to a home, choosing where a new pet lives.
- **Decorating**, and pets using furniture by its words.
- **Tug of war**, word-driven toy physics, after-fetch behaviours (nap, chew, puzzle).
- **Stats**: six, trained by play, gentle slip; **trust** hearts.
- **Gold stars** with milestone toasts; **the shop**: shiny toys, clothes, shiny markers, treats,
  furniture, special places, room to grow (gated on trust).
- **Wardrobe**: clothes fitted to any creature's shape.
- **Competitions**: weekly calendar, six events (one per stat), four cups, eight rival pets, a
  podium, ribbons, a Gold Medal.
- **Art**: ~170 drawings in coloured pencil and marker baked by `tools/bake_art.gd`; shine and
  sparkle for special things.

## M1.5 - Drawing in stages, adopting, ready-built homes (built)

- Heads, arms and legs asked up front; add-ons (eyes, horns, hands, feet, claws...) drawn while
  drawing their host, previewed in place; new part types hand, foot, claw.
- Picture buttons throughout (`art_ui.gd`).
- Forty adoptable pets in the shop, with a meet panel.
- Fourteen ready-built homes for empty plots, named by the kid.

## M2 - On a real phone

- Android export: JDK 17, the Android SDK, the standard (non-.NET) Godot 4.5.1 and its export
  templates, a debug keystore, an Android preset. **The preset's include filter needs `*.json`**
  so `art/*/pivots.json` ships.
- Test by finger: drawing feel, fill speed on a cheap tablet, drag-from-drawer, the back gesture.
- Pinch to turn and resize parts; a settings screen (mic off by default, volume).
- Redraw a part; delete or rehome a pet.
- Sounds, generated like DrawFight's.

## M3 - Voice (optional, off by default)

Record its voice or keep the generated one; pitch by size and mood; call and clap by loudness.

## M4 - Tricks, walks and presents

Trick cards (drawn by the kid, taught by gesture - and used in the Trick Show), walks with
presents ("draw what's inside"), bath and mud, sleeping at night, photo album and journal.

## M5 - Visiting through ecec.dev

Only after the questions in `sharing.md` are answered: parent gate, moderation, share codes,
taking a pet to visit, friendships, bringing gifts home, return visits.

## M6 - iOS

Needs a Mac with Xcode and an Apple developer account.

## Idea backlog

**Stats and training**
- Training gear for a home: a hurdle set, a tug post, a puzzle board - pets practise alone.
- Stat "personal bests" on the pet panel, and a ribbon wall per pet.
- A coach's whistle in the shop: tap it to make every pet in a home do laps (stamina).

**Competitions**
- Grand Prix on the last Sunday: three events back to back.
- Seasonal events: Pumpkin Roll (October), Snowball Throw (December), Egg Hunt (spring).
- A Family Cup where your own pets race each other, just for fun.
- More events per stat: Fetch Frenzy (speed), Log Push (strength), Trampoline Tricks (agility),
  Swim Relay (stamina, finned pets shine), Hide and Seek (smarts), Talent Show (charm).

**Toys** - more words and toys to draw or buy
- Words: "glowy" at night, "magnetic" (sticks to the pet), "bubbly" (blows bubbles),
  "jingly", "boomerang" (comes back by itself), "floaty in water".
- Shop: Boomerang (comes back), Bubble Wand, Kite (windy places), Laser Dot (speed), Yo-yo.

**Furniture and places**
- More kit: a pool, a sandpit, a swing, a hammock tree, a snow fort, a lily pad, a cardboard box
  (every pet loves the box).
- More special places: Pirate Ship, Treehouse Village, Underwater Palace, Dinosaur Valley,
  Haunted House (friendly), Space Station.
- Place effects: low gravity on the Moon, mud in the swamp, wind in the sky.

**Currency and shop**
- Seasonal stock, a weekly "special of the week", sticker book of milestones.
- Paper styles for the drawing sheet: squared, chalkboard, sketchbook.
- Gift a friend a toy to carry on a visit.

**Pets**
- Eggs: two friends' parts recombined into a baby. Growing up: draw it "all grown up".
- A secret favourite scratch spot per pet.
- DrawFight tie-in: pets as the crowd on a DrawFight stage.

## Open questions (current default in brackets)

1. Can a kid delete or rehome a pet, and should a parent confirm? [rehome yes; delete with a
   confirm, framed as "goes to live in the wild"]
2. Profiles for siblings sharing a tablet? [none]
3. Should stars ever be earnable from competitions on past days (catch-up)? [no - come back
   next week]
4. Sharing: parent PIN or email approval; share codes only or a public pool? [share codes,
   see `sharing.md`]
5. Public GitHub repo like DrawFight? [yes - kids' drawings live on the device, never in the
   repo]
