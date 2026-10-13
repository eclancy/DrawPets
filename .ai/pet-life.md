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
| shampoo and brush | bath day: nails, a wash, teeth, its coat; mud as overlays that wash off | built |
| teach tricks by voice | trick cards the kid draws, taught by swipe | built |
| call its name | tap the ground (always); optionally call or clap into the mic | built |
| walks and presents | a walk through its place; presents are "draw what's inside!" prompts | built |
| dogs that know each other | friendships between pets, by personality and favourites | built |
| Bark Mode | visiting friends' homes through ecec.dev (`sharing.md`) | planned |

## Needs - gentle real time (decided)

Four needs, 0-1: **food, fun, clean, energy**. They drift while the app is closed
(`PetStore.DRIFT_PER_HOUR`) and **never drop below 0.25**. Energy refills while away.

**The rhythm (`Care`):** feed it and play with it **every day** (food and fun run down over about
a day); give it a **bath once a week** (clean runs down over a week, and a bath fills it right
up). In Beginner the pet card shows this as a gentle today list instead of stats: "Fed today -
yum!" / "Hungry? Time for food!", "Played today!" / "Wants to play!", "Bath day in 3 days." /
"It's bath day!".

- Low needs show as mood, not damage: slower tail, droopy ears, less bounce.
- A tired pet (energy < 0.45) goes and naps on something **cozy** by itself.
- After 6+ hours away a pet **missed you**: a greeting with hearts - a reward, never guilt.
- **Never:** sickness, fleas, running away, dying, red warnings, guilt notifications.

## Beginner and Advanced (built)

Asked on first start (`ModeScreen`), switched by a grown-up in Settings (held 1.5 s so a tap
never does it). The point is not to overwhelm kids who are not ready for a busier game, and to
keep competing away from kids who find it hard.

| | Beginner | Advanced |
|---|---|---|
| feeding, play, petting, bath day, mud, walks and presents, night, photos, journal, calling | yes | yes |
| trick cards | yes - every pet learns at the same pace | yes - clever pets learn faster |
| trust hearts, gold stars, the shop, adopting, drawing things | yes | yes |
| the pet card | a "today" list (fed, played, bath day) | the six stats and levels |
| stats | kept quietly, never shown: no level-up toasts, stars or journal lines | shown and trained |
| the calendar | a fun day every day - Pet Party, Treasure Hunt, Talent Show, Spa Day, Costume Parade, Dance Party, Photo Day - no scores, no rivals, a rosette for joining in (`competitions.md`) | competitions with cups and rivals |
| Star Snack (a training boost), "trains twice as fast" in the shop | hidden | yes |

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

**Bath day (once a week).** The Bath drawer's **Bath day!** button sends the pet off - into the
house if its home has one (the bathroom's in there), else to its place's watering hole
(`BathDay.SPOTS`: a pond, a rock pool, a hot spring, an oasis, a crystal pool, a cloud puddle, a
giant shell) - and `BathScreen` runs the routine, one step at a time:
1. **Clip its nails** - only if it has feet, hands or claws (no nails, no clipping).
2. **A wash** - bubbles, the mud comes off; a rinse, and it shakes itself dry.
3. **Brush its teeth** - it says "ahh".
4. **Groom its coat** - brush fur, polish scales, smooth feathers or rub lotion into skin.
Each step's tool works its way over the pet **by itself, slowly**; rub with a finger and the
tool goes where you rub, and faster. The pet shuts its eyes and enjoys it. At the end: clean is
full for the week, two hearts of trust, and **3 stars once a day**. The home says when it is
bath day for someone.

**Its coat** is picked by the kid when making a pet ("What's its coat like?" - fluffy fur, shiny
scales, soft feathers, smooth skin); pets from before have one guessed from their parts (fins: scales, wings: feathers, else fur). The drawing is never read.

The drawer also keeps the **Sponge** ("soapy") and **Brush** ("fluffy") for in-between: the
sponge rubs off mud (and a pet shakes dry, a little cleaner), the brush gives hearts like
petting - and a sleeper sleeps on.

**Food goes in the bowl.** Every home has a food bowl. Tap a snack in the Food drawer (or drop
it near the bowl) and it goes in; the hungriest pet trots over and eats from it, nose down.
Dropped anywhere else, it is picked up and munched as before.

## Trick cards (built)

**Tricks** (under Walk in a home) opens `TrickScreen` for one pet: a stage with the pet on it and
seven cards beside it - **Sit, Jump, Spin, Roll over, Wave, Bow, Dance**.
- Tap a blank card and **draw a symbol on it** - a swirl, a star, anything; it is only a
  picture, and the game never looks at it (rule 4). The card keeps the drawing (`card_<trick>.png`
  in the pet's folder).
- Tap a card to hold it up, then **do its swipe on the stage**: sit = down, jump = up, spin = a
  circle, roll over = sideways, wave = a zigzag, bow = a V, dance = a hill. The swipe to do is
  shown as a moving dotted line. Only the swipe's shape is read (`Tricks.read_swipe`).
- The right swipe teaches it: a quarter more each time, more for a clever pet
  (`Tricks.lesson`: 0.25 + smarts/240), four lessons at most. While it is learning it sometimes
  gets it, sometimes thinks about it. Each lesson trains smarts. The wrong swipe gets a puzzled
  "?" and the right one shown again - never a telling-off.
- Learned: it does the trick every time it is shown the card and the swipe, and **3 stars** the
  first time (once per trick per pet).
- Tricks are motions every creature has (`Creature.do_trick`): sit folds its legs half way,
  roll over goes onto its back and over, bow leans down, wave waves its arms, spin turns round
  and round, jump leaps, dance dances.
- The **Trick Show** is played with the pet's own cards (`competitions.md`).

## Photos and the journal (built)

**Photo** (in a home) turns the drawer bar into a camera: pick a pose - Happy, Jump, Wave,
Dance, Sit, Sleepy - and every pet strikes it; **Snap!** freezes that moment (the place and the
pets, not the buttons). Then `PhotoEditor`: pick a frame (paper, hearts, stars, flowers, rainbow,
snapshot with the date), tap stickers on (heart, star, flower, crown, note, paw, sun, "Hi!") and
drag them about - off the edge takes one away - and **Keep it** or Throw away. Frames and
stickers are crayon drawn in code, never shine.
- Kept photos go in the **album** (`Album`, `AlbumScreen`: from Photo, or the home screen's
  Album button) at 960x540 in `user://photos/`. They are **never saved to the phone's gallery
  and never shared** (`sharing.md`). The oldest go after 120.
- Each pet has a **journal** that writes itself (`Journal`, the pet card's Journal button): the
  day it was drawn or adopted, then its firsts (fetch, tug of war, bath, outfit, walk), presents
  dug up, tricks learned, levels and trust gained, places in competitions - and every photo
  it is in. A front page has its portrait, words, favourites, tricks and trust.

## Bedtime (built)

At night (`places.md`) pets yawn, turn round once to get comfy, and lie down flat on their
tummies - front legs stretched forward, back legs tucked back, head down, ears droopy, eyes shut -
on a cozy bed or cushion, else on the doorstep of a house or tent, else by something warm, else
where they are. Opening a home at night finds them already asleep ("It's night time - shh!").
- **Tap a sleeping pet** and it wakes gently: a long stretch and a yawn, then hello. It stays up
  for a minute, and for as long as it is fed, played with or petted; then it goes back to bed.
- **Rub a sleeping pet** and it sleeps on - the hearts still come, quietly.
- Food and toys do not wake anyone; the hint says to tap one.
- Sleeping gives energy back. Day naps on cozy things work the same way (a tap wakes them too).
- **Morning** (6-11 am), the first visit of the day to a home: everyone stretches and says good
  morning. Morning coming while the home is open does the same.

## Friends (built)

Pets get to know each other, become **friends**, then **best friends** (`Friends`, kept on both
pets in `pet["friends"]`). Never enemies: a pair that does not click just takes longer.

**Who clicks** - only from what the kid chose, never the drawing:
- **Attitude** (personality words): playful likes playful, silly and sporty; sleepy and calm like
  each other and the cuddly; cuddly likes the cuddly, the shy and soft coats (fur, feathers);
  brave looks out for the shy and likes big pets; **shy** likes calm, shy and cuddly pets and is
  *slow* with playful, sporty and silly ones, and with pets much bigger than itself; curious is
  drawn to pets of another kind; hungry pets are snack buddies; fancy likes a pet who dresses up.
- **Interest**: the same favourite place; the same favourite way to play (fetch, tug...); the
  same favourite food words; and a favourite place that points at a kind - a pet that loves wet
  places likes swimmers, one that loves high places likes fliers.
- **Kind**, from its parts: fliers (wings), swimmers (fins), wrigglers (no legs), walkers.
How much A takes to B is one-way (a shy pet can adore a calm one that barely notices); how fast
they become friends is the two averaged (`Friends.fit`, 0.4-2, 1 ordinary).

**Time together** - in a home, now and then an idle pet goes to another, more often one it gets
on with or knows well:
- **Meeting**: a sniff, and a hint saying how it will go - "Zorp met Pip! Pip is shy with playful
  pets - give it time." or "...Both playful - they'll get on!".
- **Nuzzles** (hearts for each level), **chase** for lively friends, **fetch together** (chasing
  the same toy), party guests visiting, and **best friends sleep side by side** at night.
- Friendship grows by how well they fit, at most 22 points a pair a day: getting to know at 15,
  friends at 45, best friends at 80 - a few days for a pair that clicks, longer for one that does
  not. It never shrinks.
- Becoming friends: hearts, a hint, a line in both journals, and **3 stars** (best friends: **5**),
  once per pair. Party guests (the rival pets) can become friends too.

**Where it shows**: the pet card ("Best friends with Pip. Friends with Biscuit."), the journal's
front page with why ("Friends: Pip - both dream of Sunny Meadow."), and the shop's adopt panel
("Would get on with Zorp (both playful)." or "Would take its time making friends with your pets.").

## Favourites are mechanics, not labels

- **Favourite food** always gets a celebration.
- **Favourite toy** is the one it was made with; toys sharing its words are favourites too.
- **Favourite place**: can be any place, even a locked one - a pet that dreams of the Moon is a
  reason to save up for it.

## Voices and the microphone (built)

Every pet has a voice the kid makes: a base sound shaped with sliders, or their own recording of
up to 3 seconds - and it talks with small variations every time. See `audio-direction.md`. The mic
is **off until turned on** (Settings, or a yes on first Record), every mic feature has a touch way
round it, no speech recognition, and recordings never leave the device.

**Calling (built).** A **Listen** button in every home: on, the game listens for a clap or a
shout - **how loud only**, never the words, and nothing is recorded or kept (`Sounds.loudness`
reads a quarter-second rolling buffer). A sound much louder than the room (five times its
usual level, and at least a third of full scale) is a call: every pet looks up and comes
running to the front to say hello (a heart of trust), and a sleeping pet wakes gently first.
Two seconds' rest between calls. Listening is **off until tapped**, stops when the home is
left, and the first time asks "Call your pets?" (the same mic yes as Settings). **Tapping the
ground** does the same without the mic, and a tap wakes a sleeper.

## Its card, and letting go (built)

**A pet's drawings are final once it is made** - there is no going back to redraw, add or take
off parts later (decided: the drawing is the pet). While making it, Back and drafts still let a
kid change a step before they finish.

From the pet panel (tap a pet in its home):
- **Journal**: its journal (see Photos and the journal).
- **Voice**: straight to the sound maker.
- **Move**: to another home with a free room, or build a new one.
- **Let go** (`LetGoScreen`): the pet goes off "to live in the wild" - gentle, and final. The
  button must be **held for two seconds**, so a stray tap never sends a pet away. It waves, says
  goodbye and wanders off, and its folder is deleted. An adopted pet goes back to the shop.

## Planned next

Everything planned for pets is built: walks and presents are in `places.md`; ideas still to come
are in `roadmap.md`.
