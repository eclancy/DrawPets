# Project overview

A virtual-pet game where every pet is a creature a kid drew, part by part, inside the game.
It walks, wags, blinks and plays because of the parts it has - and then they look after it,
Nintendogs-style, in the place it loves most.

## The pitch

A kid picks what their creature has - a head, two eyes, six legs, wings, a tail - and draws
each part on its own sheet, starting from a red dot that marks where it joins on. The game
lays the parts out on the body, the kid drags them where they want them, and the creature
comes alive. Then they name it, pick how big it is and where it loves to live, and draw its
favourite food and favourite toy. Then they visit it, pet it, feed it, throw its toy, and come
back tomorrow to see it again.

The point is the same as DrawFight's: **they see their own drawing alive**. The difference is
that nothing has to leave the game to get there. No photos, no cutting, no grown-up in the
loop, and no AI anywhere. Every pixel on the creature is one the kid put there, and every way it
moves comes from a hand-written motion recipe for that kind of part.

## Who it is for

Kids aged 10-12 (decided). Old enough to read short prompts and handle a real care routine,
contests and unlocks; young enough that the drawing has to be fast and forgiving on a phone.
The family plays on one shared Android phone or tablet first, iOS later.

## The five pillars

1. **Their linework survives.** Strokes are never smoothed, straightened, traced or "improved".
   Parts only ever rotate and squash - they are not warped or redrawn. Overlays (mud, a hat)
   sit on top and come off; they never edit the drawing.
2. **Motion comes from the part, not the creature.** A leg steps, a tail wags, an eye blinks,
   whatever it is attached to and however many there are. So any combination a kid invents
   animates the first time, with zero per-creature animation work. Parts also decide abilities:
   wings fly, fins swim, no legs means it hops.
3. **Their choices are the pet's personality.** Favourite food, toy, place and size are not
   labels - they change what the pet does, how it reacts, and where it is happiest.
4. **Gentle, never punishing.** A pet never gets sick, never runs away, never dies. Neglect
   makes it sleepy and mopey; one visit fixes it. The game never grades a drawing.
5. **Making a pet is fast, and drawing more is always rewarded.** A whole creature in under ten
   minutes. Every later system - presents, accessories, decorations, trick cards - is another
   excuse to draw something.

## Decided

| question | answer |
|---|---|
| engine | Godot 4.5, **GDScript** (C# cannot export to iOS or web and is shaky on Android) |
| platform | **Android first**, iOS later. Landscape. Touch first; mouse works for testing |
| renderer | GL Compatibility - runs on cheap tablets |
| age | 10-12 |
| assembly | draw each part on its own sheet, then **drag parts onto the body** |
| care | **gentle real-time** - needs drift while the app is closed, with a floor |
| microphone | record the creature's own voice (3 s at most), and call it by loudness - **all optional**, off unless turned on, with a button for everything the mic does |
| voices | a base sound + sliders (higher/deeper, faster/slower, wobble, echo, bend, robot, backwards) or a recording; varied every time the pet talks |
| fixing pets | redraw, add, take off, move parts; move home; let go "to live in the wild" (hold to confirm) |
| sharing | **online through ecec.dev**, moderated: visit friends' homes with a pet, learn, make friends, bring gifts home - see `sharing.md` |
| face | eyes and a mouth are required; the mouth is drawn open and the game shuts it |
| drawing order | ask heads, arms and legs up front; add everything else while drawing the part it goes on |
| buttons | pictures wherever possible |
| adopting | 40 creatures the kid did not draw, to meet and adopt in the shop |
| homes | plots start empty; build a ready-made home from a list and name it |
| describing | kids describe toys, food, furniture, clothes, pets and places with preset words, and the words drive behaviour |
| progression | gold stars from milestones; a shop of shiny toys, clothes, markers, furniture, special places and room to grow (`shop.md`) |
| stats | speed, strength, agility, stamina, smarts, charm - trained by play, slipping gently if neglected (`pet-life.md`) |
| homes | limited plots and rooms; more cost stars AND the pets' trust (`shop.md`) |
| competitions | a local weekly calendar, one event per stat, four cups (`competitions.md`) |
| art | coloured pencil or marker; shine and sparkle only for special things (`art-direction.md`) |
| AI | none, anywhere |

## Scope

**In:** drawing parts, assembly, procedural motion, care and play, homes to decorate, drawing
or picking food/toys/furniture/clothes, stats, gold stars and the shop, competitions, tricks,
presents, a photo album, visiting through ecec.dev.

**Out unless something changes:** AI of any kind, real-money anything, ads, chat between kids,
free-text visible to other kids, death or illness, a pet running away, judging drawings.

## Engine and house style

Mirrors DrawFight where it can: screens built in code and swapped by `GameRoot`, flat
`scripts/` and `scenes/`, `.ai/` as the design source of truth, a dev flag that screenshots
every screen into `.shots/`. GDScript instead of C#, snake_case files with `class_name`.

See `creature-pipeline.md` for drawing and assembly, `pet-life.md` for care, play, stats and
words, `places.md` for places and homes, `shop.md` for stars and room to grow,
`competitions.md` for events, `art-direction.md` for the look, `sharing.md` for ecec.dev, and
`roadmap.md` for the build order and every idea not built yet.
