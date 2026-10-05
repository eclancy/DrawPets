# Online play through ecec.dev

Kids' pets visiting each other - the Bark Mode idea - through the same server that already takes
DrawFight submissions. **Not built.** This is the design, and the questions that must be
answered before any of it ships.

## What it is (decided direction)

- **Visiting**: a kid takes ONE of their pets to visit a friend's home. Their pet plays with
  the friend's pets there - fetch, tug, chasing each other round the furniture.
- **Learning from friends**: a visit can teach a pet a trick the friend's pet knows (once trick
  cards exist), and gives a small boost to the stat the friend's pet is best at.
- **Making friends**: pets that have met remember each other. A friendship meter goes up each
  visit, and friends greet each other with hearts.
- **Bringing things home**: a visiting pet comes back with a gift from the friend's family - a
  copy of one of their drawn toys or snacks, which joins your toybox or pantry. (Kids' drawings
  travelling between families is exactly why moderation matters, below.)
- **Return visits**: sometimes, when the game starts, a pet you have visited is already in one
  of your homes, playing with your pets. It stays for the session, then goes home.

## Why it needs care

The players are 10-12: **under 13**. A service that collects personal information from children
under 13 falls under COPPA in the US (and GDPR-K, the UK Children's Code elsewhere). A drawing is
low-risk; a pet's name can contain a real name; **a child's voice is personal information.**

## Rules

1. **Nothing goes up without a parent.** A parent gate (device PIN, or approval from the
   parent's email) before anything is uploaded. No kid accounts, no kid logins.
2. **Everything is moderated before anyone sees it.** Uploads land in a queue (like DrawFight's
   `fighters/incoming/`) and Eric approves each one. Nothing is auto-published.
3. **Drawings, words and layout only.** What travels is `pet.json`, its part PNGs, and the
   drawn items it brings. **Never the voice recording** - visitors use the generated voice. No
   free text beyond the pet's name, shown only after moderation.
4. **No contact between kids.** No messages, no chat, no names of kids - a visit is pets playing.
5. **Friends, not strangers, first.** Start with share codes between families who know each
   other (a code a parent passes on), not a public pool. Far lower risk and moderation load.
6. **Removable.** A parent can delete anything uploaded; the server deletes it everywhere.

## Shape

- **Upload**: the pet folder (minus voice) plus any items it carries, zipped, posted to an
  `intake/` endpoint with the parent's approval token.
- **Visits**: the game fetches approved pets from friends' codes. Visiting is asynchronous - you
  visit a copy of their home and pets, and they find out later that you came (and what you left).
- **Postcards**: a photo of the two pets together, saved to both albums.

## Open questions

- Parent gate: device PIN, or an emailed approval link?
- Share codes only, or eventually a moderated public pool of visitors?
- Who moderates when Eric is away?
- Is the server in EricClancyEngineeringAndCrafts ready for a second intake type?
