# Art direction

The visual contract for everything the kids do **not** draw: places, menus, emotes. Inherited
from DrawFight on purpose, because the problem is the same - the kids' drawings have to win
every frame.

## The one law: creatures own black

Kids draw in black crayon on white more than anything else, and black is the highest-contrast
thing a screen can show. So **nothing outside a creature is ever darker than about 30% value.**

- Places are light, low-saturation crayon with **no outlines**. Depth comes from value.
- Night, caves and the moon are **pale lavender**, never black - a dark sky erases a black
  drawing, and it is how kids draw night anyway.
- UI text and borders are dark indigo (`UI.INK`), not black.
- Emotes (hearts, stars, notes, zzz) are coloured crayon, never black.
- The palette in the drawing screen *does* have black: it is the kids' colour.

## Everything the game draws is a drawing

Nothing in the game is vector clip-art. There are three looks, and every made-for-the-game
picture is one of them:

- **Coloured pencil** (`Crayon.pencil_*`): fine close strokes of uneven pressure, a lighter
  cross-hatch, flecks of paper showing through. Natural, soft things: beds, trees, food.
- **Marker** (`Crayon.marker_*`): broad translucent strokes that go darker in streaks where they
  overlap. Bold things: toys, clothes, props, and the rival pets.
- **Shiny** (`Shiny`): ONLY for special things - shop toys, the crown, shiny-marker strokes,
  gold stars. A metallic, rainbow or glitter tint, a sweeping band of light, twinkling
  four-pointed sparkles. Shine is what stars buy, so nothing ordinary may have it.

Game art is outlined in a **darker shade of its own colour**, never black, and sits on an opaque
paper-white base so nothing behind it shows through (a hat must hide the head under it). The
**rival pets** are the one exception: they are drawn as if by other kids, so they get black
marker outlines - creatures own black. So does the **mascot** on the app icon
(`scripts/art_brand.gd`): a kid's drawn pet, close up and smiling, hugging its coloured pencil, on
a light sky square.

The art lives in `scripts/art_things.gd`, `art_wear.gd` and `art_rivals.gd` as drawing code, and
is baked to `art/` by `tools/bake_art.gd`. Change the drawing code and re-bake; never edit a PNG.

## Buttons are pictures

Wherever a button can be a picture, it is (`scripts/art_ui.gd`): the eraser button is an
eraser, brush sizes are dots of that size, assembly edits are arrows and squares, body parts
have their own little drawings, sizes are animals from a mouse to a dinosaur. Words go under a
picture when a kid might not guess it, never instead of one.

## Crayon, not computer

Everything drawn in code goes through `Crayon`: fills that hatch past their edges, lumpy blobs,
wobbly lines. Every wobble is **hashed from a seed** (`Crayon.noise`), never random - a shape
that re-rolls on each redraw shimmers. Keep the overshoot: colouring outside the lines is what
reads as a child did this.

## Light UI vanishes

Light text on a light place is invisible, so every label over a place is `UI.title`: indigo
with a thick paper-coloured outline. Never a box behind it - boxes cover the place.

## Sizes

Designed at 1280x720, stretched (`canvas_items`, `expand`) to any phone or tablet. Nothing
tappable smaller than about 64 px at design size; creatures at least ~60 px tall even when
tiny (the camera zooms in for them).
