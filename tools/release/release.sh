#!/usr/bin/env bash
# Publish a new version of DrawPets. Every Windows copy picks it up the next time it starts; an
# Android copy says on its home screen that a grown-up can get it.
#
#   bash tools/release/release.sh 0.1.0 ["What changed, for players"]
#   bash tools/release/release.sh 0.1.0 --build-only     # everything into build/release/,
#                                                        # nothing committed, tagged or published
#
# The optional second argument heads the release notes, and ecec.dev/games/drawpets shows it under
# "What's new". The download instructions are always appended below it, and must keep starting
# with "Download **": that page strips the paragraph that starts that way.
#
# Commits the version bump, tags it, exports Windows, Android and the web, and makes a GitHub
# Release with the installer (DrawPets-Setup.exe, Inno Setup, installer.iss), the full zip (the
# portable version), the small patch zip, the Android APK (DrawPets.apk, signed with the release
# key), the web version (DrawPets-web.zip) and version.json. ecec.dev/drawpets/version.json
# redirects to the newest release's version.json; the web version needs ecec.dev redeployed, which
# the script starts at the end. See .ai/releasing.md. Ported from Wizard Survivors'.
set -euo pipefail

VERSION="${1:-}"
CHANGES="${2:-}"
BUILD_ONLY=0
if [ "$CHANGES" = "--build-only" ]; then
	BUILD_ONLY=1
	CHANGES=""
fi
HOW_TO="Download **DrawPets-Setup.exe** and run it, then play from the Start menu or the desktop. It keeps itself up to date from then on. No installer? DrawPets-windows.zip is the portable version: unzip it anywhere you can write to and run DrawPets.exe. On an Android phone or tablet, download **DrawPets.apk** and open it (a grown-up allows the install). On an iPad, iPhone, Chromebook or Mac, play in the browser at https://ecec.dev/drawpets/play/ - and add it to the Home Screen. Download page: https://ecec.dev/drawpets/download"
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	echo "usage: bash tools/release/release.sh X.Y.Z [\"what changed\" | --build-only]" >&2
	exit 1
fi

cd "$(dirname "$0")/../.."

# A Claude session gets GODOT_BIN from .claude/settings.json; a plain shell reads it from there.
if [ -z "${GODOT_BIN:-}" ] && [ -f .claude/settings.json ]; then
	GODOT_BIN=$(sed -n 's/^ *"GODOT_BIN": *"\(.*\)",\{0,1\} *$/\1/p' .claude/settings.json | sed 's/\\\\/\\/g')
	GODOT_BIN=$(cygpath -u "$GODOT_BIN" 2>/dev/null || echo "$GODOT_BIN")
	export GODOT_BIN
fi
: "${GODOT_BIN:?GODOT_BIN is not set - see .claude/settings.json}"
[ -f "$GODOT_BIN" ] || { echo "GODOT_BIN does not exist: $GODOT_BIN" >&2; exit 1; }

# Inno Setup compiles the installer. Checked up front so a missing install cannot fail the
# release after the export. winget install JRSoftware.InnoSetup puts it here (per user).
ISCC="${ISCC:-$LOCALAPPDATA/Programs/Inno Setup 6/ISCC.exe}"
ISCC=$(cygpath -u "$ISCC" 2>/dev/null || echo "$ISCC")
[ -f "$ISCC" ] || { echo "Inno Setup's ISCC.exe not found at $ISCC - install it (winget install JRSoftware.InnoSetup) or set ISCC" >&2; exit 1; }

# The Android release key, which never goes in git (.ai/releasing.md). The file sets
# GODOT_ANDROID_KEYSTORE_RELEASE_PATH, _USER and _PASSWORD, which Godot's export reads.
KEYS="${DRAWPETS_RELEASE_KEYS:-$HOME/.drawpets-release/release.env}"
[ -f "$KEYS" ] || { echo "no release key settings at $KEYS - see .ai/releasing.md" >&2; exit 1; }
set -a
# shellcheck disable=SC1090
. "$KEYS"
set +a
[ -f "${GODOT_ANDROID_KEYSTORE_RELEASE_PATH:-}" ] || { echo "the release keystore named in $KEYS is missing" >&2; exit 1; }

# The web version needs the standard (non-.NET) Godot of the same version (tools/web_build.sh).
WEB_BIN="${GODOT_WEB_BIN:-/c/Users/ericc/Godot/Godot_v4.5.1-stable_win64/Godot_v4.5.1-stable_win64_console.exe}"
[ -f "$WEB_BIN" ] || { echo "the standard Godot editor for the web build is not at $WEB_BIN - set GODOT_WEB_BIN" >&2; exit 1; }
export GODOT_WEB_BIN="$WEB_BIN"

ANDROID_HOME="${ANDROID_HOME:-$LOCALAPPDATA/Android/Sdk}"
[ -d "$ANDROID_HOME" ] || ANDROID_HOME="$HOME/Android/Sdk"
APKSIGNER=$(ls "$ANDROID_HOME"/build-tools/*/apksigner.bat 2>/dev/null | sort -V | tail -1)
# apksigner needs a newer Java than the one on the PATH: the JDK 17 from .ai/android.md.
export JAVA_HOME="${JAVA_HOME:-$LOCALAPPDATA/Programs/Eclipse Adoptium/jdk-17.0.20.1+1}"
[ -n "$APKSIGNER" ] || { echo "apksigner not found under $ANDROID_HOME/build-tools" >&2; exit 1; }

if [ $BUILD_ONLY -eq 0 ]; then
	if [ -n "$(git status --porcelain)" ]; then
		echo "commit or stash your changes first - a release is built from what is committed" >&2
		exit 1
	fi
	if git rev-parse -q --verify "refs/tags/v$VERSION" >/dev/null; then
		echo "v$VERSION already exists" >&2
		exit 1
	fi
fi

# Put the two files back as they were (a failed release, or --build-only) - from a copy, not
# from git, so a build-only run cannot throw away uncommitted work in them.
SAVED=$(mktemp -d)
cp project.godot export_presets.cfg "$SAVED/"
undo() { cp "$SAVED/project.godot" "$SAVED/export_presets.cfg" .; }

CURRENT=$(sed -n 's/^config\/version="\(.*\)"$/\1/p' project.godot)
echo "DrawPets $CURRENT -> $VERSION"

# The version lives in project.godot, which is where the running game reads it from. Android
# needs it too, plus a version code that only ever goes up (an update must have a higher one):
# 1.2.3 -> 10203.
IFS=. read -r MAJOR MINOR PATCH <<< "$VERSION"
CODE=$((MAJOR * 10000 + MINOR * 100 + PATCH))
sed -i "s/^config\/version=\".*\"$/config\/version=\"$VERSION\"/" project.godot
sed -i "s/^version\/code=.*$/version\/code=$CODE/; s/^version\/name=.*$/version\/name=\"$VERSION\"/" export_presets.cfg

rm -rf build/windows build/release
mkdir -p build/windows build/release
# Godot does not create the export folder itself, and on an export error it can sit there
# instead of exiting - hence the timeout.
timeout 900 "$GODOT_BIN" --headless --path . --export-release "Windows Desktop" build/windows/DrawPets.exe \
	> build/export.log 2>&1 || { tail -20 build/export.log; echo "Windows export failed - see build/export.log" >&2; undo; exit 1; }
[ -f build/windows/DrawPets.pck ] || { echo "the Windows export produced no .pck - see build/export.log" >&2; undo; exit 1; }

# Gradle's daemon would otherwise hold the console open long after the APK is done
# (.ai/android.md).
GRADLE_OPTS=-Dorg.gradle.daemon=false timeout 1800 "$GODOT_BIN" --headless --path . --export-release "Android" \
	build/release/DrawPets.apk > build/export_android.log 2>&1 \
	|| { tail -20 build/export_android.log; echo "Android export failed - see build/export_android.log" >&2; undo; exit 1; }
[ -f build/release/DrawPets.apk ] || { echo "the Android export produced no APK - see build/export_android.log" >&2; undo; exit 1; }
# Signed with the release key, not the debug one: a phone only takes an update signed the same
# way as what it has.
CERT=$(MSYS_NO_PATHCONV=1 "$APKSIGNER" verify --print-certs build/release/DrawPets.apk 2>&1 | grep -m1 "certificate DN" || true)
case "$CERT" in
	*"Android Debug"*|"") echo "DrawPets.apk is not signed with the release key: $CERT" >&2; undo; exit 1 ;;
esac

bash tools/web_build.sh build/web || { undo; exit 1; }

python tools/release/package.py "$VERSION"
# The installer: build/release/DrawPets-Setup.exe, from the same export. The MSYS variables stop
# Git Bash rewriting ISCC's /Q and /D switches into Windows paths.
MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*' "$ISCC" /Q "/DAppVersion=$VERSION" tools/release/installer.iss \
	|| { echo "installer compile failed" >&2; undo; exit 1; }
[ -f build/release/DrawPets-Setup.exe ] || { echo "ISCC produced no DrawPets-Setup.exe" >&2; undo; exit 1; }

if [ $BUILD_ONLY -eq 1 ]; then
	undo
	ls -la build/release
	echo "Built v$VERSION into build/release/ - nothing committed, tagged or published."
	exit 0
fi

git diff --quiet project.godot export_presets.cfg || git commit -q -m "Release v$VERSION" project.godot export_presets.cfg
git tag "v$VERSION"
git push -q origin HEAD "v$VERSION"

gh release create "v$VERSION" --repo eclancy/DrawPets \
	build/release/DrawPets-Setup.exe build/release/DrawPets-windows.zip \
	build/release/DrawPets-patch.zip build/release/DrawPets.apk build/release/DrawPets-web.zip \
	build/release/version.json \
	--title "DrawPets $VERSION" \
	--notes "${CHANGES:+$CHANGES

}$HOW_TO"

# The web version is served from ecec.dev itself (same site as the meeting point), so the site's
# deploy fetches the newest DrawPets-web.zip; start it now.
gh workflow run deploy.yml --repo eclancy/EricClancyEngineeringAndCrafts \
	&& echo "Started ecec.dev's deploy - /drawpets/play/ gets v$VERSION in a few minutes." \
	|| echo "Could not start ecec.dev's deploy - run its Deploy workflow by hand for the web version." >&2

echo "Released v$VERSION - every Windows copy updates the next time it starts."
