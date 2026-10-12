# -*- coding: utf-8 -*-
"""DrawPets' three music loops, built on band.py (DrawFight's instruments and sequencer).

    python tools/audio/build.py --music

Writes music/home.wav, music/create.wav and music/contest.wav: mono, 22050 Hz, each a seamless
whole-file loop (a 'smpl' chunk marks it for Godot's importer).

All three are in C major, the key of every chime in sfx.py, so a reward bell always agrees with
whatever is playing.

  home    - homes, the shop, the calendar. A swung ukulele with a whistled tune and a toy piano
            answering, a walking bass, snaps and a shaker. Light: it plays for a long time.
  create  - drawing and fixing pets. A slow, straight toy-piano tune over plucked arpeggios -
            calm enough to concentrate to.
  contest - the competitions. A bouncy romp: a handheld-console lead calling, cartoon horns
            answering, offbeat chops, a bouncing bass and claps.

Nobody on this project can hear the result, so every part is written to rules that can be
checked on paper (the same as DrawFight's): chord tones on the strong beats, passing notes only
on the weak ones, no semitone rub between a tune and the chord under it.
"""
from __future__ import division

import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import synth as S
from band import (note, render, chord_at, uke, upright, whistle, toypiano, snap, shaker, chip, chipslide,
                  horn, skank, bass, bassdrop, clap, kick, hat, slidewhistle)

# Ukulele voicings, re-entrant G4 C4 E4 A4 tuning, as a player would finger them.
UKE = {
    "C": ["G4", "C4", "E4", "C5"], "Am": ["A4", "C4", "E4", "A4"], "F": ["A4", "C4", "F4", "A4"],
    "G": ["G4", "D4", "G4", "B4"], "G7": ["G4", "D4", "F4", "B4"], "E7": ["G#4", "D4", "E4", "B4"],
    "D7": ["A4", "D4", "F#4", "C5"], "Fm": ["G#4", "C4", "F4", "G#4"], "A7": ["G4", "C#4", "E4", "A4"],
    "Dm7": ["A4", "D4", "F4", "C5"], "Dm": ["A4", "D4", "F4", "A4"], "Em": ["G4", "E4", "G4", "B4"],
}
ROOT = {"C": "C3", "Am": "A2", "F": "F2", "G": "G2", "G7": "G2", "E7": "E2", "D7": "D3", "Fm": "F2",
        "A7": "A2", "Dm7": "D3", "Dm": "D3", "Em": "E2"}
FIFTH = {"C": "G2", "Am": "E3", "F": "C3", "G": "D3", "G7": "D3", "E7": "B2", "D7": "A2", "Fm": "C3",
         "A7": "E3", "Dm7": "A2", "Dm": "A2", "Em": "B2"}
TRIAD = {"C": ["C4", "E4", "G4"], "F": ["C4", "F4", "A4"], "G": ["B3", "D4", "G4"], "G7": ["B3", "D4", "F4"],
         "Am": ["C4", "E4", "A4"], "D7": ["C4", "F#4", "A4"], "Em": ["B3", "E4", "G4"]}


def _mixed(events, levels):
    return [(b, inst, p, d, v * levels[inst.__name__]) for b, inst, p, d, v in events]


def _bars(phrases):
    """[(bar, [(beat in bar, note, beats)])] -> [(beat, note, beats)]."""
    out = []
    for bar, notes in enumerate(phrases):
        for b, p, d in notes:
            out.append((bar * 4 + b, p, d))
    return out


# ---------------------------------------------------------------------------
# home: a swung ukulele tune, 100 BPM, sixteen bars.
#
# The A half walks round C - Am - F - G and leans on a secondary dominant (E7 into Am, D7 into
# G7). The B half opens on F, winks with the borrowed F minor, and comes home through A7 - Dm7
# - G7 - C, ending on G7, which pulls straight back into the C at the top.
# ---------------------------------------------------------------------------

HOME_BPM = 100.0
HOME_SWING = 0.62
HOME_CHART = ["C", "Am", "F", "G", "C", "E7", "Am", ("D7", "G7"),
              "F", "Fm", "C", "A7", "Dm7", "G7", "C", "G7"]
HOME_BEATS = 4 * len(HOME_CHART)
STRUM = [(0.0, "down", 0.9), (1.0, "down", 0.8), (1.5, "up", 0.55), (2.5, "up", 0.6), (3.0, "down", 0.8),
         (3.5, "up", 0.55)]
STRUM_SPREAD = 0.022

HOME_TUNE = _bars([
    [(0, "E5", 1), (1, "G5", .5), (1.5, "E5", .5), (2, "C5", 1.5)],
    [(0, "A4", 1), (1, "C5", .5), (1.5, "E5", .5), (2, "A5", 1.5)],
    [(0, "A5", .5), (.5, "G5", .5), (1, "F5", 1), (2, "C5", 1), (3, "A4", 1)],
    [(0, "B4", 1), (1, "D5", 1), (2, "G5", 2)],
    [(0, "E5", .5), (.5, "F5", .5), (1, "G5", 1), (2, "E5", 1), (3, "C5", 1)],
    [(0, "B4", 1), (1, "D5", .5), (1.5, "E5", .5), (2, "G#5", 2)],
    [(0, "A5", 1.5), (1.5, "G5", .5), (2, "E5", 1), (3, "C5", 1)],
    [(0, "F#5", 1), (1, "A5", 1), (2, "G5", 1), (3, "F5", 1)],
    [(0, "A5", 1), (1, "C6", 1), (2, "A5", 1), (3, "F5", 1)],
    [(0, "G#5", 1), (1, "F5", 1), (2, "C5", 2)],
    [(0, "E5", 1), (1, "G5", .5), (1.5, "C6", .5), (2, "G5", 2)],
    [(0, "C#5", 1), (1, "E5", 1), (2, "G5", 1), (3, "A5", 1)],
    [(0, "F5", 1.5), (1.5, "E5", .5), (2, "D5", 1), (3, "C5", 1)],
    [(0, "B4", 1), (1, "D5", 1), (2, "F5", 1), (3, "G5", 1)],
    [(0, "E5", 2), (2, "G5", 1), (3, "E5", 1)],
    [(0, "D5", 1), (1, "F5", 1), (2, "B4", 1), (3, "D5", 1)],
])
# The toy piano answers in the whistler's long notes - chord tones, high.
HOME_ANSWERS = [(3 * 4 + 2.5, "B5", .5), (3 * 4 + 3, "D6", 1), (7 * 4 + 2.5, "B5", .5),
                (11 * 4 + 2.5, "G5", .5), (11 * 4 + 3, "E6", 1), (14 * 4 + 1, "G5", .5), (14 * 4 + 1.5, "C6", .5)]
HOME_MIX = {"uke": 0.22, "upright": 0.7, "snap": 1.0, "shaker": 0.16, "whistle": 0.42, "toypiano": 0.3}


def home_swing(beat):
    whole = math.floor(beat)
    return whole + HOME_SWING if abs(beat - whole - 0.5) < 1e-6 else beat


def home_events():
    ev = []
    for bar in range(len(HOME_CHART)):
        b = bar * 4
        strum = STRUM
        if isinstance(HOME_CHART[bar], tuple):
            strum = sorted(STRUM + [(2.0, "down", 0.75)])
        for k, (off, stroke, vel) in enumerate(strum):
            at = home_swing(b + off)
            ring = (home_swing(b + strum[k + 1][0]) if k + 1 < len(strum) else b + 4) - at
            tones = UKE[chord_at(HOME_CHART, b + off)]
            strings = tones if stroke == "down" else list(reversed(tones))[:3]
            for s, t in enumerate(strings):
                ev.append((at + s * STRUM_SPREAD, uke, t, ring, vel))
        # A walking bass: root, fifth, root, and a step towards the next chord.
        c1 = chord_at(HOME_CHART, b)
        c3 = chord_at(HOME_CHART, b + 2)
        walk = [ROOT[c1], FIFTH[c1], ROOT[c3], FIFTH[c3]]
        for k, p in enumerate(walk):
            ev.append((b + k, upright, p, 0.8, 1.0 if k == 0 else 0.85))
        ev.append((b + 1.0, snap, "A4", 0.3, 1.0))
        ev.append((b + 3.0, snap, "A4", 0.3, 1.0))
        for e in range(8):
            ev.append((home_swing(b + e * 0.5), shaker, "A6", 0.08, 1.0 if e % 2 else 0.65))
    for beat, pitch, dur in HOME_TUNE:
        start = home_swing(beat)
        ev.append((start, whistle, pitch, (home_swing(beat + dur) - start) * 0.95, 1.0))
    for beat, pitch, dur in HOME_ANSWERS:
        ev.append((home_swing(beat), toypiano, pitch, dur, 1.0))
    return _mixed(ev, HOME_MIX)


# ---------------------------------------------------------------------------
# create: a slow toy-piano tune, 84 BPM, straight, sixteen bars. Plucked arpeggios underneath
# (the ukulele, one string at a time), a soft bass on one and three, a quiet shaker. No drums -
# it is music to draw to.
# ---------------------------------------------------------------------------

CREATE_BPM = 84.0
CREATE_CHART = ["C", "G", "Am", "F", "C", "F", "G", "C", "Am", "Em", "F", "C", "Dm", "G", "C", "G7"]
CREATE_BEATS = 4 * len(CREATE_CHART)
CREATE_TUNE = _bars([
    [(0, "G5", 1), (1, "E5", 1), (2, "C5", 1), (3, "E5", 1)],
    [(0, "D5", 1), (1, "B4", 1), (2, "G5", 2)],
    [(0, "C5", 1), (1, "E5", 1), (2, "A5", 1), (3, "G5", 1)],
    [(0, "A5", 1), (1, "F5", 1), (2, "C5", 2)],
    [(0, "E5", 1), (1, "G5", 1), (2, "C6", 1), (3, "G5", 1)],
    [(0, "A5", 1), (1, "C6", 1), (2, "A5", 1), (3, "F5", 1)],
    [(0, "G5", 1), (1, "B5", 1), (2, "D6", 1), (3, "B5", 1)],
    [(0, "C6", 2), (2, "G5", 2)],
    [(0, "A5", 1), (1, "E5", 1), (2, "C5", 1), (3, "E5", 1)],
    [(0, "B4", 1), (1, "E5", 1), (2, "G5", 2)],
    [(0, "A5", 1), (1, "G5", 1), (2, "F5", 1), (3, "C5", 1)],
    [(0, "E5", 2), (2, "C5", 2)],
    [(0, "D5", 1), (1, "F5", 1), (2, "A5", 1), (3, "F5", 1)],
    [(0, "G5", 1), (1, "D5", 1), (2, "B4", 2)],
    [(0, "C5", 1), (1, "E5", 1), (2, "G5", 1), (3, "C6", 1)],
    [(0, "B5", 1), (1, "G5", 1), (2, "F5", 1), (3, "D5", 1)],
])
CREATE_MIX = {"uke": 0.3, "upright": 0.55, "shaker": 0.1, "toypiano": 0.5}


def create_events():
    ev = []
    for bar in range(len(CREATE_CHART)):
        b = bar * 4
        ch = CREATE_CHART[bar]
        tones = sorted(UKE[ch], key=note)
        order = [tones[0], tones[1], tones[2], tones[3], tones[2], tones[1], tones[2], tones[3]]
        for e, t in enumerate(order):
            ev.append((b + e * 0.5, uke, t, 1.0, 0.8 if e % 2 else 1.0))
        ev.append((b, upright, ROOT[ch], 1.6, 1.0))
        ev.append((b + 2, upright, FIFTH[ch], 1.6, 0.85))
        for e in range(4):
            ev.append((b + e + 0.5, shaker, "A6", 0.08, 1.0))
    for beat, pitch, dur in CREATE_TUNE:
        ev.append((beat, toypiano, pitch, dur, 1.0))
    return _mixed(ev, CREATE_MIX)


# ---------------------------------------------------------------------------
# contest: a bouncy romp, 152 BPM, straight, sixteen bars.
#
#   A (8)  C C F G, C C F G7: the lead calls on C, the horns answer, the lead calls on F and G.
#   B (8)  Am F C G, Am F D7 G7: the lead runs up and down the chords; D7 - G7 at the end is the
#          cartoon "here we go again" back to the C at the top, thrown there by a slide whistle.
# ---------------------------------------------------------------------------

CONTEST_BPM = 152.0
CONTEST_CHART = ["C", "C", "F", "G", "C", "C", "F", "G7", "Am", "F", "C", "G", "Am", "F", "D7", "G7"]
CONTEST_BEATS = 4 * len(CONTEST_CHART)
SLIDE = True
CALL = {
    "C": [(0, "E5", .5), (.5, "G5", .5), (1, "C6", 1, SLIDE), (2.5, "G5", .5), (3, "E5", 1)],
    "F": [(0, "F5", .5), (.5, "A5", .5), (1, "C6", 1, SLIDE), (2.5, "A5", .5), (3, "F5", 1)],
    "G": [(0, "D5", .5), (.5, "G5", .5), (1, "B5", 1, SLIDE), (2.5, "G5", .5), (3, "D5", 1)],
}
ANSWER_C = [(1, "C5", .5), (1.5, "D5", .5), (2, "E5", .5), (2.5, "G5", 1.5)]
RUN = {"Am": ["A4", "C5", "E5", "A5"], "F": ["F4", "A4", "C5", "F5"], "C": ["C5", "E5", "G5", "C6"],
       "G": ["G4", "B4", "D5", "G5"], "D7": ["D5", "F#5", "A5", "C6"], "G7": ["G4", "B4", "D5", "F5"]}
CONTEST_MIX = {"chip": 0.4, "chipslide": 0.4, "horn": 0.25, "skank": 0.2, "bass": 0.5, "bassdrop": 0.5,
               "kick": 0.55, "clap": 0.45, "hat": 0.1, "slidewhistle": 0.3}


def contest_events():
    ev = []
    for bar in range(len(CONTEST_CHART)):
        b = bar * 4
        ch = CONTEST_CHART[bar]
        key = ch.rstrip("7") if ch in ("G7",) else ch
        # The band: offbeat chops, a bass bouncing between octaves, kick on one and three,
        # claps on two and four, hats on the eighths.
        for off in (0.5, 1.5, 2.5, 3.5):
            for t in TRIAD[ch]:
                ev.append((b + off, skank, t, 0.4, 1.0))
        root = ROOT[ch]
        up = root[:-1] + str(int(root[-1]) + 1)
        last = bar % 8 == 7
        for k, p in enumerate([root, up, root, up]):
            inst = bassdrop if last and k == 3 else bass
            ev.append((b + k, inst, p, 0.9, 1.0))
        ev.append((b, kick, "C2", 0.3, 1.0))
        ev.append((b + 2, kick, "C2", 0.3, 0.9))
        ev.append((b + 1, clap, "A4", 0.3, 1.0))
        ev.append((b + 3, clap, "A4", 0.3, 1.0))
        for e in range(8):
            ev.append((b + e * 0.5, hat, "A6", 0.1, 1.0 if e % 2 == 0 else 0.6))
        # The tune.
        if bar < 8:
            if bar in (1, 5):
                for o, p, d in ANSWER_C:
                    ev.append((b + o, horn, p, d * 0.9, 1.0))
            else:
                for n in CALL[key if key in CALL else "C"]:
                    inst = chipslide if len(n) > 3 else chip
                    ev.append((b + n[0], inst, n[1], n[2] * 0.9, 1.0))
        else:
            tones = RUN[ch]
            seq = tones + list(reversed(tones))
            for e, p in enumerate(seq):
                ev.append((b + e * 0.5, chip, p, 0.45, 1.0 if e % 2 == 0 else 0.8))
    ev.append((CONTEST_BEATS - 1.5, slidewhistle, "C6", 1.4, 1.0))
    return _mixed(ev, CONTEST_MIX)


# ---------------------------------------------------------------------------
# build
# ---------------------------------------------------------------------------

TRACKS = [
    # name, events, bpm, beats, reverb mix, peak dBFS
    ("home", home_events, HOME_BPM, HOME_BEATS, 0.2, -3.0),
    ("create", create_events, CREATE_BPM, CREATE_BEATS, 0.28, -3.0),
    ("contest", contest_events, CONTEST_BPM, CONTEST_BEATS, 0.12, -3.0),
]


def build_all(out_dir, only=None):
    if not os.path.isdir(out_dir):
        os.makedirs(out_dir)
    results = []
    for name, fn, bpm, beats, reverb_mix, target_db in TRACKS:
        if only and name not in only:
            continue
        buf = render(fn(), bpm, beats)
        n = len(buf)
        wet = S.reverb(buf + buf[:S.n_samples(1.5)], size=0.8, damp=0.45, mix=reverb_mix)
        looped = wet[:n]
        for i in range(n, len(wet)):
            looped[i - n] = wet[i]
        looped = S.normalize(S.dc_block(looped), 10.0 ** (target_db / 20.0))
        preroll = 64
        halved = S.halve_rate(looped[-preroll:] + looped)[preroll // 2:]
        path = os.path.join(out_dir, name + ".wav")
        pk, rm, secs, clipped = S.write_wav_loop(path, halved, sr=S.SR // 2)
        results.append((name, looped))
        print("music %-8s %5.1f s at %3.0f BPM  peak %5.1f dBFS  rms %5.1f dBFS  %4.1f MB%s"
              % (name, secs, bpm, pk, rm, os.path.getsize(path) / 1048576.0,
                 "  CLIPPED x%d" % clipped if clipped else ""))
    return results
