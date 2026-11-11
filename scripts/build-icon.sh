#!/bin/bash
# Rebuild the macOS icon bundle from the committed 1024px PNG source.
set -euo pipefail
cd "$(dirname "$0")/.."

icon_work="$(mktemp -d "${TMPDIR:-/tmp}/broschy-icon.XXXXXX")"
trap 'rm -rf "$icon_work"' EXIT
icon_set="$icon_work/Broschy.iconset"
mkdir -p "$icon_set"

for size in 16 32 128 256 512; do
    sips -z "$size" "$size" Resources/AppIcon.png --out "$icon_set/icon_${size}x${size}.png" >/dev/null
    double_size=$((size * 2))
    sips -z "$double_size" "$double_size" Resources/AppIcon.png --out "$icon_set/icon_${size}x${size}@2x.png" >/dev/null
done

iconutil -c icns "$icon_set" -o Resources/Broschy.icns
cp Resources/AppIcon.png docs/assets/app-icon.png
printf '%s\n' "Updated Resources/Broschy.icns and docs/assets/app-icon.png"
