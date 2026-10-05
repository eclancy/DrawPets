# Creature pipeline

How a kid's drawings become a creature that moves. Read before touching `DrawCanvas`,
`PartTypes`, `PetBuilder`, `Creature` or `CreaturePart`.

## The flow

1. **Pick parts** (`PartPickerScreen`) - a count for each type. Body is always one; **eyes
   and a mouth are required** (at least one of each) - eyes blink and mouths open, and a pet
   that can do neither has no face to react with.
2. **Draw the body** - big, facing right, no dot.
3. **Draw one of each part type** (`DrawScreen` + `DrawCanvas`), each on its own 512 px sheet.
4. **Put it together** (`AssembleScreen`) - drag, turn, resize, flip, layer, copy, remove.
5. Name, size, favourite place; two personality words; favourite food and toy (picked from
   what the family has, or drawn and described with words); where it will live.

Each part type is drawn **once**; the kid gets as many copies as they picked. Four legs is one
leg drawing used four times, the far two darker.

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

The bucket treats the ghost as a wall. A leg drawn as an open outline - the top left open where
it meets the body, which is how everyone draws a leg - fills cleanly and the colour stops at the
body.

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
| ear, horn, antenna, hair, spike, other | damped springs that lag behind the body's moves and wobble back; ears droop when sad |

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
