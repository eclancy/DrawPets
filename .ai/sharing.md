# Sharing pets with friends

Kids swap pets **phone to phone, in person**, and from then on each family's pets drop in to
visit the other's homes. **No server, no internet, no accounts.** Built (`SwapScreen`).

## Why it is built this way (decided)

The players are 7 and up - all of them under 13 - and DrawPets is made for them, so under COPPA (US), the UK Children's Code
and Google Play's Families policy it is treated as a children's app **for every player** - an
age gate or birth-date screen does not change that. Anything that stores children's content on
a server and shows it to other families needs verifiable parental consent (a card payment, a
signed form, an ID check, or a consent service), which this project does not do.

So nothing goes to a server. Pets travel only **directly between two phones that are together**,
which collects nothing - the same as two kids swapping drawings at school. Friends are people
you have met. (Not legal advice; revisit with a lawyer before adding anything online.)

## How a swap works

1. Both kids open **Friends** (home screen) and tap **Swap pets with a friend** at the same time,
   phones close together.
2. The phones find each other (`SwapLink`):
   - **Nearby Connections** (`NearbyLink`, the `DrawPetsNearby` Android plugin in
     `addons/drawpets_nearby/`, source in `android_plugin/`) where Google Play services exist:
     Bluetooth to find each other, then a direct Wi-Fi link Nearby makes itself. No Wi-Fi network,
     no internet, no data plan.
   - **The same Wi-Fi, or one phone's hotspot** (`LanLink`) everywhere else (e.g. Amazon Fire
     tablets): a UDP broadcast on the room's network, then TCP straight between the phones. Also
     offered as "Try the Wi-Fi way" when Nearby will not connect.
3. Both screens say "Found the Mango family!" and show **the same three pictures** (from Nearby's
   authentication digits, or from both phones' session numbers on Wi-Fi). Both kids tap **Yes,
   that's them** - which also stops a phone in the next room joining by mistake.
4. **All of each family's pets** hop across (`PetPack`), and are saved as visitors (`Visitors`).
5. A first swap with a family: 3 stars, once.

**Or with a code** ("Swap with a code" beside the big button, and on the what-to-try page) - for
a friend whose phone can't find this one: an iPhone (when there is an iOS version; Nearby's iOS
library is not ready, and an iPhone may only broadcast with Apple's say-so), or Wi-Fi that won't
pass a broadcast. Both phones on the same Wi-Fi, or one on the other's hotspot (which needs no
internet or data plan):

1. Each phone shows its **swap code** (a QR code, `QrCode`) beside a **Scan my friend's code**
   button. Either kid scans the other's.
2. The code holds where to find the phone on the room's network and a one-time secret
   (`LanLink.code`). The scanner calls straight there; the phone that showed it says nothing until
   it hears the right secret. Scanning was the check, so there are no pictures - the pets go.
3. The camera is asked for only when a kid taps Scan, after a kid-words explanation, and only to
   read the code: the scanner (ZXing, a plain pattern decoder - no AI) keeps no picture.

Before Nearby's Android permission pop-up the game explains it in kid words ("Tap ALLOW!"). If
anything goes wrong the kid sees a picture checklist (is the swap screen open on both? is
Bluetooth on? same Wi-Fi?) - never an error message.

## What travels (rules)

1. **Drawings, words and layout only:** each pet's part drawings and layout, name, size,
   favourite place, personality, coat, a generated voice recipe, clothes and favourites from the
   game's own catalog.
2. **Never** a voice recording (a recorded voice is swapped for the generated one), the journal,
   photos, friends, stars, stats, or anything about the child (CLAUDE.md rule 8).
3. **Everything received is untrusted** and checked field by field against the game's own
   tables (`PetPack.unpack`): sizes capped, ids and file names restricted, every drawing
   re-decoded and size-limited, names cut to 24 characters with control characters removed.
   **A scanned code is untrusted too** (`LanLink.read_code`): only our own format, only our own
   ports, only home, school and hotspot addresses (10.x, 172.16-31.x, 192.168.x), at most three -
   whatever QR code a kid points the camera at, the game never calls out to the internet.
4. **No contact between kids**: no messages, no chat, no kid names - families are "the Mango
   family", a made-up nickname (`Family`). A visit is pets playing.
5. **Removable**: a grown-up holds a family's button on the Friends page to remove it - its pets
   are deleted from this phone, and your pets forget them.

## The only other thing that goes online

The update check (`.ai/releasing.md`): a downloaded copy asks ecec.dev for `version.json` when it
starts, with nothing about the player in the request. Nothing a kid made ever goes with it.

## Visiting

A friend family's pet drops into a home the first time it is opened each day, and now and then
after (not at night, not during a party). It wanders, plays, makes friends with your pets
(`Friends` - what it makes friends with is remembered for next time) and goes home when you
leave. Tap it and it says hello. Its pets are as up to date as the last swap; swapping again
refreshes them. Up to 30 friend families are kept.

## Later, maybe

Friends far away (pets updating over the internet) would need a server holding children's
content, so verifiable parental consent first - see "Why it is built this way". Not planned.
