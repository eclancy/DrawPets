# Creature pipeline

How a kid's drawings become a creature that moves. Read before touching `DrawCanvas`,
`CreatureSheet`, `PartCutter`, `PartTypes`, `PetBuilder`, `Creature` or `CreaturePart`.

## The flow - one sheet, guided by a plan (decided)

The whole creature is drawn on **one big sheet**, part by part, each part right where it goes
(`CreatureSheet`). Eric: "Drawing pets is confusing ... when they click on wings, it shouldn't
immediately change the UI a whole bunch. It should just let them draw wings and then animate it."
It replaced a staged flow (how many heads/arms/legs, a sheet per host, tap where each add-on goes,
a zoomed sheet per add-on, then an assembly screen), which kids found hard to follow.

**Guided** (decided, 2026-10-23 - Eric: "a guided procedure again, where they select how many
heads / eyes / arms etc ahead of time and then we guide them through the process, then we ask
them if they want to add any other specific parts after, like tentacles"). The counting is back,
the separate sheets are not:

- **First, "What will your pet have?"** (`PartPlanner`, "start"): heads, eyes, ears, arms, legs
  and tails, each a picture with - and + (`PartTypes.PLAN_ASK`: fewest, most, start - set to a
  cat or a dog: 1, 2, 2, 0, 4, 1; eyes at least one). The body and a mouth come with every pet.
  That makes the **plan**: [[type, how many], ...] in `PartTypes.GUIDE_ORDER` (body, head, eyes,
  mouth, nose, ears, horns, antennae, hair, arms, hands, legs, feet, claws, tail, wings, fins,
  spikes, tentacles, other - what a part grows from before the part).
- **The sheet asks for each in turn**: the first part in the plan with fewer drawn than planned.
  "Draw a LEG, coming down from the body. It walks!", then "LEG 2 of 4! Draw it - or copy the
  last one." (`PartTypes.DRAW_NEXT`) on a fresh page, with Copy bouncing. **Drawn is counted in
  pieces** (`CreatureSheet.count_of`, PartCutter's own pieces), so four legs drawn in one go are
  four and the sheet moves on; spikes, hair and claws are a bunch (`PartTypes.BUNCH`) - any is
  enough.
- **"Anything else?"** (`PartPlanner`, "more", over the sheet) appears when the plan is all
  drawn: every part not in the plan yet, a picture to tap (it comes in at its usual number -
  `MORE_START`: a pair of wings, a hand for each arm, a foot for each leg) and - +; bunches are
  yes or no. "Draw them!" adds them to the plan and the sheet asks for them; "No - it's
  finished!" goes on to its name; "Back to drawing" closes it. **Add more**, at the end of the
  plan's parts, opens it any time. It is not asked again when the kid only went back to fix a
  part that was already drawn.

1. **The screen never changes shape**, and **everything is big enough for a small finger on a
   phone** (Eric: "buttons need to be bigger and more legible, and the directions for what
   you're currently drawing should be more obvious" - on a phone the whole 720-unit-tall screen
   is about 7 cm, so an 11 px word is a millimetre high). Tools down the left, two to a row
   (`TOOL_SIZE` 84 x 76), each with its word under it (Crayon, Paint, Eraser, Move; Undo, Clear;
   Zoom in, Zoom out, See all - a kid asked what the crumpled page and the hand were), the brush
   sizes under them, and Stop. **Across the top of the sheet, a banner says what to draw now**,
   lit like the part's tile: the part's picture, "Draw a LEG" (or "LEG 2 of 4") big, and a line
   beside it - how ("Coming down from the body. It walks!"), or anything the game has to say, in
   red ("That's its BODY!"); it bounces when the part changes. Under it the sheet, as big as the
   room left allows (`CreatureSheet.SIZE`, 1024 x 896). On the right (`SIDE_W` 420): **the plan's
   parts** (a tile for each kind, as wide as fits in three rows, a dot for each one - filled once
   drawn - a tick when they are all drawn, the one being drawn lit; tap one to go back to it; Add
   more), a row for the part being drawn (below), the crayons, and the Done button. The plan's
   parts keep the room of three rows, so nothing below them moves. The drawing screen for food,
   toys and the rest (`DrawScreen`) has the same big tools with their words.
2. **Draw it in place.** The prompt says what to draw (`PartTypes.DRAW`, one of it; "on its
   body" when there is no head) and **Done says what it will do**: "Next leg" while there are
   more to draw, "Done with the legs" on the last, and on an empty page "No more legs" (the plan
   comes down to the ones drawn) or "Skip the tail" - never for the body, eyes or a mouth, which
   every creature needs. The rest of the creature shows around it, a little faint
   (`OTHERS_ALPHA`), stacked exactly as the creature will be, so it is clear which lines are the
   bold drawing's; the crayon, eraser and undo only touch them.
3. **Copy, In front / Behind** (decided - Eric: "we should have an explicit 'duplicate leg'
   button next to a 'draw next leg' button ... any part has an explicit way to duplicate ...
   they should be able to select for each part whether it goes in front of or behind the body /
   head / other parts"). Under the parts, for any part but the body (the plan's Next leg is the
   "draw next leg"):
   - **Copy the last leg** (on the fresh page for the next one) or **Copy this leg** puts a copy
     just beside it - the next leg - bold, with a dashed line round it, and the prompt says "Drag
     it where it goes!": a crayon or hand press on the copy's ink slides it (relative, any zoom;
     it only ever lands on whole pixels, so its lines are never softened), until the kid draws
     somewhere else or picks another tool. The page slides to show it if it landed out of view.
     The drawn hand shows the slide the first three times (`HowTo`). Copying past the plan's
     number adds to it.
   - **In front | Behind**: two halves, the side it is on now lit - tap the one you want. Their
     pictures are the part with what it grows from (the head for an ear). The bold drawing goes
     to the front or back of the stack, and the sheet shows it there at once; while it is behind
     something, that something is nearly solid on the sheet, as on the creature. Tails, spikes
     and fins start behind (`PartCutter.BEHIND`), everything else in front; eyes, mouths and
     noses have no switch (behind, they would vanish).
   Copy is faded (and says "Draw one first!") until there is something to copy, and bounces when
   a fresh page for the next one opens.
   Nothing is ever copied or joined behind the kid's back: the old automatic far-side twin of a
   single wing, ear or leg is gone (it turned four touching legs into eight). A copy is a button
   they pressed.
4. **The last of a part shows it off** (`PartPreview`, about 3 s, tap to carry on): wings flap,
   legs walk, eyes blink - the real rig and the real recipes - with a picture of the part for
   each one found (four leg pictures for four legs), so a kid who cannot read can count them.
   Then straight back to the sheet with the next part in the plan (its tile bounces once).
   Tapping another part instead of Done puts this one down without the show.
5. **Any drawing can be fixed.** Picking a part reopens its last drawing. The bucket tapped inside
   another drawing of the same part, the eraser put on one, or the crayon put on or inside one
   once the bold drawing has something on it, makes that one the bold one and carries on there -
   stripes on the first leg go on the first leg, never into a new loose "leg". The bucket or the
   eraser on another part's drawing says "That's its BODY! Tap Body first, then colour it." Undo
   takes back strokes, and once a new drawing or copy has nothing left, the new drawing itself.
   The plan - with a part skipped staying skipped - lasts through Back to drawing and a saved
   draft; a draft keeps the name, size and place too.
6. **The body comes first** - the other tiles are faded until there is one, and say so.
   **"It's finished!"** appears once there is a body, eyes and a mouth (`PartTypes.NEEDED`) - so
   a kid can stop before the plan is done - and goes on to the name, size and favourite place
   (missing eyes or a mouth: the sheet opens on them instead). There **Back to drawing** goes back
   to the sheet, all still there - then personality; coat; voice; favourite food and toy; where
   it lives. Those steps carry a Stop the creator floats top-right (hidden while a
   favourite snack or toy is being drawn).
7. **Zoom** for small things: pinch or the wheel, or the buttons; two fingers, the hand tool or a
   right-drag slide the sheet about. A pinch that starts with a finger already drawing takes that
   stroke back, and the bucket pours when the finger lifts, so zooming never leaves marks.
8. **Stop** asks "Save it for later / Throw it away / Keep drawing" (and, held by a grown-up,
   "report a bug"). A saved pet is a **draft** in `user://draft/` (version 3: draft.json, with
   the plan and each drawing's place and stacking, plus a PNG per drawing,
   `layer_<type>_<n>.png`; a draft from before plans gets a cat-or-dog one), written
   each time a drawing is put down - only the ones that changed - and with the page as it is on
   Save or when the app goes to the background. Starting a new pet offers to finish it. A
   version 2 draft (a picture per part) becomes one drawing per part; a version 1 draft (the
   staged flow) carries its body over, in the middle of the sheet. Android's back
   gesture skips a part's show, closes the Stop box, or asks to stop - never dropping a pet.

Every part the kid draws is its own **drawing**: `CreatureSheet.layers` is type -> [{image
(cropped to its ink), at, shine, behind, z}], in the order drawn. **They draw each one**
(decided): two eyes drawn are two eyes, four legs four legs - one at a time, copied, or all in
one go.

## Cutting the creature into parts (`PartCutter`)

When a part is done (and when the creature is finished) the drawings are cut into parts. Nothing
is redrawn: every part is exactly the kid's pixels, cut out.

- **Pieces.** A drawing's separate blobs of ink are separate parts, so four legs drawn in one go
  still walk. Ink about 12 px apart or less (`GROUP_GAP` grows each blob 6 px) is one piece, and
  so is a blob mostly inside another's box (half its box or more) - a pupil, an eye's highlight,
  a wing's feathers; merely overlapping boxes are not, so four slanted legs stay four. Two
  drawings are never one piece. Specks under `SPECK` pixels are dropped. Each drawing's pieces
  are cached (by its image) until it changes, so a Done only cuts the drawing just made.
- **Hosts.** The body carries everything; a head carries the face parts drawn on it (the body
  does, with no head); an arm carries hands; a leg (or an arm) carries feet and claws. A piece
  goes on the allowed host its ink overlaps most - a head over the body for an eye on both.
- **Joints.** Eyes, mouths and noses blink, open and twitch about their middle. Everything else
  hangs from where it touches its host: the middle of the ink they share - a leg swings from
  where it meets the body, an ear wobbles from its base. A piece touching nothing hangs from its
  point nearest the nearest host.
- **The rest pose is the drawing.** A leg drawn hanging down hangs down, a tail drawn out to the
  left points back - the motion recipes swing about that.
- **Gait.** A type's pieces are numbered left to right across all its drawings, so legs drawn
  one by one still take turns as they walk.
- **In front or behind.** Each part goes in front of its host or behind it, as the kid chose for
  its drawing (`behind`; tails, spikes and fins start behind), and among the parts on the same
  host the later-stacked one is in front (`z`) - which Creature's joint tree can show exactly, so
  the sheet (`CreatureSheet._stacked`) shows the same stack.
- **No twins.** Nothing is added that the kid did not draw or copy. (Ready-made creatures still
  get their far-side copies from `PetBuilder.add_parts`; saved pets keep theirs.)
- **The bucket only sees the part being drawn** (Eric: "the paint bucket should treat the wing as
  its own layer"). A wing drawn over the body fills right across the body's outline under it,
  the way the kid sees it.
- **The bucket closes open shapes.** A tap that would colour the whole page - inside a C, a leg
  drawn as a U, between two lines - closes the shape it is in with a straight edge across its
  opening and fills inside that, as if the kid had drawn the edge (`DrawCanvas.close_around`:
  look out from the tap every way, take the lines met nearest, and close their convex hull). A
  tap beside a single line, or on empty paper, still says "Tap INSIDE something you drew".

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

## Ready-made creatures: hosts and add-ons

Rivals and adoptables are still built the older way, from a drawing per part
(`Roster.assemble`): `PetBuilder.add_parts(pet, type, count, image, pivot, shine, host)` puts
`count` copies on EVERY part of type `host` (`parts_of`), mapping each anchor through that host's
own transform - so a hand lands on the end of each arm wherever the arm is. A far-side host's
add-ons are far-side too. A part's `pivot` there is the red dot it was drawn from (`PartTypes`
"dot", on a 512 px sheet zoomed by "zoom"), which is its joint and fixes its rest direction. A
roster part key `claw_on_arm` puts claws on arms instead of legs, and a roster entry's `layout`
overrides where a part goes (anchor, edge, spread, far - `PetBuilder.layout_on_host`), so the
ready-made creatures do not all have their eyes, mouth and head in the same spot. Each one has
its own eyes, mouth and neck too - never one shared eye drawing.

## Auto-layout (`PetBuilder.add_parts`)

For ready-made creatures, parts go where they most likely would:

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
joint's `pos`, `rot`, `scale`, `flip`, `behind`, `parent` (the part it rides on), `draw_scale`
(1 for a part drawn in place; 1/zoom for a ready-made one drawn on a zoomed sheet), and its
`pivot` in its own cropped image. A kid's pet at rest is exactly the sheet they drew. `Creature`
converts it to a joint hierarchy at build time - an eye on the head rides along when it nods.

Creature hangs every part on the part it rides on, in the order of `pet["parts"]`: a part's
behind-children, the part, its front-children (`PetBuilder.draw_order` gives the same order). A kid's
pet lists its parts host-first, then by each drawing's place in the sheet's stack (`z`), so the
creature stacks exactly as the sheet showed it (`CreatureSheet.stack_of`).

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

## Once it is made

A pet's drawings are final once it is finished - there is no redrawing, adding or taking off
parts later (`pet-life.md`). While it is being made, picking a part again (or a draft) reopens
its layer with `DrawCanvas.load_drawing`, which starts from the drawing as it was (undo stops
at it).

## Clothes

Clothes are worn like parts (`Wardrobe`): each item says where it goes (head, eyes, neck,
back), Wardrobe finds that place on this pet's own ink - the top of its head, the middle of its
eyes - sizes the item to fit, and stores it in body space hung on the part it sits on, so a hat
nods with its head. Capes and wings hang behind the body. One item per place.

## Shiny strokes

A stroke drawn with a shiny marker is mirrored into a mask (`DrawCanvas`), cut out with its part
(`PartCutter`), saved beside the part as `<type>_shine.png`, and only those pixels shine in the
game.

## Not yet

- **Redraw a part** from the pet's page, keeping its layout.
- **Bendy parts**: a `Polygon2D` skinned along a tentacle or long tail, still the kid's
  pixels, so it curls instead of swinging stiffly.
- **Faster cutting** on the cheapest tablets: `PartCutter.pieces` is GDScript (0.1-0.3 s a
  layer on a PC); a slow phone may want it in a GDExtension.
- **Stroke texture**: a crayon-grain brush beside the solid one.
- Flood fill is GDScript; if it is slow on the cheapest tablet, move it to a compute shader or a
  GDExtension before shrinking the sheet.
