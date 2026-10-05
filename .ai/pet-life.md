# Pet life

Everything a pet does once it exists - the Nintendogs half of the game. Read before adding any
need, stat, activity, reaction or reward.

## The Nintendogs mapping

| Nintendogs | DrawPets | status |
|---|---|---|
| pet the dog | rub a pet: hearts, eyes shut, charm and trust | built |
| food bowl | drag a snack out of the Food drawer; the hungriest pet munches it | built |
| ball / frisbee | fling a toy; everyone chases; the fastest brings it back | built |
| rope tug | hold a stretchy toy by a pet's mouth and pull | built |
| toy physics | from the toy's words: bouncy, floaty, rolly, heavy, spinny... | built |
| the room | a home to decorate: furniture drawn or from the kit, used by its words | built |
| accessories | clothes from the shop or drawn, dragged onto a pet | built |
| contests | six events on a weekly calendar, four cups each (`competitions.md`) | built |
| money | gold stars for milestones, a shop of things you cannot draw (`shop.md`) | built |
| shampoo and brush | scrub off mud - overlays only, never touching the drawing | planned |
| teach tricks by voice | trick cards the kid draws | planned |
| call its name | tap the ground (always); optionally call or clap into the mic | tap built, mic planned |
| walks and presents | a walk through its place; presents are "draw what's inside!" prompts | planned |
| Bark Mode | visiting friends' homes through ecec.dev (`sharing.md`) | planned |

## Needs - gentle real time (decided)

Four needs, 0-1: **food, fun, clean, energy**. They drift while the app is closed
(`PetStore.DRIFT_PER_HOUR`) and **never drop below 0.25**. Energy refills while away.

- Low needs show as mood, not damage: slower tail, droopy ears, less bounce.
- A tired pet (energy < 0.45) goes and naps on something **cozy** by itself.
- After 6+ hours away a pet **missed you**: a greeting with hearts - a reward, never guilt.
- **Never:** sickness, fleas, running away, dying, red warnings, guilt notifications.

## Stats (built)

Six stats, 0-100, shown as level 1-10 (`Stats`). Trained by play, with diminishing returns so
early levels come fast and the last ones take real play.

| stat | trained by |
|---|---|
| **Speed** | chasing and fetching, slidey furniture, races |
| **Strength** | tug of war, heavy toys, climbing, scratch posts |
| **Agility** | catching a toy in the air, bouncy/floaty/spinny toys, trampolines, hurdles |
| **Stamina** | chewy toys, splashing, napping, the marathon |
| **Smarts** | puzzle toys, hiding in hidey furniture, the trick show |
| **Charm** | petting, dressing up, dancing to musical things, soft and squeaky toys |

- **Shiny toys train twice as fast.** **Food words boost a stat** for ten minutes (spicy ->
  speed, crunchy and meaty -> strength, fishy -> smarts...); a Star Snack boosts all six.
- **Starting stats** come from the pet's own choices - size (tiny is quick, giant is strong),
  parts (wings -> agility, fins -> stamina, arms -> strength, 3+ eyes -> smarts), personality.
  A head start, never a cap: every stat can reach 100.
- **Slipping, gently**: a stat untrained for 2 days drops 2.5 a day, but **never below 75% of
  its best**, and never below where it started.
- **Speed is visible**: walk and run speed follow the speed stat.

## Trust

Hearts, 0-5, from love (petting, feeding, fetch, tug, competitions). Trust gates more room for
pets (`shop.md`), and each new heart pays stars.

## Describing words (built)

Kids never type a description - they tap words, and the words are what the game reads
(`Words`). A toy drawn as three wobbly lines still bounces exactly the way the kid meant.

- **Toys** (2 words): bouncy, stretchy, floaty, rolly, squeaky, soft, heavy, chewy, puzzly,
  spinny, glowy. Physics and what happens after the fetch both come from them: a soft toy is
  carried to a cozy bed for a nap, a chewy one is chewed, a puzzly one pops out a treat.
- **Food** (2): sweet, crunchy, juicy, spicy, healthy, fishy, meaty, buggy, cold, chewy,
  weird. A pet celebrates its favourite and is happy with anything sharing its words.
- **Furniture** (2): cozy (naps), bouncy (bounces), climbable (perches), hidey (hides),
  splashy (splashes - gets cleaner), shady (rests in it when the place is hot), warm (when it
  is cold), musical (dances), tasty (drops a snack once a day), scratchy, slidey, fancy.
- **Clothes** (2): fancy, cozy, sporty, silly, spooky, cool, warm, brave - Style Show themes.
- **Personality** (2 per pet): playful, sleepy, cuddly, brave, shy, curious, hungry, sporty,
  clever, silly, fancy, calm. Each makes some stats train faster.
- **Places** carry words too (hot, snowy, inside...). A pet loves its favourite place and
  likes places that share its words.

## Favourites are mechanics, not labels

- **Favourite food** always gets a celebration.
- **Favourite toy** is the one it was made with; toys sharing its words are favourites too.
- **Favourite place**: can be any place, even a locked one - a pet that dreams of the Moon is a
  reason to save up for it.

## Microphone - optional (decided)

The mic is **off until turned on** in settings, and every mic feature has a touch equivalent.
Record the creature's own noise (or keep the generated one), played back pitched by size and
mood; call or clap by loudness to make it come over or wake up. No speech recognition.
`RECORD_AUDIO` is asked for only when the mic is switched on. Recordings never leave the device.

## Planned next

1. **Bath and mud**: muddy places splat crayon mud overlays; a sponge scrubs them off.
2. **Trick cards**: the kid draws a symbol; doing the gesture with the card teaches the trick.
3. **Walks and presents**: sparkles hide presents; opening one is a drawing prompt.
4. **Sleep at night** by the device clock, and a pale-lavender night in every place.
5. **Photo mode** and a pet journal.
6. **Voice** (optional, see above).
