#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
exec {lock}<"$root"
flock "$lock"
python3 "$root/update-blog-index.py"
