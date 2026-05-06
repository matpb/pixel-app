#!/usr/bin/env bash
# Re-runnable: rasterize pixel-logo.svg into all the favicon/icon sizes
# the website needs. Sidesteps Chrome headless's --window-size→viewport
# mismatch by rendering at 2× target then cropping with ImageMagick.
set -euo pipefail
cd "$(dirname "$0")"

render_at() {
  local size="$1" out="$2"
  local rw=$((size * 2 + 200))
  local tmp="${out%.png}.full.png"

  google-chrome-stable --headless=new --disable-gpu --no-sandbox --hide-scrollbars \
    --window-size="${rw},${rw}" --force-device-scale-factor=2 \
    --virtual-time-budget=2500 --default-background-color=00000000 \
    --screenshot="${tmp}" "file://${PWD}/_favicon.html#${size}" 2>/dev/null

  magick "${tmp}" -crop "$((size*2))x$((size*2))+0+0" -resize "${size}x${size}" "${out}"
  rm -f "${tmp}"
  echo "✔ ${out}"
}

render_at 16  ../favicon-16.png
render_at 32  ../favicon-32.png
render_at 48  ../favicon-48.png
render_at 180 ../apple-touch-icon.png
render_at 192 ../icon-192.png
render_at 512 ../icon-512.png

# Multi-resolution favicon.ico (16+32+48)
magick ../favicon-16.png ../favicon-32.png ../favicon-48.png ../favicon.ico
echo "✔ ../favicon.ico"
