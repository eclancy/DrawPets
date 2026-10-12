# -*- coding: utf-8 -*-
"""Draws every .wav in a folder as a waveform over a spectrogram, into <folder>.png - for looking
at sounds made outside build.py (the game's own voice renders: tools/voice_check.gd).

    python tools/audio/sheet.py .shots/voice_check
"""
from __future__ import division

import array
import os
import sys
import wave

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

from build import draw_sheet


def read_wav(path):
    w = wave.open(path, "rb")
    try:
        sr = w.getframerate()
        frames = w.readframes(w.getnframes())
        channels = w.getnchannels()
    finally:
        w.close()
    a = array.array("h")
    a.fromstring(frames)
    samples = [a[i] / 32768.0 for i in range(0, len(a), channels)]
    return samples, sr


def main(folder):
    results = []
    for name in sorted(os.listdir(folder)):
        if name.endswith(".wav"):
            buf, sr = read_wav(os.path.join(folder, name))
            results.append((name[:-4], buf, sr))
    draw_sheet(results, folder.rstrip("/\\") + ".png")


if __name__ == "__main__":
    main(sys.argv[1])
