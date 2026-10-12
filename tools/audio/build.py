# -*- coding: utf-8 -*-
"""Generate every sound in the game. Run from the repo root (Python 2.7, standard library + PIL):

    python tools/audio/build.py                  # sound effects (sfx/*.wav)
    python tools/audio/build.py star buy         # only effects whose names contain these
    python tools/audio/build.py --voices         # pet-voice bases (sfx/voices/*.f32)
    python tools/audio/build.py --ambience       # place loops (sfx/ambience/*.wav)
    python tools/audio/build.py --music          # the three music loops (music/*.wav)
    python tools/audio/build.py --all            # everything
    python tools/audio/build.py --sheet ...      # also draw .shots/sound_<kind>.png

The generators are the source and the files are output. Never hand-edit a sound - edit its
builder and re-run, exactly as with the art (.ai/audio-direction.md). Then run Godot's import.

Every effect is normalised to the peak in its REGISTRY entry. Those numbers ARE the mix: the game
plays effects at unity, so balance is changed by editing one number in sfx.py, not at call sites.

Nobody on this project can hear the output, so --sheet draws each sound as a waveform over a
spectrogram: a pitch going up is a line going up, an echo is a repeat, a wobble is a wave.
"""
from __future__ import division

import cmath
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, HERE)

import synth as S

LONG_WARNING = 2.6
UNDER_TARGET_WARNING = 1.0


def db_to_linear(d):
    return 10.0 ** (d / 20.0)


def build_sfx(filters):
    import sfx
    out = os.path.join(ROOT, "sfx")
    entries = sfx.REGISTRY
    if filters:
        entries = [e for e in entries if any([f in e[0] for f in filters])]
    results = []
    for name, category, target_db, fn, loops in entries:
        buf = S.dc_block(fn())
        if not loops:
            buf = S.fade(buf, 0.0004, 0.006)
        buf = S.normalize(buf, db_to_linear(target_db))
        writer = S.write_wav_loop if loops else S.write_wav
        pk, rm, secs, clipped = writer(os.path.join(out, name + ".wav"), buf)
        notes = []
        if clipped:
            notes.append("CLIPPED x%d" % clipped)
        if secs > LONG_WARNING:
            notes.append("long")
        if pk < target_db - UNDER_TARGET_WARNING:
            notes.append("UNDER TARGET by %.1f dB" % (target_db - pk))
        print("%-12s %-8s %6.1fd %6.1fd %5.2fs %s" % (name, category, pk, rm, secs, ", ".join(notes)))
        results.append((name, buf, S.SR))
    return results


# ---------------------------------------------------------------------------
# the sheet
# ---------------------------------------------------------------------------

def _fft(x):
    n = len(x)
    if n <= 1:
        return x
    even = _fft(x[0::2])
    odd = _fft(x[1::2])
    out = [0j] * n
    for k in range(n // 2):
        t = cmath.exp(-2j * math.pi * k / n) * odd[k]
        out[k] = even[k] + t
        out[k + n // 2] = even[k] - t
    return out


def spectrogram(buf, sr, cols=140, size=512, top_hz=8000.0):
    window = [0.5 - 0.5 * math.cos(2 * math.pi * i / (size - 1)) for i in range(size)]
    bins = int(top_hz / (sr / float(size)))
    hop = max(1, (len(buf) - size) // cols) if len(buf) > size else size
    frames = []
    pos = 0
    while pos + size <= len(buf) and len(frames) < cols:
        seg = [buf[pos + i] * window[i] for i in range(size)]
        spec = _fft([complex(v, 0) for v in seg])
        frames.append([20.0 * math.log10(abs(spec[b]) + 1e-6) for b in range(bins)])
        pos += hop
    return frames


def draw_sheet(results, path):
    from PIL import Image, ImageDraw
    cell_w, spec_h, wave_h, label_h = 200, 110, 40, 16
    cols = 6
    rows = int(math.ceil(len(results) / float(cols)))
    img = Image.new("RGB", (cols * cell_w, rows * (spec_h + wave_h + label_h + 8)), (246, 241, 228))
    d = ImageDraw.Draw(img)
    for idx, (name, buf, sr) in enumerate(results):
        ox = (idx % cols) * cell_w
        oy = (idx // cols) * (spec_h + wave_h + label_h + 8)
        secs = len(buf) / float(sr)
        d.text((ox + 4, oy + 2), "%s  %.2fs" % (name, secs), fill=(59, 53, 102))
        # waveform: peak per column
        n = len(buf)
        mid = oy + label_h + wave_h // 2
        for x in range(cell_w - 8):
            a = int(n * x / float(cell_w - 8))
            b = max(a + 1, int(n * (x + 1) / float(cell_w - 8)))
            seg = buf[a:b]
            if not seg:
                continue
            hi = max(seg)
            lo = min(seg)
            d.line([(ox + 4 + x, mid - hi * wave_h / 2), (ox + 4 + x, mid - lo * wave_h / 2)], fill=(90, 120, 200))
        frames = spectrogram(buf, sr, cols=cell_w - 8)
        if not frames:
            continue
        peak = max([max(f) for f in frames])
        bins = len(frames[0])
        top = oy + label_h + wave_h + 4
        for x, f in enumerate(frames):
            for y in range(spec_h):
                b = int((spec_h - 1 - y) / float(spec_h) * bins)
                v = max(0.0, min(1.0, (f[b] - (peak - 60.0)) / 60.0))
                c = (int(30 + 225 * v), int(25 + 180 * v * v), int(80 + 60 * (1 - v)))
                img.putpixel((ox + 4 + x, top + y), c)
    d2 = os.path.dirname(path)
    if not os.path.isdir(d2):
        os.makedirs(d2)
    img.save(path)
    print("sheet: %s" % os.path.relpath(path, ROOT))


def main(argv):
    flags = [a for a in argv if a.startswith("--")]
    filters = [a for a in argv if not a.startswith("--")]
    every = "--all" in flags
    only_other = any(f in flags for f in ("--voices", "--ambience", "--music"))
    sheet = "--sheet" in flags
    shots = os.path.join(ROOT, ".shots")
    if every or not only_other:
        res = build_sfx(filters)
        if sheet and res:
            draw_sheet(res, os.path.join(shots, "sound_sfx.png"))
    if every or "--voices" in flags:
        import voices
        res = voices.build_all(os.path.join(ROOT, "sfx", "voices"), filters)
        if sheet:
            draw_sheet([(n, b, S.SR) for n, b in res], os.path.join(shots, "sound_voices.png"))
    if every or "--ambience" in flags:
        import ambience
        res = ambience.build_all(os.path.join(ROOT, "sfx", "ambience"), filters)
        if sheet:
            draw_sheet([(n, b, S.SR) for n, b in res], os.path.join(shots, "sound_ambience.png"))
    if every or "--music" in flags:
        import music
        res = music.build_all(os.path.join(ROOT, "music"), filters or None)
        if sheet:
            draw_sheet([(n, b[:S.SR * 6], S.SR) for n, b in res], os.path.join(shots, "sound_music.png"))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
