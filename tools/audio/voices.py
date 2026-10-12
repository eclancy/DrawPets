# -*- coding: utf-8 -*-
"""The base sounds a kid starts their pet's voice from (or a drawn toy's sound): one function
each, written to sfx/voices/<name>.f32.

These are not played as they are. The game reads their samples and remakes them with the kid's
settings - higher, deeper, faster, slower, wobbly, echoey, bendy, robot, backwards (Voice.render)
- so they are stored as raw 32-bit float samples, mono, 22050 Hz, not as WAVs. Godot compresses
imported WAVs (QOA), and compressed audio cannot be read back as samples. The export preset
includes *.f32 so they ship.

Each is one call - one bark, one meow - because the game repeats it, varied, to make a pet
"talk". Short and dry on purpose: echo is one of the kid's own settings.
"""
from __future__ import division

import array
import math
import os

import synth as S

SEED = 9100
RATE = S.SR // 2


def formant(buf, dur, f1, f2, q=3.0, mix2=0.6):
    """Two resonances, like a mouth shape: what turns a buzz into a vowel."""
    return S.mix(S.bandpass(buf, f1, q), S.gain(S.bandpass(buf, f2, q), mix2))


def vib(f, rate, depth, dur):
    return [a * (1.0 + depth * math.sin(S.TWO_PI * rate * i / S.SR)) for i, a in enumerate(S._ctl(f, S.n_samples(dur)))]


def bark():
    dur = 0.26
    f = S.sweep(dur, 330, 190, 0.7)
    buzz = S.mix(S.osc("saw", f, dur), S.gain(S.osc("noise", 0, dur, seed=SEED + 1), 0.5))
    v = formant(buzz, dur, 650, 1300, 2.5)
    return S.drive(S.env_mul(v, S.adsr(dur, 0.006, 0.05, 0.7, 0.1)), 1.8)


def meow():
    dur = 0.6
    n = S.n_samples(dur)
    f = vib(S.ramp(n // 3, 560, 760, 0.6) + S.ramp(n - n // 3, 760, 520, 1.2), 6.0, 0.012, dur)
    buzz = S.osc("saw", f, dur)
    mouth = S.bandpass(buzz, S.ramp(n // 3, 1700, 1100) + S.ramp(n - n // 3, 1100, 800), 3.0)
    return S.env_mul(S.mix(mouth, S.gain(S.lowpass(buzz, 900), 0.4)), S.adsr(dur, 0.04, 0.1, 0.8, 0.18))


def chirp():
    def one(d):
        return S.env_mul(S.osc("sine", S.sweep(d, 2100, 3600, 0.7), d), S.ad(d, 0.004, 2.2))
    return S.layer([(one(0.07), 0.0, 1.0), (one(0.08), 0.09, 0.9)])


def squeak():
    dur = 0.16
    f = vib(S.sweep(dur, 1900, 2500, 0.6), 30.0, 0.03, dur)
    return S.env_mul(S.osc("sine", f, dur), S.adsr(dur, 0.01, 0.03, 0.8, 0.05))


def moo():
    dur = 0.95
    n = S.n_samples(dur)
    f = S.sweep(dur, 150, 112, 0.8)
    buzz = S.osc("saw", f, dur)
    mouth = S.lowpass(buzz, S.ramp(n // 4, 300, 900) + S.ramp(n - n // 4, 900, 420), 1.6)
    return S.env_mul(mouth, S.adsr(dur, 0.08, 0.1, 0.85, 0.25))


def roar():
    dur = 0.8
    f = vib(S.sweep(dur, 170, 115, 0.8), 9.0, 0.03, dur)
    buzz = S.mix(S.osc("saw", f, dur), S.gain(S.osc("noise", 0, dur, seed=SEED + 2), 0.8))
    v = S.lowpass(S.drive(buzz, 2.5), S.sweep(dur, 1600, 700), 1.2)
    return S.env_mul(v, S.adsr(dur, 0.05, 0.15, 0.75, 0.3))


def hoot():
    def one(d, f):
        return S.env_mul(S.osc("sine", vib(f, 5.0, 0.01, d), d), S.adsr(d, 0.05, 0.05, 0.8, 0.12))
    return S.layer([(one(0.22, 430), 0.0, 1.0), (one(0.32, 400), 0.28, 1.0)])


def ribbit():
    def one(d, f):
        buzz = S.gate(S.osc("saw", f, d), 32.0, 0.5, seed=SEED + 3)
        return S.env_mul(S.bandpass(buzz, 900, 2.0), S.adsr(d, 0.01, 0.03, 0.8, 0.05))
    return S.layer([(one(0.14, 210), 0.0, 1.0), (one(0.16, 240), 0.18, 1.0)])


def quack():
    dur = 0.26
    v = S.osc("square", S.sweep(dur, 520, 400, 0.8), dur)
    v = formant(v, dur, 1100, 2400, 4.0, 0.5)
    return S.env_mul(S.drive(v, 1.6), S.adsr(dur, 0.005, 0.05, 0.75, 0.1))


def oink():
    dur = 0.3
    v = S.mix(S.osc("square", S.sweep(dur, 260, 220), dur), S.gain(S.osc("noise", 0, dur, seed=SEED + 4), 0.6))
    v = S.gate(formant(v, dur, 800, 1600, 3.0), 45.0, 0.7, seed=SEED + 5)
    return S.env_mul(v, S.adsr(dur, 0.01, 0.05, 0.8, 0.1))


def baa():
    dur = 0.62
    f = vib(S.sweep(dur, 400, 360), 7.5, 0.05, dur)
    v = formant(S.osc("saw", f, dur), dur, 850, 1500, 3.0)
    return S.env_mul(v, S.adsr(dur, 0.03, 0.08, 0.8, 0.2))


def trumpet():
    dur = 0.72
    n = S.n_samples(dur)
    f = vib(S.ramp(n // 3, 560, 900, 0.5) + S.ramp(n - n // 3, 900, 760), 6.0, 0.02, dur)
    v = S.lowpass(S.drive(S.osc("saw", f, dur), 2.0), 3200, 1.0)
    return S.env_mul(v, S.adsr(dur, 0.03, 0.1, 0.85, 0.2))


def purr():
    dur = 0.95
    rumble = S.lowpass(S.osc("noise", 0, dur, seed=SEED + 6), 700)
    rumble = S.mix(rumble, S.gain(S.osc("saw", 55.0, dur), 0.3))
    return S.env_mul(S.tremolo(rumble, 26.0, 0.9), S.adsr(dur, 0.1, 0.1, 0.9, 0.25))


def beep():
    def one(d, f):
        return S.env_mul(S.lowpass(S.osc("square", f, d), 3000), S.adsr(d, 0.004, 0.02, 0.9, 0.02))
    return S.layer([(one(0.12, 880), 0.0, 1.0), (one(0.16, 660), 0.15, 1.0)])


def gurgle():
    import random
    rng = random.Random(SEED + 7)
    blips = []
    for i in range(7):
        f = rng.uniform(250, 700)
        d = rng.uniform(0.05, 0.09)
        b = S.env_mul(S.osc("sine", S.sweep(d, f, f * 1.8, 0.6), d), S.ad(d, 0.004, 2.0))
        blips.append((b, i * 0.07 + rng.uniform(0, 0.02), rng.uniform(0.6, 1.0)))
    return S.layer(blips)


def boing():
    dur = 0.45
    spring = S.osc("sine", S.sweep(dur, 190, 580, 0.7), dur)
    wob = S.osc("sine", 22.0, dur)
    spring = [a * (0.75 + 0.25 * b) for a, b in zip(spring, wob)]
    return S.env_mul(spring, S.ad(dur, 0.005, 2.5))


def trill():
    dur = 0.5
    f = vib(S.sweep(dur, 800, 1100), 24.0, 0.12, dur)
    return S.env_mul(S.osc("tri", f, dur), S.adsr(dur, 0.02, 0.05, 0.85, 0.12))


def honk():
    dur = 0.36
    v = formant(S.osc("saw", S.sweep(dur, 340, 310), dur), dur, 1000, 2100, 3.5)
    return S.env_mul(S.drive(v, 2.2), S.adsr(dur, 0.01, 0.05, 0.8, 0.1))


VOICES = [
    ("bark", bark), ("meow", meow), ("chirp", chirp), ("squeak", squeak), ("moo", moo),
    ("roar", roar), ("hoot", hoot), ("ribbit", ribbit), ("quack", quack), ("oink", oink),
    ("baa", baa), ("trumpet", trumpet), ("purr", purr), ("beep", beep), ("gurgle", gurgle),
    ("boing", boing), ("trill", trill), ("honk", honk),
]


def write_f32(path, buf):
    d = os.path.dirname(path)
    if d and not os.path.isdir(d):
        os.makedirs(d)
    a = array.array("f", buf)
    with open(path, "wb") as f:
        f.write(a.tostring())


def build_all(out_dir, filters=None):
    results = []
    for name, fn in VOICES:
        if filters and not any(f in name for f in filters):
            continue
        buf = S.normalize(S.fade(S.dc_block(fn()), 0.0004, 0.008), 0.89)
        half = S.halve_rate(buf)
        write_f32(os.path.join(out_dir, name + ".f32"), half)
        results.append((name, buf))
        print("voice %-8s %5.2f s" % (name, len(half) / float(RATE)))
    return results
