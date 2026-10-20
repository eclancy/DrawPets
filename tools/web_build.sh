#!/usr/bin/env bash
# Builds the web version of DrawPets into build/web/ (or the folder given):
#
#   bash tools/web_build.sh [--debug] [out-dir]
#
# The .NET Godot this project normally uses refuses to export for the web, even with no C# in the
# project, so this uses the standard Godot editor of the same version: GODOT_WEB_BIN, or
# C:\Users\ericc\Godot\Godot_v4.5.1-stable_win64\ (see .ai/releasing.md). It needs the web export
# templates in %APPDATA%\Godot\export_templates\4.5.1.stable\.
#
# Then copies in the two files the page loads beside the game: web/scanner.js (the camera
# scanner for swap codes) and jsQR, the QR decoder it uses. jsQR is kept in the repo as
# web/vendor/jsQR.js.txt because a .js file that big makes the .NET editor hang on exit, even
# behind .gdignore.
#
# --debug exports a development build: it prints its swap code to the browser console, so two
# tabs can swap without a camera.
set -euo pipefail
cd "$(dirname "$0")/.."

MODE="--export-release"
if [ "${1:-}" = "--debug" ]; then
	MODE="--export-debug"
	shift
fi
OUT="${1:-build/web}"
WEB_BIN="${GODOT_WEB_BIN:-/c/Users/ericc/Godot/Godot_v4.5.1-stable_win64/Godot_v4.5.1-stable_win64_console.exe}"
[ -f "$WEB_BIN" ] || { echo "the standard (non-.NET) Godot editor is not at $WEB_BIN - set GODOT_WEB_BIN" >&2; exit 1; }

rm -rf "$OUT"
mkdir -p "$OUT"
timeout 900 "$WEB_BIN" --headless --path . "$MODE" "Web" "$OUT/index.html" > build/export_web.log 2>&1 \
	|| { tail -20 build/export_web.log; echo "web export failed - see build/export_web.log" >&2; exit 1; }
[ -f "$OUT/index.pck" ] || { echo "the web export produced no index.pck - see build/export_web.log" >&2; exit 1; }
cp web/scanner.js "$OUT/scanner.js"
cp web/vendor/jsQR.js.txt "$OUT/jsQR.js"
cp web/vendor/jsQR.LICENSE "$OUT/jsQR.LICENSE.txt"
echo "web build in $OUT"
