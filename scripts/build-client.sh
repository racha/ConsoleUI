#!/usr/bin/env bash
set -euo pipefail

client="${1:-}"
case "$client" in
  vanilla|wrath) ;;
  *) echo "Usage: scripts/build-client.sh vanilla|wrath" >&2; exit 2 ;;
esac

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
output="$repo/dist/clients/$client"

# These are generated install folders, never the working source or game AddOns.
if [[ -L "$output" || -L "$output/ConsoleUI" || -L "$output/ConsoleUIKeyboard" ]]; then
  echo "Refusing to build through a symlink: $output" >&2
  exit 1
fi
mkdir -p "$output/ConsoleUI"
rsync -a --delete --exclude='.DS_Store' "$repo/ConsoleUI/" "$output/ConsoleUI/"

if [[ "$client" == "vanilla" ]]; then
  mkdir -p "$output/ConsoleUIKeyboard"
  rsync -a --delete --exclude='.DS_Store' "$repo/ConsoleUIKeyboard/" "$output/ConsoleUIKeyboard/"
else
  # Wrath is a source overlay for now. Keep the Vanilla folders untouched.
  rsync -a "$repo/clients/wrath/ConsoleUI/" "$output/ConsoleUI/"
fi

echo "$output"
