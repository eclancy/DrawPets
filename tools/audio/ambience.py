# -*- coding: utf-8 -*-
"""A quiet bed of sound for each place - birds in the meadow, waves on the beach, drips in the
cave - each an eight-second seamless loop, mono, 22050 Hz, written to sfx/ambience/<place>.wav.

They sit well under everything else: a place should feel alive, not busy. Seamless because they
loop for as long as a kid stays: everything that rings past the end is folded back onto the
start, and the noise beds crossfade across the seam.
"""
from __future__ import division

import math
import os
import random

import synth as S
from band import note, toypiano

SEED = 9500
LOOP = 8.0


def seamless(buf, loop_secs=LOOP, xfade=0.6):
    """Folds whatever runs past loop_secs back onto the start, crossfading the seam."""
    n = S.n_samples(loop_secs)
    out = list(buf[:n]) + [0.0] * max(0, n - len(buf))
    tail = buf[n:]
    k = min(len(tail), S.n_samples(xfade))
    for i in range(len(tail)):
        if i < k:
            w = i / float(k)
            out[i] = out[i] * w + tail[i] * (1.0 - w)
        else:
            out[i % n] += tail[i]
    return out


def bed(cutoff, seed, q=0.7, kind="lowpass", lfo=0.125, depth=0.4, dur=LOOP + 0.6):
    """Filtered noise breathing slowly - wind, surf, room tone. The LFO period divides the loop."""
    v = S.osc("noise", 0, dur, seed=SEED + seed)
    v = S.lowpass(v, cutoff, q) if kind == "lowpass" else S.bandpass(v, cutoff, q)
    n = len(v)
    return [x * (1.0 - depth + depth * (0.5 + 0.5 * math.sin(S.TWO_PI * lfo * i / S.SR))) for i, x in enumerate(v)]


def events(fn, times, dur=LOOP + 1.5):
    """Places fn(i) at each time (seconds), on a buffer that runs a little past the loop."""
    buf = [0.0] * S.n_samples(dur)
    for i, t in enumerate(times):
        e = fn(i)
        off = S.n_samples(t)
        for j in range(min(len(e), len(buf) - off)):
            buf[off + j] += e[j]
    return buf


def chirp_call(seed, f=3000.0, notes=3):
    rng = random.Random(seed)
    parts = []
    t = 0.0
    for k in range(notes):
        d = rng.uniform(0.05, 0.1)
        f0 = f * rng.uniform(0.85, 1.2)
        tone = S.env_mul(S.osc("sine", S.sweep(d, f0, f0 * rng.uniform(1.1, 1.4), 0.7), d), S.ad(d, 0.005, 2.0))
        parts.append((tone, t, rng.uniform(0.6, 1.0)))
        t += d + rng.uniform(0.02, 0.06)
    return S.layer(parts)


def whistle_call(seed, f=1500.0):
    d = 0.35
    rng = random.Random(seed)
    a = S.env_mul(S.osc("sine", S.sweep(d, f, f * 0.8), d), S.adsr(d, 0.04, 0.05, 0.7, 0.12))
    b = S.env_mul(S.osc("sine", S.sweep(d, f * 0.8, f * 1.05), d), S.adsr(d, 0.04, 0.05, 0.7, 0.12))
    return S.layer([(a, 0.0, 1.0), (b, 0.4 + rng.uniform(0, 0.1), 0.9)])


def times(seed, count, spread=LOOP):
    rng = random.Random(SEED + seed)
    return sorted([rng.uniform(0.0, spread) for _ in range(count)])


def drip(i):
    f = 1500.0 + (i * 397 % 900)
    d = 0.3
    return S.env_mul(S.osc("sine", S.sweep(d, f * 1.4, f, 0.3), d), S.expdecay(S.n_samples(d), 14.0))


def croak(i):
    d = 0.28
    v = S.gate(S.osc("saw", 120 + (i % 3) * 25, d), 28.0, 0.5, seed=SEED + 40 + i)
    return S.env_mul(S.bandpass(v, 600, 1.5), S.adsr(d, 0.01, 0.03, 0.8, 0.06))


def cricket(i):
    d = 0.5
    v = S.gate(S.osc("sine", 4300 + (i % 4) * 150, d), 30.0, 0.4, seed=SEED + 60 + i)
    return S.env_mul(v, S.adsr(d, 0.02, 0.05, 0.9, 0.1))


def chime(i):
    f = note(("C6", "E6", "G6", "A6", "D6")[i % 5])
    return S.partials(f, [1.0, 2.76, 5.4], 1.6, amps=[1.0, 0.3, 0.12], decays=[2.5, 4.0, 7.0])


def sea_waves():
    v = bed(700, 1, 0.6, lfo=0.25, depth=0.85)
    return v


def place_meadow():
    birds = events(lambda i: chirp_call(SEED + i * 7, 3200.0, 3 + i % 3), times(1, 7))
    return S.mix(S.gain(bed(500, 2), 0.35), S.gain(birds, 0.5))


def place_forest():
    birds = events(lambda i: whistle_call(SEED + i * 11, 1300.0 + (i % 3) * 300), times(2, 5))
    peck = events(lambda i: S.layer([(S.env_mul(S.bandpass(S.osc("noise", 0, 0.02, seed=SEED + 70 + k), 1800, 3.0),
                                                S.expdecay(S.n_samples(0.02), 3.0)), k * 0.06, 0.8) for k in range(5)]),
                  times(3, 1))
    leaves = bed(2200, 3, 0.6, "band", 0.125, 0.7)
    return S.mix(S.gain(leaves, 0.3), S.gain(birds, 0.45), S.gain(peck, 0.3))


def place_beach():
    return S.gain(sea_waves(), 0.9)


def place_ocean():
    rumble = bed(380, 4, 0.7, lfo=0.125, depth=0.3)
    bubbles = events(lambda i: S.env_mul(S.osc("sine", S.sweep(0.12, 300 + i * 37 % 400, 900, 0.6), 0.12),
                                         S.ad(0.12, 0.005, 2.0)), times(4, 14))
    return S.mix(S.gain(rumble, 0.6), S.gain(bubbles, 0.35))


def place_mountains():
    wind = S.osc("noise", 0, LOOP + 0.6, seed=SEED + 5)
    wind = S.bandpass(wind, [700 + 500 * (0.5 + 0.5 * math.sin(S.TWO_PI * 0.125 * i / S.SR)) for i in range(len(wind))], 2.5)
    return S.gain(wind, 0.9)


def place_desert():
    return S.gain(bed(1200, 6, 0.8, "band", 0.25, 0.6), 0.7)


def place_jungle():
    bugs = events(cricket, times(7, 6))
    birds = events(lambda i: chirp_call(SEED + 200 + i, 2400.0, 4), times(8, 4))
    frogs = events(croak, times(9, 3))
    return S.mix(S.gain(bed(600, 7), 0.25), S.gain(bugs, 0.15), S.gain(birds, 0.4), S.gain(frogs, 0.3))


def place_cave():
    drips = events(drip, times(10, 6))
    drips = S.reverb(drips, size=0.85, damp=0.3, mix=0.45)
    hum = S.gain(S.lowpass(S.osc("noise", 0, LOOP + 0.6, seed=SEED + 11), 150), 0.5)
    return S.mix(drips, hum)


def place_volcano():
    rumble = bed(160, 12, 0.8, lfo=0.125, depth=0.5)
    crackles = events(lambda i: S.env_mul(S.gate(S.highpass(S.osc("noise", 0, 0.2, seed=SEED + 90 + i), 2000), 90.0, 0.3,
                                                  seed=SEED + 95 + i), S.ad(0.2, 0.002, 2.0)), times(12, 10))
    return S.mix(S.gain(rumble, 0.9), S.gain(crackles, 0.25))


def place_swamp():
    crickets = events(cricket, times(13, 9))
    frogs = events(croak, times(14, 5))
    return S.mix(S.gain(bed(450, 13), 0.25), S.gain(crickets, 0.2), S.gain(frogs, 0.45))


def place_sky():
    chimes = events(chime, times(15, 5))
    return S.mix(S.gain(bed(1500, 15, 0.5, "band", 0.125, 0.6), 0.4), S.gain(chimes, 0.25))


def place_moon():
    n = S.n_samples(LOOP + 0.6)
    hum = [0.5 * math.sin(S.TWO_PI * 62.5 * i / S.SR) + 0.4 * math.sin(S.TWO_PI * 63.0 * i / S.SR) for i in range(n)]
    bleeps = events(lambda i: S.env_mul(S.osc("sine", 1200 + 300 * (i % 3), 0.12), S.ad(0.12, 0.01, 2.0)), times(16, 4))
    return S.mix(S.gain(S.lowpass(hum, 400), 0.4), S.gain(S.reverb(bleeps, 0.8, 0.4, 0.4), 0.2))


def place_castle():
    birds = events(lambda i: chirp_call(SEED + 300 + i, 2800.0, 3), times(17, 5))
    flag = S.gain(S.gate(bed(900, 17, 0.8, "band", 0.25, 0.5), 6.0, 0.6, seed=SEED + 18), 0.25)
    return S.mix(S.gain(bed(500, 18), 0.3), S.gain(birds, 0.45), flag)


def place_candy():
    box = events(lambda i: toypiano(note(("C6", "E6", "G6", "C7", "D6", "A6")[i % 6]), 1.0), times(19, 9))
    fizz = S.gain(S.highpass(S.osc("noise", 0, LOOP + 0.6, seed=SEED + 19), 6000), 0.06)
    return S.mix(S.gain(box, 0.3), fizz)


PLACES = [
    ("meadow", place_meadow), ("forest", place_forest), ("beach", place_beach), ("ocean", place_ocean),
    ("mountains", place_mountains), ("desert", place_desert), ("jungle", place_jungle), ("cave", place_cave),
    ("volcano", place_volcano), ("swamp", place_swamp), ("sky", place_sky), ("moon", place_moon),
    ("castle", place_castle), ("candy", place_candy),
]


# Steady beds (a hum, wind, surf) are louder for their peak than ones made of separate calls, so
# they are set lower to sit at the same loudness as the rest.
TARGETS = {"moon": -29.0, "mountains": -23.0, "desert": -22.0, "beach": -21.0}


def build_all(out_dir, filters=None, target_db=-20.0):
    results = []
    for name, fn in PLACES:
        if filters and not any(f in name for f in filters):
            continue
        buf = seamless(S.dc_block(fn()))
        buf = S.normalize(buf, 10.0 ** (TARGETS.get(name, target_db) / 20.0))
        preroll = 64
        half = S.halve_rate(buf[-preroll:] + buf)[preroll // 2:]
        path = os.path.join(out_dir, name + ".wav")
        pk, rm, secs, clipped = S.write_wav_loop(path, half, sr=S.SR // 2)
        results.append((name, buf))
        print("ambience %-9s %4.1f s  peak %5.1f dBFS  rms %5.1f dBFS%s" % (name, secs, pk, rm,
              "  CLIPPED" if clipped else ""))
    return results
