#!/usr/bin/env bash
# Build numera.velofy.co/pro from the real NumeraAI marketing pages.
#
#   docker run -d --name numera-live ... -p 8042:8000 numera-pro:live
#   ./build-from-app.sh
#
# The app's landing and about pages ARE the Pro marketing site. Keeping a
# hand-written copy in this repo meant two versions of the same argument,
# drifting apart. This captures them instead.
#
# What it does NOT capture is pricing: the app pages carry none, and this page
# has to sell. That section lives in pricing.part.html and is appended here.
set -euo pipefail

SRC="${SRC:-http://127.0.0.1:8042}"
HERE="$(cd "$(dirname "$0")" && pwd)"
CONSOLE="https://numera-console.velofy.co/login.html"

# -L matters: /about answers 301 and a plain fetch silently yields zero bytes.
fetch() { curl -fsSL "$SRC$1"; }

fetch / > /dev/null 2>&1 || { echo "NumeraAI not reachable at $SRC"; exit 1; }

CSS_PATH="$(fetch / | grep -oE '/static/css/numera2\.[a-z0-9]+\.css' | head -1)"
[ -n "$CSS_PATH" ] || { echo "could not find the stylesheet reference"; exit 1; }
mkdir -p "$HERE/static/css"
curl -fsSL "$SRC$CSS_PATH" -o "$HERE/static/css/numera2.css"
echo "  css      $(wc -c < "$HERE/static/css/numera2.css" | tr -d ' ') bytes"

for pair in "/:index" "/about:about"; do
  route="${pair%%:*}"; name="${pair##*:}"
  fetch "$route" | python3 "$HERE/transform.py" "$name" "$CSS_PATH" "$CONSOLE" > "$HERE/$name.page"
  size=$(wc -c < "$HERE/$name.page" | tr -d ' ')
  # A marketing page under 8KB means the fetch or the transform ate it.
  if [ "$size" -lt 8000 ]; then
    echo "  FAIL     $name is only $size bytes; refusing to publish a truncated page"
    rm -f "$HERE"/*.page; exit 1
  fi
  echo "  $name$(printf '%*s' $((9 - ${#name})) '')$size bytes"
done

# Append the commercial section before the footer.
python3 - "$HERE" <<'PY'
import pathlib, sys
here = pathlib.Path(sys.argv[1])
page = (here / "index.page").read_text()
part = (here / "pricing.part.html").read_text()
i = page.rfind("<footer")
page = (page[:i] + part + "\n" + page[i:]) if i != -1 else (page + part)
(here / "index.html").write_text(page)
(here / "about.html").write_text((here / "about.page").read_text())
print("  index    %d bytes (landing + pricing)" % len(page))
PY

rm -f "$HERE"/*.page
echo "  console links -> $CONSOLE"
echo "Done. Serve $HERE and check before committing."
