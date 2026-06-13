#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v pwsh >/dev/null 2>&1; then
  echo "QA requires PowerShell 7 (pwsh)." >&2
  echo "On macOS: brew install --cask powershell" >&2
  exit 127
fi

exec pwsh -NoProfile -File "$script_dir/qa.ps1" "$@"
