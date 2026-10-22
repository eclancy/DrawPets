# Creature pipeline

How a kid's drawings become a creature that moves. Read before touching `DrawCanvas`,
`CreatureSheet`, `PartCutter`, `PartTypes`, `PetBuilder`, `Creature` or `CreaturePart`.

## The flow - one sheet (decided)

The whole creature is drawn on **one big sheet**, part by part, each part right where it goes
(`CreatureSheet`). Eric: "Drawing pets is confusing ... when they click on wings, it shouldn't
immediately change the UI a whole bunch. It should just let them draw wings and then animate it."
It replaced a staged flow (how many heads/arms/legs, a sheet per host, tap where each add-on goes,
a zoomed sheet per add-on, then an assembly screen), which kids found hard to follow.

1. **The screen never changes shape.** Tools down the left (crayon, bucket, eraser, hand; undo,
   clear; zoom in, zoom out, whole sheet; Stop), the sheet as big as the screen allows
   (`CreatureSheet.SIZE`, 1024 x 896), and on the right the prompt, a button for every part type
   (`PartTypes.SHEET_PARTS`), the crayons and brush sizes, and the Done button.
2. **Tap a part, draw it in place.** Tapping Wings lights that button, the prompt says what to
   draw ("Draw its WINGS, touching the body..." - `PartTypes.DRAW`) and Done reads "Done with the
   wings". Nothing else moves. The rest of the creature shows around it, a little faint
   (`OTHERS_ALPHA`), stacked as the creature will be - the tail behind the body, the face on the
   head - so it is clear which lines are this part's; the eraser and undo only touch them.
3. **Done with a part shows it off** (`PartPreview`, about 3 s, tap to carry on): wings flap,
   legs walk, eyes blink - the real rig and the real recipes. Then straight back to the sheet,
   with the next suggested part (`PartTypes.SUGGESTED`: body, head, eyes, mouth, legs) already
   picked and gently glowing, and a tick on every part drawn. Tapping another part instead of
   Done puts this one down without the show.
4. **Any part can be picked again** and its lines come back to draw on and rub out
   (`DrawCanvas.load_drawing`; undo stops there).
5. **The body comes first** - the other buttons are faded until there is one, and say so.
   **"It's finished!"** appears once there is a body, eyes and a mouth (`PartTypes.NEEDED`) and
   goes on to the name, size and favourite place; personality; coat; voice; favourite food and
   toy; where it lives. Those steps carry a Stop the creator floats top-right (hidden while a
   favourite snack or toy is being drawn).
6. **Zoom** for small things: pinch or the wheel, or the buttons; two fingers, the hand tool or a
   right-drag slide the sheet about. A pinch that starts with a finger already drawing takes that
   stroke back, and the bucket pours when the finger lifts, so zooming never leaves marks.
7. **Stop** asks "Save it for later / Throw it away / Keep drawing". A saved pet is a **draft**
   in `user://draft/` (draft.json plus a PNG per part layer, `layer_<type>.png`), written each
   time a part is put down - only the layers that changed - and with the page as it is on Save or
   when the app goes to the background. Starting a new pet offers to finish it. A version 1
   draft (the staged flow) carries its body over, in the middle of the sheet. Android's back
   gesture skips a part's show, closes the Stop box, or asks to stop - never dropping a pet.

Every part TYPE is its own layer. **They draw each one** (decided): two eyes drawn are two eyes,
four legs drawn are four legs. A single wing, ear, horn, antenna, leg, arm or tentacle still gets
a matching one behind it (below).

## Cutting the creature into parts (`PartCutter`)

When a part is done (and when the creature is finished) the layers are cut into parts. Nothing
is redrawn: every part is exactly the kid's pixels, cut out.

- **Pieces.** A layer's separate blobs of ink are separate parts. Ink within `GROUP_GAP` (6 px)
  is one piece, and blobs whose boxes overlap are one piece - a pupil inside its eye, a highlight
  drawn just beside it. Specks under `SPECK` pixels are dropped. Each layer's pieces are cached
  until it changes, so a Done only cuts the layer just drawn.
- **Hosts.** The body carries everything; a head carries the face parts drawn on it (the body
  does, with no head); an arm carries hands; a leg (or an arm) carries feet and claws. A piece
  goes on the allowed host its ink overlaps most - a head over the body for an eye on both.
- **Joints.** Eyes, mouths and noses blink, open and twitch about their middle. Everything else
  hangs from where it touches its host: the middle of the ink they share - a leg swings from
  where it meets the body, an ear wobbles from its base. A piece touching nothing hangs from its
  point nearest the nearest host.
- **The rest pose is the drawing.** A leg drawn hanging down hangs down, a tail drawn out to the
  left points back - the motion recipes swing about that.
- **Twins.** A paired type drawn just once gets a far-side copy: behind, darkened, moved `far`
  along the host (the other way if that is off the host), and walked onto the host's outline the
  way the part grows (`edge`) - so a far ear sits on the head, not in the air. What rides on it
  comes too: a lone arm's twin has a copy of its hand.
- **Behind.** Tails, spikes and fins tuck behind what they grow from (`PartCutter.BEHIND`); the
  sheet shows them behind as they are drawn. Hair drawn in place is drawn ON the head, so it
  stays in front.
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
