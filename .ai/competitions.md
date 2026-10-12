# Competitions

The calendar, the six events (one per stat), the cups, and the rule that makes them fair.
Code: `Events`, `CalendarScreen`, `EventScreen`, `CompetitionScreen`, `TrackGame`, `TugGame`,
`TrickGame`, `StyleGame`, `Rivals`.

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
| Wed | Tug-of-War Cup | strength | three-round knockout; tap HEAVE! when the ring is biggest |
| Thu | Style Show | charm | dress to the day's theme word, then tap to pose in the moving spotlight |
| Fri | Hop Hurdles | agility | tap to jump; agility sets how high and how long |
| Sat | Big Marathon | stamina | tap with the drum; on-beat keeps energy up, stamina sets how fast it drains |

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

## Ideas not built yet

- **Grand Prix** on the last Sunday of the month: three events back to back, all stats count.
- **Seasonal events**: a Pumpkin Roll in October, a Snowball Throw in December.
- **Family cup**: the kid's own pets race each other (no prizes - just for fun).
- **Friends' pets as rivals**, once sharing exists (`sharing.md`).
- **Training gear** in the shop (a hurdle set for a home, a tug post) that lets pets practise
  an event's stat on their own.
