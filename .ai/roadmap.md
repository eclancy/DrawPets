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

## M1.6 - Fixing pets, sound (built)

- Fix a pet (redraw from the old drawing, add, take off, move parts, every detail), move it to
  another home, let it go to live in the wild (hold to confirm).
- Sound for everything: 59 generated effects, 14 place ambiences, three music loops, settings.
- Pet voices: 18 base sounds, seven sliders, own recordings (3 s), varied every time it talks.
  Drawn toys can have a sound.

## M1.7 - Toys that play their own way, petting by touch (built)

- Every toy plays the way its words say: fetch (held out for another throw), tug (a pet comes
  for the other end), cuddle, chew, squeak-and-pounce, treat puzzle, push. Toys lying about can
  be picked up again and tapped. A chew bone and a big log join the starter kit.
- Petting: head rubs, body wiggles, belly rubs, tickles, and a tap to say hello (`pet-life.md`).

## M1.8 - Drawing a pet, kinder (built)

- Body and head prompts say "draw the SHAPE"; every add-on asks where it goes first (tap once
  per copy) and its sheet opens zoomed in on the tap.
- Back and Stop on every drawing step; a half-drawn pet saves as a draft and can be finished
  later; Android's back gesture never loses one.
- Faces look at us: nose between the eyes, ears/horns/antennae either side - for kids' pets by
  default, and every ready-made creature checked against it (profile ones kept as profiles).
- Every ready-made creature has its own eyes, mouth and neck; shiny markers last a whole
  drawing and cost 120-150.

## M1.9 - Day and night (built)

The device clock: dusk, a lavender night with a moon, stars and fireflies, glowy lamps and toys,
pets asleep somewhere cozy, a tap to wake one gently, and good morning (`places.md`,
`pet-life.md`).

## M2 - On a real phone - see `android.md`

- Done: JDK 17, the Android SDK, the .NET Godot's Android template (no second editor needed), a
  debug keystore, the Android and Android Demo presets (include filter `*.json, *.f32`), an icon.
  Both export signed APKs.
- Next: a device. Test by finger: drawing feel, fill speed on a cheap tablet, drag-from-drawer,
  scrolling the drawers, the back gesture, petting and toy play.
- Pinch to turn and resize parts.

## M3 - Calling by voice (optional, off by default)

Voices and recordings are built (M1.6). Still to do: call or clap by loudness to make a pet come
over or wake up - always with the tap-the-ground way round it.

## M4 - Tricks, walks and presents

Trick cards (drawn by the kid, taught by gesture - and used in the Trick Show), walks with
presents ("draw what's inside"), bath and mud, photo album and journal.

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

1. ~~Can a kid delete or rehome a pet?~~ Decided and built: Move, and Let go (hold for two
   seconds, "goes to live in the wild"). Should a parent confirm letting go? [no - the hold is
   enough; revisit if a sibling lets someone else's pet go]
2. Profiles for siblings sharing a tablet? [none]
3. Should stars ever be earnable from competitions on past days (catch-up)? [no - come back
   next week]
4. Sharing: parent PIN or email approval; share codes only or a public pool? [share codes,
   see `sharing.md`]
5. Public GitHub repo like DrawFight? [yes - kids' drawings live on the device, never in the
   repo]
