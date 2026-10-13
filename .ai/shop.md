# Gold stars, the shop, and room to grow

How a kid earns, what they spend on, and why the family grows only as fast as the pets' trust.
Read before adding any reward, price or shop item. Code: `Profile`, `ShopScreen`, `Items.SHOP`,
`GameRoot.reward`.

## Gold stars

The currency is **gold stars** - the sticker a teacher puts on good work. Every star comes
with a toast that says what it was for; a kid should always know what they did to earn one.

| milestone | stars | limit |
|---|---|---|
| first visit to a home each day | 3 | once a day per home |
| a new pet moves in | 10 first pet, then 5 | - |
| feeding | 1 | first 3 a day |
| its favourite food | 2 | once a day |
| every 5th fetch | 2 | up to 25 fetches a day |
| winning tug of war at home | 1 | 5 a day |
| playing with a toy its own way (a cuddle, a chew, a pounce, a treat out, a push) | 1 | 5 a day, all together |
| drawing something new (toy, food, furniture, clothes) | 2 | 5 a day |
| decorating | 1 | 3 a day |
| bath day (the whole routine) | 3 | once a day |
| joining in a fun day (Beginner) | 3 | once a day |
| a present from a walk, drawn | 1 | 3 a day |
| a pet learns a trick | 3 | once per trick per pet |
| a stat goes up a level | 3 per level | - (Advanced only) |
| a pet's trust goes up | 5 x hearts | - |
| competitions (first try at a cup that day) | 1st/2nd/3rd/4th by cup | see `competitions.md` |
| practice at the Fun Fair, rematches | 1 | 3 a day |

The daily caps exist so the fastest way to earn is to **come back tomorrow**, not to grind
fetch for an hour - the same rhythm Nintendogs has.

## What is in the shop

The rule for stock: **only what a kid cannot just draw.** They can draw any toy, food,
furniture or hat they like for free; the shop sells what drawing cannot give them.

| tab | items | why it is worth stars |
|---|---|---|
| **Adopt** | **40 pets** in four groups - Meadow & Forest, Fliers, Water & Oddballs, Dinos & Monsters (35 tiny ... 110 giant) | creatures the kid did not draw; tap one to MEET it first: it bounces up to say hello, with its size, personality, favourite place, favourite food and toy, and stats |
| Shiny Toys | Shiny Ball, Golden Bone, Glitter Disc, Rainbow Rope, Crystal Squeaker, Star Plush, Puzzle Cube, Rocket Ball (25-40) | they **shine and sparkle**, and train their stat **twice as fast** |
| Clothes | 10 hats, 4 glasses, bow tie, scarf, bandana, cape, backpack, fairy wings (10-50; the crown and wings shine) | dressing up, and Style Show points for matching the theme |
| Markers & Treats | Gold, Rainbow and Glitter Markers (120-150, one drawing each); Star Snack (15, one use) | a marker lasts a whole drawing - every part of a new pet, all of one fix-up, or one toy - and is used up when it is finished (or not at all if the drawing is thrown away); what it drew shines forever. A Star Snack makes every stat train faster for ten minutes |
| Furniture | Throne, Rainbow Slide, Hot Tub, Treehouse, Piano, Castle Bed (45-70) | fancy things with several words at once |
| Places | Cloud Kingdom 90, Candy Land 100, The Moon 120, Castle 150 | a pet can dream of these from day one; buying one lets a home be built there |
| Room to Grow | a new home plot (60, 120, 200, 300), an extra room in a home (30, 50, 80, 120) | more pets - see below |

**Prizes are never for sale.** The Gold Medal is won by coming first in a Gold Cup or above.

## Adopting

The forty adoptable pets (`Adoptables`, drawn in `scripts/art_adopt_*.gd`) are drawn as if by
other kids, part by part, and built by the same pipeline as a kid's own pet. Each has a size,
favourite place, two personality words, a favourite food and toy, and starting stats from all
of those. Adopting one needs a free room (or a free plot to build a home on) and its price in
stars, paid once it has moved in. It becomes a family pet like any other - its own folder,
trust starting at zero, free to train, dress and enter. One of each.

## Shiny things

Shiny is the only art in the game that is not plain pencil or marker (`Shiny`): a metallic,
rainbow or glitter tint, a band of light sweeping across, and four-pointed sparkles twinkling
on the ink. A shiny marker records which strokes it drew in a mask, so only those strokes
shine - a kid can draw a plain crown with a shining gold jewel.

## Room to grow

A family starts with **2 home plots** and **2 rooms in each home** - four pets. More room costs
gold stars **and trust**:

- **A new home plot** needs every pet the family has to trust them to 2 hearts (then 3, 3, 4).
- **An extra room** in a home needs every pet in that home to trust them to 1 heart (then 2, 3, 3).
- At most 6 plots and 6 rooms a home.

Trust is hearts, 0-5, earned by love - petting, feeding, playing (`Stats.TRUST_LOVE`). So the
way to a bigger family is to look after the one you have, which is the point. A greyed-out
buy button always says exactly who needs more trust.

## Ideas not built yet

- **Seasonal stock**: a pumpkin plush in October, a snowflake marker in December.
- **Gift a friend**: buy a toy to send with a pet when it visits (see `sharing.md`).
- **Sticker book** of every star milestone ever earned, as a record to page through.
- **Wallpaper and paper styles** for the drawing sheet (squared paper, a chalkboard).
