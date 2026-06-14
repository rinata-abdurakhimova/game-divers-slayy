#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(dirname "$script_dir")"
export_path="$project_root/build/web/index.html"

echo "=== Loading .env ==="
if [[ -f "$project_root/.env" ]]; then
  set -a
  source "$project_root/.env"
  set +a
fi

itch_target="${ITCH_TARGET:-alina-anila/slay-diver-rise-of-67:web}"

find_command() {
  local configured="$1"
  shift

  if [[ -n "$configured" ]]; then
    printf '%s\n' "$configured"
    return
  fi

  local candidate
  for candidate in "$@"; do
    if command -v "$candidate" >/dev/null 2>&1; then
      command -v "$candidate"
      return
    fi
  done

  return 1
}

godot_path="$(find_command "${GODOT_EXE:-}" godot4 godot || true)"
butler_path="$(find_command "${BUTLER_PATH:-}" butler \
  "/Users/alina1/Library/Application Support/itch/broth/butler/versions/15.27.0/butler" \
  "/Users/alina1/Library/Application Support/itch/broth/butler/butler" \
  || true)"

if [[ -z "$godot_path" ]]; then
  echo "Godot was not found. Set GODOT_EXE to the Godot console executable." >&2
  exit 1
fi

if [[ -z "$butler_path" ]]; then
  echo "Butler was not found. Install it or set BUTLER_PATH to its executable." >&2
  exit 1
fi

if [[ -z "${BUTLER_API_KEY:-}" ]]; then
  echo "BUTLER_API_KEY is not set. Create or retrieve it from itch.io before deploying." >&2
  exit 1
fi

mkdir -p "$project_root/build/web"

echo "=== Exporting Web build ==="
"$godot_path" --headless --path "$project_root" \
  --export-release "Web" "$export_path"

echo "=== Pushing to itch.io ==="
"$butler_path" push "$project_root/build/web" "$itch_target"

echo "=== Done ==="
