# DrawPets

Draw a creature. Bring it to life. Look after it.

Kids pick what their creature has - a head, eyes, legs, wings, a tail, tentacles, anything - and
draw each part on its own sheet, starting from a red dot that marks where it joins on. They
drag the parts onto the body, and it comes alive: legs step, tails wag, eyes blink, wings flap.
Then they name it, pick its size and the place it loves to live, and draw its favourite food
and toy. And then they look after it like a real pet: pet it, feed it, throw its toy,
and visit it in its favourite place.

Pets live together in homes the kid decorates - with furniture they draw or pick from a
starter kit - and everything is described with preset words that decide how it plays: a
"bouncy" ball is fetched and held out for another throw, a "stretchy" rope is for tug of war, a
"soft" teddy gets a cuddle, a "squeaky" duck gets pounced on, a "cozy" bed is where they nap.
Rub a pet's head and it leans into your finger; keep rubbing its tummy and it rolls over for a
belly rub. Playing trains six stats,
milestones earn gold stars for a shop of shiny toys, clothes, special places and room for more
pets, and a weekly calendar of competitions - one per stat - pits them against eight rival pets.

No photos, no AI. Every pixel of every pet is one a kid drew; every other picture in the game is
a drawing too, in coloured pencil or marker.

A sibling of [DrawFight](https://github.com/eclancy/DrawFight).

## Running it

Godot 4.5 (GDScript, no .NET needed).

```
godot --path .
```

`godot --path . -- --demo --quit` has a scripted kid draw a creature, play with it, decorate,
shop and enter every competition, screenshotting every step into `.shots/`.

The game's own art is drawing code in `scripts/art_*.gd`, baked to `art/` with
`godot --path . -s tools/bake_art.gd -- --group=things` (or any other `art_<group>.gd`).
Every sound, ambience and music loop is generated too: `python tools/audio/build.py --all`.

## Where things are

- `scripts/` - all the code. Start at `game_root.gd`.
- `.ai/` - the design docs: what the game is, how drawings become creatures, how pets live.
- `CLAUDE.md` - working notes for coding agents.

Pets are saved on the device only, under Godot's user data folder. Kids' drawings are never
part of this repo.
