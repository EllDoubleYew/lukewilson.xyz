#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || ! -f ${1-} ]]; then
    echo "Usage: ${0##*/} <post.md or post.markdown>" >&2
    exit 1
fi

source_file=$1
case "${source_file,,}" in
    *.md|*.markdown) ;;
    *) echo 'Provide a Markdown file (.md or .markdown).' >&2; exit 1 ;;
esac

if ! command -v cmark-gfm >/dev/null; then
    echo 'Install cmark-gfm first: sudo apt install cmark-gfm' >&2
    exit 1
fi

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
body=$(cmark-gfm --unsafe < "$source_file")

# Serialize publishing and standalone index rebuilds without leaving a lock file.
exec {lock}<"$root"
flock "$lock"
output=$(LC_ALL=C.UTF-8 python3 - "$root" "$source_file" 3<<<"$body" <<'PY'
import re
import sys
from datetime import datetime, timezone
from html import escape
from pathlib import Path

root = Path(sys.argv[1])
title = Path(sys.argv[2]).name.rsplit(".", 1)[0]
slug_text = "".join(char if char.isalpha() or char.isdecimal() else "-"
                    for char in title.lower())
slug = re.sub(r"-+", "-", slug_text).strip("-")[:100]
slug = slug.encode("utf-8")[:220].decode("utf-8", errors="ignore").rstrip("-") or "post"
now = datetime.now().astimezone()
date = now.date().isoformat()
values = {
    "TITLE": escape(title),
    "DATE": date,
    "PUBLISHED": now.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%f0Z"),
    "DISPLAY_DATE": f"{now:%B} {now.day}, {now.year}",
    "BODY": open(3, encoding="utf-8").read().rstrip("\n"),
}
template = (root / "templates/blog-post.html").read_text(encoding="utf-8")
html = re.sub(r"\{\{(TITLE|DATE|PUBLISHED|DISPLAY_DATE|BODY)\}\}",
              lambda match: values[match[1]], template)

blogs = root / "blogs"
blogs.mkdir(exist_ok=True)
stem = f"{date}-{slug}"
output = blogs / f"{stem}.html"
suffix = 2
while output.exists() or output.is_symlink():
    output = blogs / f"{stem}-{suffix}.html"
    suffix += 1
output.write_text(html, encoding="utf-8")
print(output)
PY
)

if ! python3 "$root/update-blog-index.py"; then
    rm -- "$output"
    exit 1
fi

printf 'Created %s\nReady to preview. Commit and push when you want to put it online.\n' "$output"
