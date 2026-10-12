# -*- coding: utf-8 -*-
"""The instruments and sequencer for DrawPets' music - copied from DrawFight's
tools/audio/music.py (which took the sequencer, note cache and wrapped tails from
WizardSurvivors). DrawPets' own tracks are in music.py; this file is only the band.

Every instrument takes (frequency, seconds) and returns a mono buffer. render() runs past the
end of a loop and folds the overhang back onto the start, so a ringing note crosses the seam
instead of being cut at it.
"""
from __future__ import division

import math
import os
import random
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import synth as S

_PITCH_CLASS = {
    "C": -9, "C#": -8, "Db": -8, "D": -7, "D#": -6, "Eb": -6, "E": -5, "E#": -4,
    "F": -4, "F#": -3, "Gb": -3, "G": -2, "G#": -1, "Ab": -1,
    "A": 0, "A#": 1, "Bb": 1, "B": 2, "B#": 3,
}


def note(name):
    """Scientific pitch notation to Hz. note("A4") is 440."""
    i = len(name)
    while i > 0 and (name[i - 1].isdigit() or name[i - 1] == "-"):
        i -= 1
    return 440.0 * (2.0 ** ((_PITCH_CLASS[name[:i]] + (int(name[i:]) - 4) * 12) / 12.0))


def _oct(name, k):
    """The same note k octaves away."""
    i = len(name)
    while i > 0 and name[i - 1].isdigit():
        i -= 1
    return name[:i] + str(int(name[i:]) + k)


# ---------------------------------------------------------------------------
# instruments - each takes (frequency, seconds) and returns a buffer
# ---------------------------------------------------------------------------

def _phase(freq):
    """A start phase that differs from note to note. Chord notes struck together all starting
    at phase zero line their first edges up into one spike, which then sets the loop's peak."""
    return (freq * 0.6180339887) % 1.0


def _glide(freq, n, start, secs):
    """A pitch curve that starts at freq * start and settles on freq."""
    k = min(n, S.n_samples(secs))
    return S.ramp(k, freq * start, freq, 0.5) + [freq] * (n - k)


def _vibrato(f, rate, depth, delay):
    """Vibrato that only arrives once a note has been held - a singer's, not a siren's."""
    out = list(f)
    d0 = S.n_samples(delay)
    grow = S.SR * 0.2
    for i in xrange(d0, len(f)):
        t = i - d0
        out[i] = f[i] * (1.0 + depth * min(1.0, t / grow) * math.sin(S.TWO_PI * rate * t / S.SR))
    return out


def _pluck(freq, dur, bright, t60, seed):
    """Karplus-Strong: a burst of noise going round a loop one period long, losing its top
    end each time round. It is a real plucked string's physics, so it sounds like one."""
    n = S.n_samples(dur)
    loop = S.SR / freq - 0.5           # the two-point average below adds half a sample
    whole = int(loop)
    frac = loop - whole
    rng = random.Random(seed)
    burst = S.lowpass([rng.uniform(-1.0, 1.0) for _ in xrange(whole + 2)], bright, 0.7)
    mean = sum(burst) / len(burst)
    burst = [v - mean for v in burst]  # DC in the burst would never decay out of the loop
    g = 0.001 ** (1.0 / (t60 * freq))
    a, b, c = 0.5 * g * (1.0 - frac), 0.5 * g, 0.5 * g * frac
    y = [0.0] * n
    nb = len(burst)
    for i in xrange(n):
        v = burst[i] if i < nb else 0.0
        j = i - whole
        if j >= 2:
            v += a * y[j] + b * y[j - 1] + c * y[j - 2]
        elif j >= 0:
            v += a * y[j]
        y[i] = v
    # Left raw, the first instant of every strum - the burst - is the loudest thing in the
    # track and sets the peak the whole loop is scaled to. Saturating it and giving it a few
    # milliseconds of rise brings the ring up to meet it. The end is damped by the next strum,
    # not cut, so a chop is not a click.
    y = S.drive(S.normalize(y, 1.0), 2.0)
    ka = min(n, S.n_samples(0.003))
    k = min(n - ka, S.n_samples(0.025))
    return S.env_mul(y, S.ramp(ka, 0.0, 1.0) + [1.0] * (n - ka - k) + S.ramp(k, 1.0, 0.0))


# --- the menu band ---------------------------------------------------------

def uke(freq, dur):
    """A ukulele string. Nylon, so the burst is soft and the ring is short."""
    return _pluck(freq, dur, 2400.0, 1.0, int(freq * 10))


def upright(freq, dur):
    """The walking bass: round, with a thump at the front - a string pulled hard starts sharp.
    More overtone than fundamental, because a TV speaker cannot play 55 Hz and the ear finds
    the note from its harmonics anyway."""
    n = S.n_samples(dur)
    f = _glide(freq, n, 1.025, 0.03)
    v = S.mix(S.gain(S.osc("sine", f, dur), 0.6), S.gain(S.osc("tri", f, dur), 0.6),
              S.gain(S.osc("saw", f, dur), 0.3))
    v = S.lowpass(v, S.sweep(dur, 2200, 700, 0.4), 0.9)
    return S.env_mul(v, S.adsr(dur, 0.01, 0.18, 0.45, min(0.08, dur * 0.3)))


def whistle(freq, dur):
    """The menu tune, whistled: a near-pure tone with breath in it, scooping up into each note
    the way lips do."""
    n = S.n_samples(dur)
    f = _vibrato(_glide(freq, n, 0.955, 0.06), 5.2, 0.007, 0.18)
    tone = S.mix(S.osc("sine", f, dur), S.gain(S.osc("sine", [x * 2.0 for x in f], dur), 0.05))
    breath = S.gain(S.bandpass(S.osc("noise", 0, dur, seed=241), freq, 5.0), 1.2)
    return S.env_mul(S.mix(tone, breath), S.adsr(dur, 0.025, 0.08, 0.85, min(0.07, dur * 0.3)))


def toypiano(freq, dur):
    """A toy piano: struck metal rods, so the overtone is nowhere near harmonic and dies first.
    That plink is the whole instrument. Rings the same length whatever the note's value."""
    v = S.partials(freq, [1.0, 2.0, 6.27], 1.0, amps=[1.0, 0.1, 0.3], decays=[5.5, 8.0, 35.0])
    tick = S.highpass(S.osc("noise", 0, 0.004, seed=242), 3000)
    return S.mix(v, S.gain(S.env_mul(tick, S.expdecay(len(tick), 3.0)), 0.15))


def snap(freq, dur):
    """A finger snap - the menu's backbeat, much lighter than a snare."""
    n = S.n_samples(dur)
    return S.env_mul(S.bandpass(S.osc("noise", 0, dur, seed=212), 2800, 1.4), S.expdecay(n, 22.0))


def shaker(freq, dur):
    """A shaker. A soft front and a dark centre let it carry the swing without hissing, which
    matters in a loop that plays for minutes."""
    d = 0.08
    n = S.n_samples(d)
    k = S.n_samples(0.012)
    env = S.ramp(k, 0.0, 1.0) + S.decay(n - k, 2.5)
    return S.env_mul(S.bandpass(S.osc("noise", 0, d, seed=243), 5000, 1.2), env)


# --- the battle band -------------------------------------------------------

def _chip(freq, dur, scoop, scoop_secs):
    n = S.n_samples(dur)
    f = _vibrato(_glide(freq, n, scoop, scoop_secs), 6.0, 0.006, 0.16)
    # A 25% pulse averages half below zero; lift it, or every note starts with a thump.
    p = [v + 0.5 for v in S.osc("pulse", f, dur, duty=0.25)]
    v = S.mix(S.gain(p, 0.6), S.gain(S.osc("tri", f, dur), 0.5))
    v = S.lowpass(v, 3000, 0.8)
    return S.env_mul(v, S.adsr(dur, 0.004, 0.08, 0.6, min(0.05, dur * 0.3)))


def chip(freq, dur):
    """The battle lead: a narrow pulse like an old handheld's, the edge taken off it so it never
    gets shrill under the hit sounds, and a tiny scoop into every note."""
    return _chip(freq, dur, 0.97, 0.018)


def chipslide(freq, dur):
    """The lead's accented notes slide up a whole step - the cartoon 'bwee'."""
    return _chip(freq, dur, 0.89, 0.07)


def horn(freq, dur):
    """The answering voice: a cartoon brass section in one - two detuned saws whose filter
    opens as the note speaks, then closes, which is the 'bwah' of a horn."""
    n = S.n_samples(dur)
    f = _glide(freq, n, 0.975, 0.045)
    ph = _phase(freq)
    v = S.mix(S.osc("saw", f, dur, phase=ph),
              S.gain(S.osc("saw", [x * 1.007 for x in f], dur, phase=(ph + 0.37) % 1.0), 0.8))
    k = min(n, S.n_samples(0.04))
    v = S.lowpass(v, S.ramp(k, 500, 2600, 0.7) + S.ramp(n - k, 2600, 1100, 0.6), 1.2)
    return S.env_mul(S.drive(v, 1.6), S.adsr(dur, 0.012, 0.12, 0.7, min(0.06, dur * 0.3)))


def skank(freq, dur):
    """One note of the offbeat chop: clipped and hollow, so it is felt as rhythm, not harmony."""
    ph = _phase(freq)
    v = S.mix(S.gain(S.osc("square", freq, dur, phase=ph), 0.5),
              S.gain(S.osc("saw", freq * 2.0, dur, phase=(ph + 0.3) % 1.0), 0.2))
    v = S.highpass(S.lowpass(v, 2600, 0.9), 250)
    return S.env_mul(v, S.ad(dur, 0.002, 3.5))


def _bounce(freq, dur, fall, hold):
    """The battle bass: square and sine with a filter snap, and a pitch that sags at the tail.
    Weighted to the square's overtones rather than the sine's fundamental, for the same reason
    as the menu's bass: the fundamental is mostly headroom spent on nothing a TV can play."""
    n = S.n_samples(dur)
    k = int(n * hold)
    f = [freq] * k + S.ramp(n - k, freq, freq * fall, 1.6)
    v = S.mix(S.gain(S.osc("square", f, dur), 0.55), S.gain(S.osc("sine", f, dur), 0.5))
    v = S.lowpass(v, S.sweep(dur, 2000, 450, 0.5), 1.3)
    # A 12 ms rise is still a pluck, and it lets the kick's click land first instead of on
    # top of the bass's own front - the two together were the loudest moment of every bar.
    return S.drive(S.env_mul(v, S.ad(dur, 0.012, 1.3)), 1.8)


def bass(freq, dur):
    """Most bass notes droop a few cents as they end - just enough to sound like rubber."""
    return _bounce(freq, dur, 0.97, 0.5)


def bassdrop(freq, dur):
    """The last note of a phrase falls properly: 'bwow'."""
    return _bounce(freq, dur, 0.75, 0.3)


def bassfall(freq, dur):
    """The breakdown's first hit sinks a whole octave - the floor going out from under it."""
    return _bounce(freq, dur, 0.5, 0.05)


def clap(freq, dur):
    """Three hands not quite together, then the room - the spread is what makes it a clap."""
    parts = []
    for k, off in enumerate((0.0, 0.009, 0.018)):
        b = S.osc("noise", 0, 0.01, seed=231 + k)
        parts.append((S.env_mul(b, S.expdecay(len(b), 3.0)), off, 0.9))
    tail = S.osc("noise", 0, 0.18, seed=234)
    parts.append((S.env_mul(tail, S.expdecay(len(tail), 8.0)), 0.026, 0.8))
    return S.highpass(S.bandpass(S.layer(parts), 1250, 1.0), 400)


def block(freq, dur):
    """A woodblock: a hollow knock with only a hint of pitch, gone in a few hundredths."""
    v = S.partials(freq, [1.0, 2.57], 0.1, amps=[1.0, 0.3], decays=[9.0, 14.0])
    knock = S.bandpass(S.osc("noise", 0, 0.006, seed=235), freq * 2.0, 2.0)
    return S.mix(v, S.gain(S.env_mul(knock, S.expdecay(len(knock), 3.0)), 0.5))


def tom(freq, dur):
    """A tom for the fills, tuned to the chord it falls through."""
    d = 0.32
    n = S.n_samples(d)
    body = S.env_mul(S.osc("sine", S.ramp(n, freq * 1.6, freq, 0.3), d), S.expdecay(n, 6.5))
    stick = S.env_mul(S.bandpass(S.osc("noise", 0, d, seed=236), 1800, 1.0), S.expdecay(n, 40.0))
    return S.drive(S.mix(body, S.gain(stick, 0.5)), 1.4)


def slidewhistle(freq, dur):
    """A slide whistle rising a fifth to freq and holding it - 'fweeep', back to the top."""
    n = S.n_samples(dur)
    k = int(n * 0.85)
    f = _vibrato(S.ramp(k, freq / 1.5, freq, 0.8) + [freq] * (n - k), 7.0, 0.01, 0.0)
    v = S.mix(S.osc("sine", f, dur), S.gain(S.osc("sine", [x * 2.0 for x in f], dur), 0.08),
              S.gain(S.highpass(S.osc("noise", 0, dur, seed=237), 3000), 0.04))
    return S.env_mul(v, S.adsr(dur, 0.04, 0.05, 0.9, min(0.06, dur * 0.2)))


def kick(freq, dur):
    """Short, with a click on the front: it is heard by its knock, not its boom, so it can
    punch without setting the peak of the whole loop."""
    n = S.n_samples(dur)
    body = S.env_mul(S.osc("sine", S.sweep(dur, 160, 50, 0.3), dur), S.expdecay(n, 9.0))
    click = S.bandpass(S.osc("noise", 0, 0.005, seed=215), 3000, 1.0)
    click = S.env_mul(click, S.expdecay(len(click), 3.0))
    return S.drive(S.mix(body, S.gain(click, 0.6)), 1.5)


def snare(freq, dur):
    n = S.n_samples(dur)
    noise = S.env_mul(S.bandpass(S.osc("noise", 0, dur, seed=211), 2200, 0.8), S.expdecay(n, 9.0))
    body = S.env_mul(S.osc("tri", S.sweep(dur, 240, 170), dur), S.expdecay(n, 14.0))
    return S.mix(noise, S.gain(body, 0.6))


def hat(freq, dur):
    n = S.n_samples(dur)
    return S.env_mul(S.highpass(S.osc("noise", 0, dur, seed=213), 7000), S.expdecay(n, 14.0))


def crash(freq, dur):
    n = S.n_samples(dur)
    return S.env_mul(S.highpass(S.osc("noise", 0, dur, seed=214), 4500), S.expdecay(n, 4.5))


# ---------------------------------------------------------------------------
# sequencer
# ---------------------------------------------------------------------------

_CACHE = {}


def _voice(instrument, freq, dur):
    """One note, rendered once. Velocity is applied by the caller so it never splits the key."""
    key = (instrument.__name__, round(freq, 3), round(dur, 4))
    if key not in _CACHE:
        _CACHE[key] = instrument(freq, dur)
    return _CACHE[key]


def render(events, bpm, total_beats, tail_beats=8):
    """events: (beat, instrument, note name or None, length in beats, velocity)."""
    beat_s = 60.0 / bpm
    loop_n = S.n_samples(total_beats * beat_s)
    full_n = S.n_samples((total_beats + tail_beats) * beat_s)
    buf = [0.0] * full_n
    for beat, instrument, name, dur_beats, vel in events:
        v = _voice(instrument, note(name) if name else 0.0, dur_beats * beat_s)
        off = S.n_samples(beat * beat_s)
        for i in xrange(min(len(v), full_n - off)):
            buf[off + i] += v[i] * vel
    out = buf[:loop_n]
    for i in xrange(loop_n, full_n):
        out[(i - loop_n) % loop_n] += buf[i]
    return out


def chord_at(chart, beat):
    """The chord symbol sounding at a beat. A chart bar is one symbol, or two for half a bar each."""
    bar = chart[int(beat // 4) % len(chart)]
    if isinstance(bar, tuple):
        return bar[0] if beat % 4 < 2 else bar[1]
    return bar


