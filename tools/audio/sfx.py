# -*- coding: utf-8 -*-
"""Every DrawPets sound effect, one function per file, plus REGISTRY.

The game looks like a kid's drawing come to life, so it sounds like a soft cartoon: paper and
crayon for the drawing, pats and boings for pets, little bells for rewards. Anything tonal is in
C major, the key of the music, so every chime agrees with it (.ai/audio-direction.md).

A function that is not in REGISTRY does not ship - build.py does not scan this module.
"""
from __future__ import division

import random

import synth as S
from band import note, toypiano, horn, tom, block, clap, slidewhistle

SEED = 8800

C5, D5, E5, F5, G5, A5, B5 = [note(n) for n in ("C5", "D5", "E5", "F5", "G5", "A5", "B5")]
C6, E6, G6, C7 = note("C6"), note("E6"), note("G6"), note("C7")
C4, E4, G4 = note("C4"), note("E4"), note("G4")


# ---------------------------------------------------------------------------
# shared constructs
# ---------------------------------------------------------------------------

def swell(dur, peak_at=0.35, curve=2.0):
    n = S.n_samples(dur)
    up = max(1, int(n * peak_at))
    return S.ramp(up, 0.0, 1.0, 0.7) + S.decay(n - up, curve)


def whoosh(dur, f0, f1, q=1.3, seed=1, peak_at=0.35):
    v = S.osc("noise", 0, dur, seed=SEED + seed)
    v = S.bandpass(v, S.sweep(dur, f0, f1, 0.8), q)
    return S.env_mul(v, swell(dur, peak_at))


def thump(dur, f0, f1, k=10.0):
    n = S.n_samples(dur)
    return S.env_mul(S.osc("sine", S.sweep(dur, f0, f1, 0.4), dur), S.expdecay(n, k))


def tick(dur, cutoff=2500.0, k=40.0, seed=2):
    n = S.n_samples(dur)
    v = S.highpass(S.osc("noise", 0, dur, seed=SEED + seed), cutoff)
    return S.env_mul(v, S.expdecay(n, k))


def bell(freq, dur, bright=1.0):
    """A small struck bell - the voice of every reward."""
    return S.partials(freq, [1.0, 2.0, 3.01, 4.2], dur,
                      amps=[1.0, 0.4 * bright, 0.18 * bright, 0.1 * bright],
                      decays=[5.0, 7.0, 10.0, 14.0])


def tone(shape, freq, dur, cutoff=3000.0, attack=0.004, curve=3.0):
    v = S.lowpass(S.osc(shape, freq, dur), cutoff)
    return S.env_mul(v, S.ad(dur, attack, curve))


def pip(freq, dur=0.06, k=30.0):
    """A soft paper-and-pencil pip: a short sine with a breath of noise on its front."""
    n = S.n_samples(dur)
    body = S.env_mul(S.osc("sine", freq, dur), S.expdecay(n, k))
    return S.mix(body, S.gain(tick(0.012, 3000, 80.0, seed=int(freq) % 97), 0.25))


def sparkles(count, dur, seed, low=1800.0, high=4200.0):
    """A shower of tiny high bells at seeded times - the sound of shine."""
    rng = random.Random(SEED + seed)
    parts = []
    for i in range(count):
        f = rng.uniform(low, high)
        parts.append((bell(f, 0.25, 0.5), rng.uniform(0.0, dur * 0.7), rng.uniform(0.35, 0.8)))
    return S.layer(parts)


def arpeggio(freqs, step, voice=bell, dur=0.6, vel=None):
    vel = vel or [1.0] * len(freqs)
    return S.layer([(voice(f, dur), i * step, v) for i, (f, v) in enumerate(zip(freqs, vel))])


def boing_curve(dur, f0, f1, wobble_hz=20.0, depth=0.25, k=2.5):
    spring = S.osc("sine", S.sweep(dur, f0, f1, 0.7), dur)
    wob = S.osc("sine", wobble_hz, dur)
    spring = [a * (1.0 - depth + depth * b) for a, b in zip(spring, wob)]
    return S.env_mul(spring, S.ad(dur, 0.004, k))


def crackle(dur, rate, cutoff, seed, duty=0.3):
    v = S.highpass(S.osc("noise", 0, dur, seed=SEED + seed), cutoff)
    return S.gate(v, rate, duty, seed=SEED + seed + 1)


# ---------------------------------------------------------------------------
# UI
# ---------------------------------------------------------------------------

def ui_tap():
    """Every button: a soft pip, like a crayon tapped on paper."""
    return pip(1250.0, 0.07, 34.0)


def ui_toggle():
    return S.layer([(pip(1100.0, 0.05), 0.0, 0.8), (pip(1650.0, 0.06), 0.045, 1.0)])


def ui_nope():
    """Not now: a soft low wobbly boop - never a buzzer."""
    dur = 0.28
    f = [v * (1.0 + 0.03 * w) for v, w in zip(S.sweep(dur, 300, 220), S.osc("sine", 9.0, dur))]
    return S.env_mul(S.lowpass(S.osc("tri", f, dur), 1500), S.ad(dur, 0.01, 2.0))


def toast():
    """A message popping up: a little bubble pop."""
    dur = 0.12
    return S.env_mul(S.osc("sine", S.sweep(dur, 500, 1300, 0.5), dur), S.ad(dur, 0.002, 3.0))


def star():
    """A gold star earned: a bright bell climbing C-E-G-C with a little shimmer on top."""
    v = arpeggio([C6, E6, G6, C7], 0.055, vel=[0.7, 0.75, 0.8, 1.0])
    return S.layer([(v, 0.0, 1.0), (sparkles(6, 0.5, 11, 3000, 6000), 0.12, 0.5)])


def buy():
    """Something bought: ka-ching - two bright metal hits and a shower of coins."""
    hit = S.partials(1900, [1.0, 2.4, 3.9], 0.5, amps=[1.0, 0.5, 0.3], decays=[8.0, 11.0, 16.0])
    hit2 = S.partials(2500, [1.0, 2.4, 3.9], 0.6, amps=[1.0, 0.5, 0.3], decays=[6.0, 9.0, 14.0])
    return S.layer([(hit, 0.0, 0.7), (hit2, 0.09, 0.9), (sparkles(10, 0.6, 12, 2500, 5500), 0.1, 0.6)])


def level_up():
    """A stat went up: a quick climbing fanfare of bells, ending on a held C."""
    v = arpeggio([C5, E5, G5, C6, E6], 0.07, dur=0.9, vel=[0.6, 0.65, 0.7, 0.8, 1.0])
    return S.layer([(v, 0.0, 1.0), (sparkles(8, 0.7, 13), 0.3, 0.45)])


def trust_up():
    """A trust heart: a warm harp sweep up through C major, soft and round."""
    freqs = [note(n) for n in ("C4", "E4", "G4", "C5", "E5", "G5", "C6")]
    harp = S.layer([(toypiano(f, 0.9), i * 0.045, 0.5 + 0.07 * i) for i, f in enumerate(freqs)])
    return S.reverb(S.pad(S.lowpass(harp, 5000), 1.4), size=0.6, damp=0.5, mix=0.25)


def adopt():
    """A new pet in the family: a toy-trumpet ta-daa and bells."""
    ta = S.layer([(horn(f, 0.16), 0.0, 0.8) for f in (C5, E5, G5)])
    daa = S.layer([(horn(f, 0.7), 0.0, 0.9) for f in (E5, G5, C6)])
    return S.layer([(ta, 0.0, 1.0), (daa, 0.2, 1.0), (sparkles(10, 0.8, 14), 0.25, 0.5)])


def build():
    """A home built: tap-tap-tap with a little hammer, then a ta-da."""
    knocks = S.layer([(block(520.0, 0.1), t, 1.0) for t in (0.0, 0.14, 0.28)])
    tada = arpeggio([G5, C6], 0.09, dur=0.7, vel=[0.8, 1.0])
    return S.layer([(knocks, 0.0, 0.9), (tada, 0.45, 1.0)])


def goodbye():
    """A pet off to live in the wild: a music box, gentle, falling then lifting - fond, not sad."""
    freqs = [note(n) for n in ("C6", "A5", "F5", "G5", "C6")]
    v = S.layer([(toypiano(f, 1.2), i * 0.24, 0.8) for i, f in enumerate(freqs)])
    return S.reverb(S.pad(v, 2.4), size=0.7, damp=0.4, mix=0.3)


def dress():
    """Putting clothes on: a fabric swish and a twinkle."""
    swish = whoosh(0.22, 1500, 4000, 0.9, seed=20, peak_at=0.4)
    return S.layer([(swish, 0.0, 1.0), (sparkles(4, 0.3, 21, 2500, 5000), 0.12, 0.5)])


# ---------------------------------------------------------------------------
# drawing
# ---------------------------------------------------------------------------

def crayon():
    """A crayon on paper, looped: grainy scratching that the game fades with the stroke."""
    dur = 1.0
    grit = S.bandpass(S.osc("noise", 0, dur, seed=SEED + 30), 2600, 0.9)
    grit = S.gate(grit, 70.0, 0.55, seed=SEED + 31)
    body = S.lowpass(S.osc("noise", 0, dur, seed=SEED + 32), 700)
    v = S.mix(grit, S.gain(body, 0.5))
    return S.tremolo(v, 3.0, 0.25)


def eraser():
    """Rubbing out, looped: a soft dull rub."""
    dur = 1.0
    v = S.lowpass(S.osc("noise", 0, dur, seed=SEED + 33), 1100, 0.9)
    return S.tremolo(v, 8.0, 0.5)


def fill():
    """The paint bucket: bloop, then a soft splosh as the colour spreads."""
    dur = 0.4
    n = S.n_samples(dur)
    bloop = S.env_mul(S.osc("sine", S.sweep(dur, 900, 280, 0.5), dur), S.expdecay(n, 7.0))
    wet = S.env_mul(S.lowpass(S.osc("noise", 0, dur, seed=SEED + 34), S.sweep(dur, 2400, 500)),
                    S.expdecay(n, 9.0))
    return S.mix(bloop, S.gain(wet, 0.5))


def undo():
    """Undo: a quick backwards zip."""
    return S.reverse(whoosh(0.18, 3000, 900, 1.1, seed=35, peak_at=0.2))


def clear():
    """Clear: a sheet scrunched up into a ball."""
    dur = 0.55
    parts = [(S.env_mul(crackle(0.12, 160.0, 1600, 40 + i, 0.4), S.ad(0.12, 0.002, 2.0)),
              i * 0.08, 0.9 - 0.08 * i) for i in range(6)]
    return S.layer(parts)


def dot():
    return pip(1600.0, 0.05, 40.0)


def done():
    """A drawing finished: a bright little two-note chime."""
    return arpeggio([G5, C6], 0.08, dur=0.6, vel=[0.75, 1.0])


# ---------------------------------------------------------------------------
# pets
# ---------------------------------------------------------------------------

def step():
    """A soft padded footstep. The game pitches it by the pet's size and varies it every step."""
    dur = 0.09
    pad = S.lowpass(S.osc("noise", 0, dur, seed=SEED + 50), 900)
    n = S.n_samples(dur)
    return S.mix(S.env_mul(pad, S.expdecay(n, 18.0)), S.gain(thump(dur, 160, 90, 22.0), 0.7))


def hop():
    return boing_curve(0.22, 260, 620, 24.0, 0.2, 3.0)


def land():
    dur = 0.14
    n = S.n_samples(dur)
    return S.mix(thump(dur, 140, 70, 14.0), S.gain(S.env_mul(S.lowpass(S.osc("noise", 0, dur, seed=SEED + 51),
                                                                       600), S.expdecay(n, 20.0)), 0.6))


def flap():
    """Wings: a soft flutter."""
    dur = 0.26
    v = S.bandpass(S.osc("noise", 0, dur, seed=SEED + 52), 900, 0.8)
    v = S.gate(v, 16.0, 0.6, seed=SEED + 53)
    return S.env_mul(v, swell(dur, 0.3))


def bubble():
    """Swimming: a bloop of air rising."""
    dur = 0.14
    return S.env_mul(S.osc("sine", S.sweep(dur, 320, 1000, 0.6), dur), S.ad(dur, 0.005, 2.5))


def munch():
    """Eating: a crunchy chomp."""
    dur = 0.24
    n = S.n_samples(dur)
    crunch = S.env_mul(crackle(dur, 220.0, 1400, 54, 0.45), S.expdecay(n, 9.0))
    jaw = thump(0.1, 220, 120, 18.0)
    return S.layer([(jaw, 0.0, 0.8), (crunch, 0.0, 1.0)])


def chew():
    """Chewing a toy: a soft gummy squish."""
    dur = 0.3
    v = S.lowpass(S.osc("noise", 0, dur, seed=SEED + 55), S.sweep(dur, 400, 1400, 1.0), 2.5)
    return S.env_mul(v, swell(dur, 0.5))


def sniff():
    parts = [(S.env_mul(S.bandpass(S.osc("noise", 0, 0.07, seed=SEED + 56 + i), 2600, 1.2),
                        swell(0.07, 0.6)), i * 0.11, 1.0) for i in range(2)]
    return S.layer(parts)


def snore():
    """Asleep: a soft breath in, a rumbly breath out."""
    inhale = S.env_mul(S.bandpass(S.osc("noise", 0, 0.6, seed=SEED + 58), 1500, 0.8), swell(0.6, 0.8))
    out = S.mix(S.lowpass(S.osc("saw", S.sweep(0.7, 85, 70), 0.7), 500),
                S.gain(S.lowpass(S.osc("noise", 0, 0.7, seed=SEED + 59), 700), 0.6))
    out = S.env_mul(out, swell(0.7, 0.2))
    return S.layer([(inhale, 0.0, 0.5), (out, 0.62, 1.0)])


def heart():
    """A heart floating up: a soft pop with a little bell in it."""
    return S.layer([(toast(), 0.0, 0.6), (bell(E6, 0.4, 0.4), 0.02, 0.5)])


def sparkle():
    """A star over a pet's head."""
    return sparkles(7, 0.45, 60)


def splash():
    dur = 0.55
    n = S.n_samples(dur)
    water = S.lowpass(S.osc("noise", 0, dur, seed=SEED + 61), S.sweep(dur, 3600, 500, 0.6))
    water = S.env_mul(water, S.expdecay(n, 6.0))
    blips = S.layer([(tone("sine", f, 0.07, cutoff=4000.0), t, 0.25) for f, t in
                     ((620, 0.08), (840, 0.15), (700, 0.23), (980, 0.31))])
    return S.layer([(water, 0.0, 1.0), (blips, 0.0, 1.0)])


def scratch():
    strokes = [(S.env_mul(S.bandpass(S.osc("noise", 0, 0.1, seed=SEED + 62 + i), 3200, 1.5), swell(0.1, 0.3)),
                i * 0.13, 1.0) for i in range(3)]
    return S.layer(strokes)


# ---------------------------------------------------------------------------
# mud and the bath
# ---------------------------------------------------------------------------

def _pop(f0, f1=None, dur=0.05):
    f1 = f1 or f0 * 2.0
    return S.env_mul(S.osc("sine", S.sweep(dur, f0, f1, 0.6), dur), S.ad(dur, 0.002, 4.0))


def snip():
    """Clipping a nail: a tiny bright click with a ting."""
    return S.layer([(tick(0.03, 4500, 120.0, seed=330), 0.0, 1.0), (bell(G6, 0.15, 0.3), 0.0, 0.25)])


def splat():
    """Mud landing on a pet: a wet, low thwack and a drip or two."""
    dur = 0.3
    n = S.n_samples(dur)
    wet = S.lowpass(S.osc("noise", 0, dur, seed=SEED + 300), S.sweep(dur, 1800, 300, 0.5))
    wet = S.env_mul(wet, S.expdecay(n, 14.0))
    body = thump(0.16, 170, 80, 16.0)
    drips = S.layer([(tone("sine", f, 0.05, cutoff=3000.0), t, 0.18) for f, t in ((520, 0.1), (690, 0.17))])
    return S.layer([(body, 0.0, 0.9), (wet, 0.0, 1.0), (drips, 0.0, 1.0)])


def scrub():
    """A soapy sponge rubbing: a squishy swish and tiny bubble pops."""
    dur = 0.32
    v = S.bandpass(S.osc("noise", 0, dur, seed=SEED + 301), S.sweep(dur, 900, 2200, 1.0), 1.4)
    v = S.gate(v, 22.0, 0.6, seed=SEED + 302)
    v = S.env_mul(v, swell(dur, 0.4))
    pops = S.layer([(_pop(f), t, 0.3) for f, t in ((900, 0.06), (1300, 0.16), (1100, 0.24))])
    return S.layer([(v, 0.0, 1.0), (pops, 0.0, 1.0)])


def brush():
    """A brush through fur: two soft bristly swishes."""
    return S.layer([(S.env_mul(S.highpass(S.osc("noise", 0, 0.16, seed=SEED + 305 + i), 3500),
                               swell(0.16, 0.5)), i * 0.12, 1.0 - 0.3 * i) for i in range(2)])


def shake():
    """Shaking dry: a fast fluttery brrrr that slows, drops flicking off."""
    dur = 0.9
    v = S.bandpass(S.osc("noise", 0, dur, seed=SEED + 310), 1300, 0.9)
    v = S.tremolo(v, 17.0, 0.9)
    v = S.env_mul(v, S.ad(dur, 0.02, 2.0))
    drops = S.layer([(tone("sine", f, 0.05, cutoff=4000.0), t, 0.2) for f, t in
                     ((880, 0.1), (1040, 0.22), (760, 0.35), (990, 0.5))])
    return S.layer([(v, 0.0, 1.0), (drops, 0.0, 1.0)])


def clean():
    """Squeaky clean: a rubbery squeak up, then a glassy ting (C major: E6 G6 C7)."""
    sq = S.env_mul(S.osc("sine", S.sweep(0.12, 1100, 1700, 0.8), 0.12), S.ad(0.12, 0.005, 3.0))
    ting = S.layer([(bell(E6, 0.6, 0.8), 0.12, 0.8), (bell(G6, 0.7, 0.8), 0.2, 0.7), (bell(C7, 0.8, 0.6), 0.28, 0.5)])
    return S.layer([(sq, 0.0, 0.6), (ting, 0.0, 1.0)])


def rain():
    """A passing shower, looped: a soft hiss and a patter on leaves."""
    dur = 4.0
    hiss = S.highpass(S.lowpass(S.osc("noise", 0, dur, seed=SEED + 320), 2400), 300)
    patter = crackle(dur, 30.0, 2500, 321, 0.15)
    return S.tremolo(S.mix(S.gain(hiss, 0.5), S.gain(patter, 0.6)), 0.5, 0.2)


# ---------------------------------------------------------------------------
# toys and things
# ---------------------------------------------------------------------------

def throw():
    return whoosh(0.3, 600, 2400, 1.0, seed=70, peak_at=0.25)


def bounce():
    """A ball hitting the ground: a rubbery boink. The game pitches it by how hard it hit."""
    return S.layer([(thump(0.12, 200, 100, 16.0), 0.0, 0.8),
                    (boing_curve(0.16, 420, 260, 30.0, 0.15, 4.0), 0.0, 0.6)])


def squeak():
    """A squeaky toy, squeezed and let go: two squeals."""
    def one(f0, f1, dur):
        v = S.fm("saw", S.sweep(dur, f0, f1, 0.6), 38.0, 0.04, dur)
        return S.env_mul(S.bandpass(v, 2400, 2.0), S.adsr(dur, 0.01, 0.03, 0.8, 0.05))
    return S.layer([(one(1400, 1900, 0.13), 0.0, 1.0), (one(1900, 1500, 0.15), 0.15, 0.9)])


def thud():
    """Something heavy landing."""
    dur = 0.3
    n = S.n_samples(dur)
    return S.mix(thump(dur, 110, 45, 9.0),
                 S.gain(S.env_mul(S.lowpass(S.osc("noise", 0, dur, seed=SEED + 71), 500), S.expdecay(n, 14.0)), 0.7))


def catch():
    """A toy caught in the mouth: a chomp and a clack."""
    return S.layer([(thump(0.08, 260, 140, 22.0), 0.0, 0.7), (block(900.0, 0.1), 0.01, 0.6)])


def tug():
    """A rope stretched in tug of war: a creak."""
    dur = 0.38
    squeal = S.fm("saw", S.sweep(dur, 380, 300, 0.8), 23.0, 0.05, dur)
    return S.env_mul(S.bandpass(squeal, 900, 2.0), S.adsr(dur, 0.04, 0.05, 0.7, 0.12))


def place():
    """Furniture set down: a woody plonk."""
    return S.layer([(block(240.0, 0.2), 0.0, 1.0), (thump(0.16, 130, 70, 14.0), 0.0, 0.7)])


def pickup():
    return whoosh(0.16, 900, 2600, 1.2, seed=72, peak_at=0.6)


def trampoline():
    return boing_curve(0.5, 160, 520, 22.0, 0.25, 2.5)


def drum():
    return tom(note("C3"), 0.3)


def piano():
    """Dancing to a piano: a little run up C major on the toy piano."""
    return S.layer([(toypiano(f, 0.8), i * 0.11, 0.8) for i, f in enumerate((C5, E5, G5, C6))])


def slide():
    """Down a slide: wheee - a whistle falling."""
    dur = 0.8
    n = S.n_samples(dur)
    f = [a * (1.0 + 0.01 * b) for a, b in zip(S.sweep(dur, 1500, 700, 1.2), S.osc("sine", 7.0, dur))]
    v = S.mix(S.osc("sine", f, dur), S.gain(S.highpass(S.osc("noise", 0, dur, seed=SEED + 73), 3000), 0.04))
    return S.env_mul(v, S.adsr(dur, 0.03, 0.05, 0.9, 0.2))


def shiny():
    """A shiny thing: a shimmer of bells that swells and fades."""
    v = sparkles(14, 0.9, 74, 2000, 5000)
    return S.tremolo(S.pad(v, 1.1), 9.0, 0.3)


# ---------------------------------------------------------------------------
# competitions
# ---------------------------------------------------------------------------

def count_tick():
    return bell(C5, 0.4)


def count_go():
    chord = S.layer([(bell(f, 0.9), 0.0, 0.7) for f in (C5, E5, G5, C6)])
    return S.layer([(chord, 0.0, 1.0), (whoosh(0.5, 800, 3500, 0.8, seed=80, peak_at=0.2), 0.0, 0.4)])


def good():
    """A tap on time: a bright ding."""
    return bell(E6, 0.45)


def bad():
    """A tap off time: a soft wooden bonk, falling."""
    return S.layer([(block(300.0, 0.15), 0.0, 1.0), (tone("tri", 260, 0.18, 1200), 0.0, 0.5)])


def jump():
    return boing_curve(0.25, 300, 800, 26.0, 0.2, 3.0)


def drum_beat():
    """The marathon's drum - the beat to tap along with."""
    return tom(note("G2"), 0.3)


def heave():
    """HEAVE! on time: a big whoosh and a rope snapping taut."""
    return S.layer([(whoosh(0.3, 500, 1800, 0.9, seed=81, peak_at=0.2), 0.0, 1.0),
                    (block(700.0, 0.1), 0.05, 0.7)])


def card_flip():
    return S.layer([(tick(0.03, 1500, 60.0, seed=82), 0.0, 1.0),
                    (whoosh(0.08, 1200, 3000, 1.5, seed=83, peak_at=0.5), 0.0, 0.5)])


def correct():
    return arpeggio([E6, G6], 0.08, dur=0.5)


def wrong():
    return S.layer([(tone("tri", 392.0, 0.16, 1500), 0.0, 0.8), (tone("tri", 311.0, 0.24, 1500), 0.14, 0.8)])


def camera():
    """Strike a pose: a camera shutter and a flash charging."""
    shutter = S.layer([(tick(0.02, 1800, 80.0, seed=84), 0.0, 1.0), (tick(0.02, 1800, 80.0, seed=85), 0.05, 0.8)])
    whine = S.env_mul(S.osc("sine", S.sweep(0.25, 2000, 5000), 0.25), S.ad(0.25, 0.01, 2.0))
    return S.layer([(shutter, 0.0, 1.0), (whine, 0.06, 0.12)])


def cheer():
    """A little crowd cheering and clapping."""
    dur = 1.6
    rng = random.Random(SEED + 86)
    crowd = S.bandpass(S.osc("noise", 0, dur, seed=SEED + 87), 1300, 0.5)
    crowd = S.env_mul(crowd, swell(dur, 0.25, 1.6))
    hoots = S.layer([(S.env_mul(S.osc("sine", S.sweep(0.25, f, f * 1.3), 0.25), S.ad(0.25, 0.03, 2.0)),
                      rng.uniform(0.0, 0.8), 0.12) for f in (500, 620, 700, 820)])
    claps = S.layer([(clap(0.0, 0.2), rng.uniform(0.05, 1.2), rng.uniform(0.25, 0.5)) for _ in range(14)])
    return S.layer([(crowd, 0.0, 0.8), (hoots, 0.0, 1.0), (claps, 0.0, 1.0)])


def fanfare():
    """First place: a toy-trumpet fanfare in C."""
    seq = [(G4, 0.0, 0.14), (C5, 0.15, 0.14), (E5, 0.3, 0.14), (G5, 0.45, 0.3), (E5, 0.78, 0.12), (G5, 0.92, 0.7)]
    lead = S.layer([(horn(f, d), t, 0.9) for f, t, d in seq])
    under = S.layer([(horn(f, 0.7), 0.92, 0.5) for f in (C5, E5)])
    return S.layer([(lead, 0.0, 1.0), (under, 0.0, 1.0), (sparkles(10, 0.8, 88), 0.9, 0.4)])


def ribbon():
    return S.layer([(bell(G5, 0.6), 0.0, 0.7), (bell(C6, 0.8), 0.1, 1.0), (sparkles(5, 0.4, 89), 0.15, 0.4)])


# ---------------------------------------------------------------------------
# REGISTRY - (name, category, peak target dBFS, builder, loops)
#
# The targets ARE the mix: the game plays every file at unity. Loudness follows how often a
# sound plays, not how important it feels.
# ---------------------------------------------------------------------------

REGISTRY = [
    ("ui_tap", "ui", -22.0, ui_tap, False),
    ("ui_toggle", "ui", -21.0, ui_toggle, False),
    ("ui_nope", "ui", -16.0, ui_nope, False),
    ("toast", "ui", -19.0, toast, False),
    ("star", "reward", -9.0, star, False),
    ("buy", "reward", -8.0, buy, False),
    ("level_up", "reward", -7.0, level_up, False),
    ("trust_up", "reward", -7.0, trust_up, False),
    ("adopt", "reward", -5.0, adopt, False),
    ("build", "reward", -8.0, build, False),
    ("goodbye", "reward", -10.0, goodbye, False),
    ("dress", "pet", -14.0, dress, False),

    ("crayon", "draw", -17.0, crayon, True),
    ("eraser", "draw", -19.0, eraser, True),
    ("fill", "draw", -12.0, fill, False),
    ("undo", "draw", -16.0, undo, False),
    ("clear", "draw", -12.0, clear, False),
    ("dot", "draw", -18.0, dot, False),
    ("done", "draw", -10.0, done, False),

    # Every stride: well down in the mix.
    ("step", "pet", -23.0, step, False),
    ("hop", "pet", -17.0, hop, False),
    ("land", "pet", -19.0, land, False),
    ("flap", "pet", -20.0, flap, False),
    ("bubble", "pet", -19.0, bubble, False),
    ("munch", "pet", -12.0, munch, False),
    ("chew", "pet", -16.0, chew, False),
    ("sniff", "pet", -18.0, sniff, False),
    ("snore", "pet", -18.0, snore, False),
    ("heart", "pet", -17.0, heart, False),
    ("sparkle", "pet", -15.0, sparkle, False),
    ("splash", "pet", -12.0, splash, False),
    ("scratch", "pet", -16.0, scratch, False),
    ("splat", "pet", -13.0, splat, False),
    ("snip", "pet", -15.0, snip, False),
    ("scrub", "pet", -16.0, scrub, False),
    ("brush", "pet", -18.0, brush, False),
    ("shake", "pet", -13.0, shake, False),
    ("clean", "reward", -10.0, clean, False),
    # A bed under everything while it rains.
    ("rain", "pet", -25.0, rain, True),

    ("throw", "toy", -14.0, throw, False),
    ("bounce", "toy", -15.0, bounce, False),
    ("squeak", "toy", -12.0, squeak, False),
    ("thud", "toy", -14.0, thud, False),
    ("catch", "toy", -12.0, catch, False),
    ("tug", "toy", -16.0, tug, False),
    ("place", "toy", -14.0, place, False),
    ("pickup", "toy", -18.0, pickup, False),
    ("trampoline", "toy", -12.0, trampoline, False),
    ("drum", "toy", -12.0, drum, False),
    ("piano", "toy", -12.0, piano, False),
    ("slide", "toy", -12.0, slide, False),
    ("shiny", "toy", -14.0, shiny, False),

    ("count_tick", "contest", -9.0, count_tick, False),
    ("count_go", "contest", -5.0, count_go, False),
    ("good", "contest", -10.0, good, False),
    ("bad", "contest", -12.0, bad, False),
    ("jump", "contest", -14.0, jump, False),
    ("drum_beat", "contest", -10.0, drum_beat, False),
    ("heave", "contest", -10.0, heave, False),
    ("card_flip", "contest", -14.0, card_flip, False),
    ("correct", "contest", -10.0, correct, False),
    ("wrong", "contest", -12.0, wrong, False),
    ("camera", "contest", -10.0, camera, False),
    ("cheer", "contest", -8.0, cheer, False),
    ("fanfare", "contest", -4.0, fanfare, False),
    ("ribbon", "contest", -8.0, ribbon, False),
]
