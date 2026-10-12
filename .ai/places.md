# Places and homes

The fourteen places, how homes work, and decorating. Code: `Places`, `PlacePainter`,
`PlaceScreen`, `Furniture`, `Profile` (homes).

## Places

| id | name | words | |
|---|---|---|---|
| meadow | Sunny Meadow | outside, warm, grassy | |
| forest | Deep Forest | outside, cool, grassy | |
| beach | Sandy Beach | outside, hot, sandy, wet | |
| ocean | Under the Sea | wet, cool, sandy | finned pets swim |
| mountains | Snowy Mountains | outside, cold, snowy, high | |
| desert | Dusty Desert | outside, hot, dry, sandy | |
| jungle | Jungle | outside, hot, wet, grassy | |
| cave | Crystal Cave | inside, cool, rocky, sparkly | lavender, never black |
| volcano | Volcano | outside, hot, rocky | |
| swamp | Muddy Swamp | outside, warm, wet, muddy | |
| sky | Cloud Kingdom | outside, cool, high | **shop, 90** |
| moon | The Moon | cold, rocky, bouncy | **shop, 120** |
| castle | Castle | outside, fancy, grassy | **shop, 150** |
| candy | Candy Land | outside, sweet, warm | **shop, 100** |

A place is **data** (`Places.DATA`): sky colours, a far layer (hills, sea, dunes, clouds,
stalactites, craters, battlements), ground, a drift (snow, bubbles, petals, sprinkles...), and
props `[kind, x, y, scale]`. `PlacePainter` is the only renderer. New place = new data; new
kind of thing in a place = new prop. Never per-place drawing code.

## Homes (built)

A **home** is a place a family has built on one of its plots: `{id, place, rooms, pets, items}`
in `Profile`. Pets live in homes, several to a home, and visiting a home shows all of them.

- A family starts with **2 empty plots**, each home with **2 rooms**. More of both from the
  shop, gated on trust (`shop.md`).
- **Building a home** (`BuildHomeScreen`, from an empty plot on the home screen, or while a new
  pet chooses where to live): pick one of fourteen **ready-built homes** (`Homes.PREMADE`) - one
  for each place, each a house plus a few things already set out (a Meadow Cottage with a
  mailbox and flowers, an Igloo with a snowman and a campfire, a Moon Base with a flag) - then
  **name it**. Homes in special places are locked until the place is bought.
- An empty plot never starts a new pet; it only builds a home.
- A new or adopted pet chooses where to live (`HomePickerScreen`): a home with a free room, or
  build one on a free plot. Each home says how the pet feels about it (loves it / likes it /
  it's ok) from the place words.
- Special places must be bought before a home can be built there - but any place can be a
  favourite.

## Decorating (built)

The **Decorate** drawer holds furniture: the free starter kit (22 things), shop furniture, and
anything the kid draws. Drag it in, drag it about, tap it for Bigger / Smaller / Flip / Put
away, drag it back to the drawer to remove it. Saved with the home.

Pets use furniture **by its words** when left alone (`PlaceScreen._play_with_furniture`): nap on
cozy things when tired, bounce on bouncy ones, perch on climbable ones, hide in hidey ones,
splash in splashy ones, dance to musical ones, shelter under shady things when the place is
hot and by warm things when it is cold. Tasty things drop a snack once a day. Each activity
trains a stat.

## Day and night (built)

The device clock sets the look (`Clock`) - there is no switch. Day; a warm pink-orange dusk from
7 pm; a **pale-lavender night** from about 8:30 pm to 6 am, never dark (`art-direction.md`); a
dawn till 7:30. At night outside places get crayon stars and a crescent moon (where the sun was,
kept clear of the buttons) and summery places get fireflies instead of petals or leaves.

The land and the things in it are multiplied by a lavender tint (`Clock.tint`); the sky is its
own layer (`PlacePainter.SkyLayer`) so the moon and stars stay bright; **creatures are never
tinted** - the kid's drawing wins every frame. Anything **glowy** (a word, for furniture and toys)
lights up instead: untinted, with a soft pencil glow round it and a pool of light on the ground.
The kit lamp, campfire, lantern, crystal lamp and candy lamp are glowy.

`--hour=21.5` pretends it is that time, to see it; the demo forces midday, then has a night turn.

## Bath spots (built)

Bath day (`pet-life.md`) happens in the bathroom if the home has a house, else at the place's
own watering hole (`BathDay.SPOTS`): a pond in the meadow, forest, jungle, swamp and Candy Land,
a rock pool at the beach, a hot spring in the mountains and the volcano, an oasis in the desert,
a crystal pool in the cave, a cloud puddle in the sky, a giant shell under the sea, and a tub on
the Moon and in the Castle. Drawn by `BathScreen.BathPainter` in two layers, so the pet stands
in the water.

## Walks (built)

**Walk** (under Home in a home) takes one pet - the one whose card is open, else the one the home
is looking at - out along its home's place (`WalkScreen`). The place goes on for six screens,
each a tile of the same place with its hills running on from the last (`PlacePainter.tile`), one
sun at the start. The pet trots ahead by itself; tap ahead and it runs there, tap behind and it
turns back. Every 700 px walked trains stamina; the walk ends at the far end ("What a walk!") or
with Home. A walk is good fun (+fun) and a little tiring.

**Presents.** Glints in the grass (pale pencil twinkles, not shine) hide presents - as many as
are left today, two a walk at most, **three a day**. Near one the pet stops, sniffs, digs (muddy
paws) and up pops a present. Tap it: **"What's inside the present? Draw it! It's a CRUNCHY
snack."** - a toy (most often), a snack or a thing for its home, one word for it, that word
already picked on the words page. Drawing it makes it a real item in the drawers, and pays **1
star** (`GameRoot.present_drawn`). Backing out of the drawing loses the present.

## The camera

Zooms by the biggest pet in the home: a home of tiny pets gets a 1.5x close-up that follows
them, a giant one a 0.66x wide shot. The walking band stops above the drawer bar.

## Planned

- **Visiting**: friends' homes, through ecec.dev (`sharing.md`).
- **Outings**: take a pet to one of your other homes for the afternoon.
- **Seasons** from the device clock: snow in December, leaves in October.
- **Place effects**: the Moon's low gravity (higher hops, floating toys), a bubble helmet for
  non-swimmers under the sea. (Mud in the swamp, and passing showers of rain, are built - see
  `pet-life.md`.)
