#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(dirname "$script_dir")"
butler_path="/Users/alina1/Library/Application Support/itch/broth/butler/versions/15.27.0/butler"

echo "=== Exporting Web build ==="
godot --headless --export-release "Web" "$project_root/build/web/index.html"

echo "=== Pushing to itch.io ==="
BUTLER_API_KEY="tcMvHQQB5e0PkotyzHNbsNtWgzEhfG0C3C3KaTFf" \
  "$butler_path" push "$project_root/build/web" alina-anila/slay-diver-rise-of-67:web

echo "=== Done ==="
