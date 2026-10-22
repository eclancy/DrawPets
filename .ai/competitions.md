# Competitions

The calendar, the six events (one per stat), the cups, and the rule that makes them fair.
Code: `Events`, `CalendarScreen`, `EventScreen`, `CompetitionScreen`, `TrackGame`, `TugGame`,
`TrickGame`, `StyleGame`, `Rivals`.

**Competitions are Advanced mode only** (`pet-life.md`). Beginner has fun days instead - see the
end of this doc.

## The rule

**Every event is the pet's stat plus the kid's timing.** A well-trained pet does well with
clumsy tapping; great tapping can carry a pet a cup above its training. Neither alone wins
the Rainbow Cup. And nothing ever judges a drawing - the Style Show scores charm, the outfit's
words and the poses.

## The calendar

Worked out on the device from the date - nothing synced, no internet - so every week has the
same rhythm and a kid can plan ("Wednesday's Tug-of-War, let's train strength"):

| day | event | stat | how you play |
|---|---|---|---|
| Sun | Fun Fair | any | practise any event (1 star, 3 a day) |
| Mon | Dash Race | speed | tap while the ring's hand is in the green for a burst; stamina holds the pace over the last 40% |
| Tue | Trick Show | smarts | watch the trick cards, tap them back in order; a round longer each time, 5 rounds. The cards are the pet's own: every trick it knows, on the card the kid drew, topped up with the game's cards to four |
| Wed | Tug-of-War Cup | strength | three-round knockout; slide the rope's knot LEFT with the guide ring, let it go back RIGHT, in time with the drum - heave, ease, heave |
| Thu | Style Show | charm | dress to the day's theme word, then tap to pose in the moving spotlight |
| Fri | Hop Hurdles | agility | tap to jump; agility sets how high and how long |
| Sat | Big Marathon | stamina | tap with the drum; on-beat keeps energy up, stamina sets how fast it drains |

## Tug of war: pull, let go, pull (decided)

Eric: "lets switch the game to look more like the kid having to pull their thumb left, then loosen
up to the right, then pull left again in sync with the time." The rope's handle lies across the
sky over the field (`TugGame.PullBar`): a guide ring slides LEFT for the first half of every beat
(the drum booms, a green PULL arrow and "PULL!") and back RIGHT for the second ("let go..."). The
kid's thumb slides the orange knot - anywhere on the screen, one to one - and lifting the thumb
lets the rope pay out, which is letting go too. Pulling left WITH the guide adds up to `HEAVE_K`
to the pet's pull (strength gives 0.8 a point); a thumb a moment behind still counts, since
everyone follows a moving thing a little late (`LAG`). Out of time it adds nothing and costs
nothing, and wiggling back and forth counts no more than one clean pull. A good pull says
"HEAVE!" in green, flashes the knot and makes the pet lean back and growl harder (`Creature.effort`,
a channel every creature has). Round 1 opens by showing it: the hand works the knot for two beats
("Watch!"), the kid tries for two ("Your turn - try it!"), then Ready, GO on a pull. The round is
won when the ribbon itself reaches your (orange) flag; after 20 s of a stuck round the flags walk
in, so every round ends.

## How to play is shown, not told (decided)

Eric: "each game should be clear what to do." Every game shows its move with the same drawn hand
(`HowTo`, `art/ui/ui_point.png`) doing it on the real cue, in time, with a caption of six words
or fewer - the kid may not read. Competitions show it every run while they count down (and two
"Watch!" goes first, the first time ever), it goes at the first touch, and it comes back when the
kid rests while the game waits. Free play and Beginner show it the first three times per activity
(`HowTo.first_times`) and again after about 6 s of nothing. One sentence on screen at a time, and
the hand only ever shows a move that really works.

## Cups

Every event runs four cups. A cup opens once a pet reaches its level **in that event's stat**,
so there is always something to enter and something to train towards.

| cup | opens at | rivals' stat | prize 1st / 2nd / 3rd / 4th |
|---|---|---|---|
| Sprout | level 1 | 8-22 | 12 / 8 / 5 / 2 |
| Star | level 3 | 22-40 | 20 / 12 / 8 / 3 |
| Gold | level 5 | 40-62 | 30 / 18 / 12 / 4 |
| Rainbow | level 7 | 62-86 | 45 / 25 / 15 / 5 |

Full prizes are paid on the **first try at a cup each day**; rematches pay 1 star (3 a day).
Every entry trains the event's stat (3 for a win, 2 otherwise). First place in a Gold Cup or
above wins the **Gold Medal** to wear. Ribbons show on the calendar day.

## Rivals

Eight rival pets, drawn as if by other kids in marker (`art_rivals.gd`): Biscuit the puppy,
Zippy the lizard, Puffles the fluffball, Captain Fins the fish in boots, Duchess the bird,
Rocky the rock monster, Noodle the caterpillar and Mango the cat. They are built by the same
`PetBuilder.add_parts` as a kid's pet, so they move the same way. Three turn up to each cup,
picked by a seed from the date, with stats for that cup - strongest in the event's stat, and
spread out so the field has an easy one, a middling one and a tough one.

Rivals are friendly: they cheer and celebrate, and nothing anyone says is unkind.

## Beginner fun days (built)

In Beginner the same calendar shows a **fun day every day** (`FunDays`, worked out from the date
like the competitions). Nobody is scored, nobody is ranked, and there are no rivals: the rival
pets come as friendly guests and as an audience that cheers for everything. Pick who's coming
(`FunDayScreen`), and off it goes:

| day | fun day | what happens |
|---|---|---|
| Sun | Pet Party | two friendly pets visit its home, dance and say hello; confetti |
| Mon | Treasure Hunt | a walk with three glints to dig up, whatever was found today |
| Tue | Talent Show | on stage, it does the tricks it knows (and a wave and a dance anyone can do); the crowd cheers each one; then a bow (`StageScreen`) |
| Wed | Spa Day | the bath day routine, bubblier, whatever day its bath is |
| Thu | Costume Parade | dress it up from the wardrobe, then down the catwalk, cameras flashing |
| Fri | Dance Party | everyone from its home on stage; tap a move and they all do it |
| Sat | Photo Day | its home with the camera open |

Joining in puts a **rosette** on the calendar - a rainbow one with a heart, no number - and pays
**3 stars once a day**, with a line in the journal.

## Ideas not built yet

- **Grand Prix** on the last Sunday of the month: three events back to back, all stats count.
- **Seasonal events**: a Pumpkin Roll in October, a Snowball Throw in December.
- **Family cup**: the kid's own pets race each other (no prizes - just for fun).
- **Friends' pets as rivals**, once sharing exists (`sharing.md`).
- **Training gear** in the shop (a hurdle set for a home, a tug post) that lets pets practise
  an event's stat on their own.
