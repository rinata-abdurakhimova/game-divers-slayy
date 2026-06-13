---
name: jam-architecture
description: Design integration-first Godot 4 scene trees, ownership boundaries, signals, dependencies, reset behavior, and tests. Use before a new entity, system, UI surface, autoload, shared contract, or any feature touching more than one team ownership zone.
---

# Jam Architecture

Read `ARCHITECTURE.md`, `INTEGRATION_CONTRACT.md`, and `OWNERSHIP.md`.

1. Name the feature goal and acting owner.
2. Choose the smallest scene tree and scripts that satisfy the goal.
3. Reuse existing signals and autoloads before adding new global APIs.
4. Define inputs, emitted and consumed signals, assets, reset behavior, and fallback.
5. Identify every owner affected and avoid shared-file edits where an adapter can work.
6. Update `INTEGRATION_CONTRACT.md` before implementing a breaking boundary.
7. Give an isolation test and a test from `Main.tscn`.

Reject architecture that adds speculative managers, deep inheritance, or hidden node-path coupling.
End with teammate handoff and integration notes.
