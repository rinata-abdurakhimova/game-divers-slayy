---
name: jam-implement
description: Implement scoped Godot 4 gameplay, world, or integration features with typed GDScript, exported tuning values, defensive checks, documented signals, and verification. Use for concrete coding tasks after ownership and integration boundaries are known.
---

# Jam Implement

Read `AGENTS.md`, `ARCHITECTURE.md`, `INTEGRATION_CONTRACT.md`, and `OWNERSHIP.md`.

1. Confirm the goal, owner, owned files, and current contract from repository context.
2. Inspect nearby scenes and scripts before editing.
3. Implement the smallest complete behavior using Godot 4.x GDScript.
4. Prefer composition, typed values, `@export` tuning, signals, and null checks at unstable boundaries.
5. Keep UI, audio, and world consumers behind documented signals.
6. Update contracts when behavior changes.
7. Run `tools/qa.cmd` on Windows, `bash tools/qa.sh` on macOS/Linux, or `tools/qa.ps1` in CI, plus the narrowest available feature test.

Report goal, acting role, files and ownership, implementation, signals and dependencies, teammate
handoff, tests, and scope warning. End with integration notes.
