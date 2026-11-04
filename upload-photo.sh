#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || ! -f ${1-} ]]; then
    echo "Usage: ${0##*/} <photo>" >&2
    exit 1
fi

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
exec {lock}<"$root"
flock "$lock"

python3 - "$root" "$1" <<'PY'
import shutil
import sys
from datetime import date
from html import escape
from pathlib import Path
from stat import S_IMODE
from tempfile import NamedTemporaryFile
from urllib.parse import quote

root = Path(sys.argv[1])
source = Path(sys.argv[2])
extension = source.suffix.lower()
if extension not in {".jpg", ".jpeg", ".png", ".gif", ".webp", ".avif", ".bmp"}:
    sys.exit("Provide a JPEG, PNG, GIF, WebP, AVIF, or BMP image.")

gallery = root / "photos.html"
start = "<!-- PHOTO-GRID:START -->"
end = "<!-- PHOTO-GRID:END -->"
original = gallery.read_bytes().decode("utf-8")
if original.count(start) != 1 or original.count(end) != 1 or original.index(start) > original.index(end):
    sys.exit("photos.html must contain exactly one ordered pair of PHOTO-GRID markers.")

photos = root / "photos"
photos.mkdir(exist_ok=True)
# Leave room for a collision suffix within the filesystem filename limit.
stem = source.stem.encode("utf-8")[:220].decode("utf-8", errors="ignore")
destination = photos / f"{stem}{extension}"
suffix = 2
while destination.exists() or destination.is_symlink():
    destination = photos / f"{stem}-{suffix}{extension}"
    suffix += 1

url = "photos/" + quote(destination.name, safe="")
alt = escape(source.stem)
uploaded = date.today().isoformat()
before, after = original.split(start)
newline = "\r\n" if after.startswith("\r\n") else "\n"
entry = newline.join((
    "",
    "      <figure>",
    f'        <a href="{url}" target="_blank" rel="noopener">',
    f'          <img src="{url}" alt="{alt}">',
    "        </a>",
    f'        <figcaption><time datetime="{uploaded}">{uploaded}</time></figcaption>',
    "      </figure>",
))
updated = before + start + entry + after

with NamedTemporaryFile(dir=root, prefix=".photos-", delete=False) as temp:
    temporary_gallery = Path(temp.name)
    try:
        temp.write(updated.encode("utf-8"))
        temp.close()
        temporary_gallery.chmod(S_IMODE(gallery.stat().st_mode))
        with destination.open("xb") as image:
            try:
                with source.open("rb") as incoming:
                    shutil.copyfileobj(incoming, image)
                image.close()
                temporary_gallery.replace(gallery)
            except BaseException:
                destination.unlink()
                raise
    finally:
        temporary_gallery.unlink(missing_ok=True)

print(f"Added {destination.relative_to(root)} and updated photos.html.")
PY
