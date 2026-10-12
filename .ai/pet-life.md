# Pet life

Everything a pet does once it exists - the Nintendogs half of the game. Read before adding any
need, stat, activity, reaction or reward.

## The Nintendogs mapping

| Nintendogs | DrawPets | status |
|---|---|---|
| pet the dog | rub its head (eyes shut, leans in), its body (wiggles), a belly rub; tap to say hi | built |
| food bowl | drag a snack out of the Food drawer; the hungriest pet munches it | built |
| ball / frisbee | fling it; everyone chases; the catcher brings it back and holds it out | built |
| rope tug | hold a rope out; a pet comes for the other end; pull | built |
| squeaky toys, chew toys, plushies | each toy plays its own way, by its words (below) | built |
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
  spinny, glowy. How it flies AND how it is played with both come from them - see below.
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

## Every toy plays its own way (built)

A toy's words decide what it is for (`Words.toy_play`): the first of stretchy, soft, puzzly,
heavy, (bouncy, rolly, floaty, spinny), chewy, squeaky that it has. Nothing reads the drawing.

| play | words | what the kid does | what the pet does | trains |
|---|---|---|---|---|
| **fetch** | bouncy, rolly, floaty, spinny (or none) | flick it | everyone chases, leaping for it in the air; the catcher brings it back to where it was thrown from and holds it out - take it and throw again. Put down, a pet brings it to you | speed, agility in the air, its words |
| **tug** | stretchy | hold it out | the nearest pet comes for the other end (no need to find its mouth), then pulls back with its strength, shaking its head. Flung, it is fetched and held out end-first: grab it to pull | strength |
| **cuddle** | soft | put it down (on a pet, or near one) | hugs it, eyes shut, hearts - then takes it to bed on something cozy for a nap | charm, stamina |
| **chew** | chewy (and nothing above) | put it down | lies down with it for a long chew. A fetched chewy toy nobody takes is chewed too | stamina |
| **squeak** | squeaky (and nothing above) | put it down, tap it | squeak! every pet looks; the nearest pounces on it and bats it away - tap again. Flung, it is chased and squeaked to bits in the catcher's mouth | agility, charm |
| **puzzle** | puzzly | roll it | noses it along, three goes, until the treat falls out - and eats it | smarts, food |
| **push** | heavy | put it down | goes round behind it and leans in, shoving it along (a rolly one rolls) | strength |

Any toy lying about can be **picked up again** (drag it, or hold a finger on it) and **tapped**
(it hops; a squeaky one squeaks). The starter kit has one of each: ball, flying disc, stick
(fetch), rope (tug), teddy (cuddle), chew bone (chew), squeaky duck (squeak), treat ball
(puzzle), big log (push). A toy coming out of the drawer says once what to do with it.

## Petting (built)

Touch is the whole of it - a finger, or a mouse standing in for one.
- **Rub its head** (its head, or its face if it has no head): eyes shut, head tipped into your
  hand, leaning towards your finger.
- **Rub its body**: a happy wiggle, tail going. **Keep rubbing** - four hearts without lifting
  your finger - and it **rolls over for a belly rub**, legs kicking; belly rubs train charm faster.
  Lift your finger and it rolls back a moment later.
- **Rub fast** and it is a tickle: it giggles.
- **Tap it**: it looks up, hops and says hello, and its card opens (how it is doing, its stats).
- Every so far of rubbing is a heart (trust, charm, a little fun).

## Mud and the bath (built)

Getting muddy is **fun, not a telling-off**. Mud is crayon splats laid **over** the drawing
(`Mud`), riding the part they landed on - the drawing itself is never touched (rule 1). Each
splat lowers the clean need a little (never under the floor).
- **Muddy Swamp**: running about splashes up muddy feet.
- **Digging**: left alone, a pet sometimes digs - nose down, paws going, dirt flying - and comes
  up with muddy paws and a muddy nose. It trains a little strength.
- **Rain**: now and then a shower passes over an outdoor place a little while after you arrive
  (12%, 45-80 seconds); anyone running about in it gets muddy feet.
- What gets on it is the place's: mud, sand on sandy places, dust on rocky ones; nothing under
  the sea, in the clouds or in the snow.

The **Bath** drawer has a **Sponge** ("soapy") and a **Brush** ("fluffy").
- Rub the sponge over a pet: bubbles, and the splat under the sponge comes off. When the last
  one is gone (or after a good long wash of a clean pet) it **shakes itself dry** and glints:
  clean is full, two hearts of trust, a little charm, and **1 star (2 baths a day)**. A wet
  sponge wakes a sleeping pet.
- Brush a pet: pale glints and hearts, like petting - and a sleeper sleeps on.

## Bedtime (built)

At night (`places.md`) pets yawn and curl up asleep - legs folded under, head down, ears droopy -
on a cozy bed or cushion, else on the doorstep of a house or tent, else by something warm, else
where they are. Opening a home at night finds them already asleep ("It's night time - shh!").
- **Tap a sleeping pet** and it wakes gently: a long stretch and a yawn, then hello. It stays up
  for a minute, and for as long as it is fed, played with or petted; then it goes back to bed.
- **Rub a sleeping pet** and it sleeps on - the hearts still come, quietly.
- Food and toys do not wake anyone; the hint says to tap one.
- Sleeping gives energy back. Day naps on cozy things work the same way (a tap wakes them too).
- **Morning** (6-11 am), the first visit of the day to a home: everyone stretches and says good
  morning. Morning coming while the home is open does the same.

## Favourites are mechanics, not labels

- **Favourite food** always gets a celebration.
- **Favourite toy** is the one it was made with; toys sharing its words are favourites too.
- **Favourite place**: can be any place, even a locked one - a pet that dreams of the Moon is a
  reason to save up for it.

## Voices and the microphone (built)

Every pet has a voice the kid makes: a base sound shaped with sliders, or their own recording of
up to 3 seconds - and it talks with small variations every time. See `audio-direction.md`. The mic
is **off until turned on** (Settings, or a yes on first Record), every mic feature has a touch way
round it, no speech recognition, and recordings never leave the device. Still planned: calling or
clapping by loudness to make a pet come over or wake up.

## Fixing and letting go (built)

From the pet panel (tap a pet in its home):
- **Fix** (`FixScreen`): redraw a part starting from the old drawing (draw on it, rub out, or
  clear and start again - it keeps its joints, so it stays where it was), add a part to its body,
  head, arms or legs, take a part off (and everything on it), move parts, and change its name,
  size, place, personality, favourites and voice. Done saves; "Forget changes" leaves the pet as
  it was. A creature always keeps its body, eyes and a mouth.
- **Voice**: straight to the sound maker.
- **Move**: to another home with a free room, or build a new one.
- **Let go** (`LetGoScreen`): the pet goes off "to live in the wild" - gentle, and final. The
  button must be **held for two seconds**, so a stray tap never sends a pet away. It waves, says
  goodbye and wanders off, and its folder is deleted. An adopted pet goes back to the shop.

## Planned next

1. **Trick cards**: the kid draws a symbol; doing the gesture with the card teaches the trick.
2. **Photo mode** and a pet journal.
3. **Voice** (optional, see above).

Walks and presents are built - see `places.md`.
