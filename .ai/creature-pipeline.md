# Creature pipeline

How a kid's drawings become a creature that moves. Read before touching `DrawCanvas`,
`PartTypes`, `PetBuilder`, `Creature` or `CreaturePart`.

## The flow - in stages (decided)

Only a few things are asked up front; everything else is added while drawing the part it goes
on, so a kid is never asked about horns before there is a head to put them on.

1. **How many heads, arms and legs?** (`PartPickerScreen`, a picture for each). These are the
   MAIN parts. Defaults: one head, no arms, four legs. Zero is fine everywhere.
2. **Draw the body's SHAPE**, facing right - the prompt says so: legs, wings and the rest come
   next. Its add-on buttons: wings, tail, fins, spikes, tentacles, other - plus every face part
   when there is no head.
3. **Draw a head's shape**, then each arm, then each leg (`Creator._next_host`). Each is a HOST
   with its own add-ons (`PartTypes.ADDONS`):
   - head: eyes, mouth, ears, horns, antennae, hair, nose, spikes
   - arm: hand, claws
   - leg: foot, claws
   **Tapping an add-on first asks where it goes** (`DrawScreen.begin_placing`): the kid taps
   their drawing once for each copy - two eyes, one mouth, an ear each side - and taps a ring
   again to take it away. "Draw it!" opens the add-on's sheet zoomed in on the first tap, with
   the host faint on it; the copies go exactly where they were tapped (`layout_on_host`'s
   "spots"; tapped pairs go near-far from left to right). Done (or Back) returns to the host,
   where the add-on now shows in place (`DrawCanvas.set_previews`) and its button shows the
   kid's drawing, how many, and a cross to take it off. Tapping it again moves it and reopens
   its drawing. The host's sheet is kept, not redrawn, while an add-on is drawn.
4. **Eyes and a mouth are required** on the face host (the head, or the body with no head);
   Done says so and wiggles their buttons until they are there.
5. **Every Done shows the part off** (`PartPreview`, about 3 s, tap to carry on): the creature
   so far does what that part does - legs walk, a tail wags, eyes blink, a mouth chomps, wings
   fly, fins swim, springy parts wobble as it hops. It is the real rig and the real recipes, not
   a canned animation; an add-on's preview is a copy of the pet with the host as drawn so far.
   Fixing a pet (redraw, add) shows it off the same way.
6. **Back and Stop, on every drawing step.** Back reopens the step before - its drawing and
   add-ons as they were - and from the body goes back to the parts picker; the drawing being
   left is kept for when the kid comes forward again (`Creator._carry`). The pet is rebuilt from
   the finished hosts each time (`_done_hosts`), so going back is just taking one off. Stop asks
   "Save it for later / Throw it away / Keep drawing". A saved pet is a **draft** in
   `user://draft/` (draft.json plus a PNG per drawing): written at every step, and with the page
   as it is on Save or when the app goes to the background. Starting a new pet offers to finish
   it. Android's back gesture does what Back does, never dropping a half-drawn pet.
7. **Put it together** (`AssembleScreen`) - drag, turn, resize, flip, layer, copy, remove.
   Back reopens the last thing drawn (parts moved here are laid out afresh); Stop as above.
   The steps after it carry a Stop the creator floats top-right (hidden while a favourite
   snack or toy is being drawn).
   Dropping an add-on on a head's, arm's or leg's ink re-hangs it there.
8. Name, size, favourite place; two personality words; favourite food and toy; where it lives.

Each type is drawn **once** per host: the kid gets as many copies as they asked for, and every
copy of a host gets every add-on - four legs drawn once, each with the one foot drawn once.

## Faces turn three-quarters to the right (decided)

Bodies are drawn side-on facing right, and faces are THREE-QUARTER views facing right too - never
straight at the camera (Eric: "we are trying to simulate a right facing angle"). Both eyes show,
set in the right-hand part of the head; the nose sits between them but nearer the far (right)
eye and a little lower, on a muzzle that pokes out to the right; the mouth goes under the nose;
ears, horns and antennae go on either side of the eyes - the near one at the back-left of the
head, the far one at the top right, behind the head and a shade darker. A lone horn goes
between them. These are the default spots
(`PartTypes`: "far" is a positive offset to the right; "body_far" for a face on the body), so a
kid who taps nothing still gets this face, and the ready-made creatures follow it unless they are
drawn in true profile (a long snout or beak, one eye), where the far ear sits just behind the
near one instead. The nose sheet's dot is in the middle: a nose is drawn around it.

## The red dot

Every part sheet has a red **"attach here" dot**, and the prompt says which way to draw from it
("ONE leg hanging DOWN from the red dot"). The dot does three jobs at once:

- **It is the joint.** The part rotates about it. DrawFight's hardest step - placing pivots on
  a photo - does not exist here, because the kid drew the pivot first.
- **It fixes the rest pose.** A leg drawn down from a dot at the top of the sheet hangs down;
  a tail drawn left from a dot on the right points backwards. The motion recipes assume that
  canonical direction, so no rotation-guessing is needed.
- **It is where the part lands on the body.** See the ghost, below.

The kid can move the dot with **Move dot** if they drew somewhere else.

## The ghost

While a part is drawn, the body (or the head, for face parts) shows faintly on the sheet, placed
so the spot the part attaches to sits on the dot, at the sheet's zoom. So the kid draws a leg
**at the right size, already in place** - no resizing afterwards. Eyes, mouths and noses are
drawn on a zoomed sheet (2.5-3x) so a thumb can manage them; they come out at true size.

The bucket treats the ghost as a wall - for a fill that starts OFF the ghost. A leg drawn as an
open outline - the top left open where it meets the body, which is how everyone draws a leg -
fills cleanly and the colour stops at the body. A fill that starts ON the ghost ignores it:
eyes, mouths and noses are drawn on top of the head, whose ghost covers the whole zoomed sheet,
so inside an eye it is the kid's own outline that holds the colour (before this, the bucket did
nothing on those sheets).

## Hosts and add-ons

`PetBuilder.add_parts(pet, type, count, image, pivot, shine, host)` puts `count` copies on EVERY
part of type `host` (`parts_of`), mapping each anchor through that host's own transform - so a
hand lands on the end of each arm wherever the arm is. A far-side host's add-ons are far-side too
(shaded with it). The default host is the type's `host` (face parts fall back to the body when
there is no head). `layout_on_host` is the same layout without a pet, which is how the drawing
sheet previews add-ons on a host still being drawn.

New add-on types: **hand** (rides its arm on a stiff spring), **foot** and **claw** (ride their
leg rigidly). Roster creatures (rivals, adoptables) use the same pipeline (`Roster.assemble`);
a roster part key `claw_on_arm` puts claws on arms instead of legs, and a roster entry's
`layout` overrides where a part goes (anchor, edge, spread, far - `PetBuilder.layout_on_host`),
so the ready-made creatures do not all have their eyes, mouth and head in the same spot. Each
one has its own eyes, mouth and neck too - never one shared eye drawing.

## Auto-layout (`PetBuilder.add_parts`)

Parts start where they most likely go, so "It's alive!" is one tap away if the kid is happy:

- an **anchor** on the reference drawing, as a fraction of its ink box (eye: 2/3 across the head);
- with an **edge** direction, the anchor walks to the last ink that way and tucks 8 px inside -
  legs land on the actual bottom of the body the kid drew, spikes on its actual top;
- **copies fan out** (`spread`) - legs along the belly, eyes side by side;
- **paired types** (legs, arms, wings, ears, horns, tentacles) come in near/far pairs, the far
  one behind and darkened to 74% - the cutout-animation trick DrawFight uses for back limbs. The far copy sits `far` along
  from the near one (ears and antennae need more room than legs, or the two read as one), and
  only far copies are darkened - a tail tucked behind the body is still on the near side;
- tails, spikes, fins and hair tuck **behind** whatever they grow from, so the join never shows.

## Storage

All layout is in **body space**: body-drawing pixels, body centre at (0, 0). Each part stores its
joint's `pos`, `rot`, `scale`, `flip`, `behind`, `parent` (body or head), the sheet `draw_scale`
(1/zoom), and its `pivot` in its own cropped image. That is exactly what the assembly screen
shows. `Creature` converts it to a joint hierarchy at build time - a part dropped on the head's
ink becomes a child of the head and rides along when it nods.

Draw order everywhere is `PetBuilder.draw_order`: a part's behind-children, the part, its
front-children.

## Motion recipes (`CreaturePart.animate`)

One per type. Parts only rotate and squash about their own joint; the drawing is never warped.

| type | motion |
|---|---|
| body | breathes; bobs with each step; squash and stretch when hopping |
| head | idle sway; tilts when curious or petted; nods while eating |
| eye | blinks (squash to 8%) every 1.5-5 s; held shut when petted or asleep |
| mouth | **drawn wide open, shown shut**: squashed to 14% at rest, and opened back up to the kid's drawing to eat (chomp), pant when running, grin when excited, bark when it says something, and yawn before sleep |
| nose | twitches when sniffing |
| leg | swings with the gait; near/far and front/back pairs out of phase (diagonal trot on four) |
| arm | counter-swings; waves when celebrating |
| wing | flaps hard when flying, flutters at rest |
| tail | wags - speed and swing come from happiness |
| fin | paddles, harder when swimming |
| tentacle | slow ripple, offset per copy |
| ear, horn, antenna, hair, spike, other | damped springs that lag behind the body's moves and wobble back; ears droop when sad. Stepped in small fixed steps (1/120 s) and capped, so a long frame on a phone cannot fling them round |

## Parts decide abilities

| has | can |
|---|---|
| legs or tentacles | walk and run |
| neither | hop everywhere (squash and stretch) |
| wings | fly - sometimes for fun, and to catch a toy in the air |
| fins | swim - floats and paddles in water places |
| arms *(planned)* | hold a toy while walking, wave, tug of war |
| mouth *(planned)* | carries in its mouth; without one, a toy is balanced on its head |

## Size

Six sizes: tiny (mouse), small (cat), medium (dog), big (horse), huge (elephant), giant
(dinosaur). Every creature is first normalised (by height, or 0.6x length for long low ones),
then scaled. Size changes stride rate (tiny scurries, giant lumbers), walk speed, the camera
zoom in its place, toy and food scale, and - when voices land - pitch.

## Fixing a pet later

`FixScreen` (see `pet-life.md`) reuses the same pieces - adding a part asks where it goes
first, on the drawing it goes on (`DrawScreen.place_only`), then draws it zoomed in there: `DrawCanvas.load_drawing` starts a sheet
from the existing drawing (undo stops at it), placed so its red dot - its joint - lands on the
sheet's dot, and `PetBuilder.replace_drawing` swaps the drawing for every part using it while
keeping their joints, so nothing moves. Adding uses `add_parts` with an explicit host; a second,
different drawing of a type gets its own file (`unused_file`), never painting over the first.
`remove_drawing` takes a drawing off with everything riding on it, refusing if it would leave no
eyes or no mouth. Saving deletes drawings no longer used.

## Clothes

Clothes are worn like parts (`Wardrobe`): each item says where it goes (head, eyes, neck,
back), Wardrobe finds that place on this pet's own ink - the top of its head, the middle of its
eyes - sizes the item to fit, and stores it in body space hung on the part it sits on, so a hat
nods with its head. Capes and wings hang behind the body. One item per place.

## Shiny strokes

A stroke drawn with a shiny marker is mirrored into a mask (`DrawCanvas`), saved beside the part
as `<type>_shine.png`, and only those pixels shine in the game.

## Not yet

- **Redraw a part** from the pet's page, keeping its layout.
- **Bendy parts**: a `Polygon2D` skinned along a tentacle or long tail, still the kid's
  pixels, so it curls instead of swinging stiffly.
- **Multiple heads** (face parts currently attach to the one head).
- **Pinch to rotate/scale** in assembly, alongside the buttons.
- **Stroke texture**: a crayon-grain brush beside the solid one.
- Flood fill is GDScript; if it is slow on the cheapest tablet, move it to a compute shader or a
  GDExtension before shrinking the sheet.
