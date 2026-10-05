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

- A family starts with **2 plots** and **2 rooms** a home. More of both from the shop, gated on
  trust (`shop.md`).
- A new pet chooses where to live (`HomePickerScreen`): a home with a free room, or a new home on
  a free plot in any unlocked place. Each choice says how the pet feels about it (loves it /
  likes it / it's ok) from the place words.
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

## The camera

Zooms by the biggest pet in the home: a home of tiny pets gets a 1.5x close-up that follows
them, a giant one a 0.66x wide shot. The walking band stops above the drawer bar.

## Planned

- **Visiting**: friends' homes, through ecec.dev (`sharing.md`).
- **Outings**: take a pet to one of your other homes for the afternoon.
- **Time and seasons** from the device clock: lavender nights, snow in December.
- **Place effects**: the Moon's low gravity (higher hops, floating toys), mud in the swamp,
  a bubble helmet for non-swimmers under the sea.
