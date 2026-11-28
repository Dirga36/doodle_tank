# AGENTS.md — Operational Guidelines for AI Coding Agents

Read this file before changing Doodle Tank.

## Core Principles and System Invariants

- **Engine:** Godot 4.7.2-stable, GDScript only, with the GL Compatibility renderer and D3D12 on Windows.
- **Project entry:** `res://scenes/opening/opening.tscn`; gameplay entry: `res://scenes/game/game.tscn`.
- **Single world:** this is one survival level, not a multi-level or zone system. Leave level-template code unchanged unless the task explicitly removes or refactors it.
- **Third-party boundary:** treat `res://addons/` as read-only. The enabled plugins are GDQuest GDScript Formatter, Maaack Game Template, Maaack Music Controller, Maaack Scene Loader, Phantom Camera, Plugin Updater, and Spawner.
- **Type everything:** use `class_name`, typed parameters and return values, typed `@export` variables, and typed `@onready` variables.
- **No hand-written project settings:** do not call `ProjectSettings.save()` or edit `project.godot` directly; use the Godot settings and editor UI.
- **Cross-node references:**
  - Within the same scene or owner, use `%UniqueName` when the node has `unique_name_in_owner`.
  - Across an instanced-scene boundary, `%` does not resolve. Use an `@export var target: TargetType` with a `NodePath`, or a stable scene export pattern.
- **Persistence:** mutate persistent values through `GameState`, then call `GlobalState.save()`. Extend `GameState.reset()` for every new saved field.
- **Player tuning:** read tunable values from `res://resources/player_stats.tres` through `preload("res://resources/player_stats.tres")` unless the scene deliberately exports a `PlayerStats` resource.

## Tech Stack and Tooling

- **Language:** GDScript
- **Renderer:** `gl_compatibility`
- **UI stretch:** `canvas_items` with `expand`
- **Physics:** Jolt Physics
- **Package manager:** none
- **Environment variables:** no project `.env` configuration; CI uses GitHub repository variables and secrets.
- **Tests:** no automated test suite is currently present.
- **Formatting:** GDQuest GDScript Formatter editor plugin.
- **Release:** GitHub Actions workflow at `.github/workflows/build-and-publish.yml` exports Windows and optionally publishes through Butler.

## Architecture and File Map

| Path | Responsibility | Modifiability |
| --- | --- | --- |
| `res://scenes/game/` | Player, enemies, HUD, map, tutorials, VFX, and gameplay scene | Primary game implementation area |
| `res://scenes/game/game.tscn` | Wires the world, player, timer, goal manager, result manager, and HUD | Edit carefully; re-save after inheritance recovery warnings |
| `res://scenes/game/scripts/` | Bolts, timer, win/lose checks, spawning, tutorial, and viewport helpers | Safe |
| `res://scenes/game/player/` | Tank components, cannon, bullet, mine, camera, and variants | Safe |
| `res://scenes/game/enemy/` | Tank, drone, armored car, targeting, and health logic | Safe |
| `res://scenes/menus/` | Main menu, options, tank selection, and Armory | Safe; extend addon base scenes rather than editing addons |
| `res://scenes/windows/` | Pause, win, lose, and menu windows | Safe |
| `res://scripts/game_state.gd` | `GameState` static save API | High caution; saved schema and migration behavior |
| `res://resources/player_stats.gd` / `.tres` | Exported player stats and upgrade levels | Runtime reads and Armory writes |
| `res://addons/` | Third-party plugins | Read-only |

## Gameplay and Persistence Invariants

- `GameTimer.play_time` is pausable; `total_time` continues while paused. `_exit_tree` contributes elapsed time to `GameState` and saves.
- A run wins at 600.1 seconds of `play_time`. The goal manager awards 2000 bonus bolts and records run bolts.
- A player death opens the lose flow and still records collected bolts.
- The bolt multiplier starts at 1.0 and gains 0.5 every 300 seconds, with three increases maximum, reaching 2.5x.
- Base enemy rewards are tank 15, drone 10, and armored car 10 before the multiplier.
- Armory costs are `1000 + current_level * 500`, maximum level 3. Health adds 500, speed adds 20, and damage adds 100 per purchase.
- Save mutations must use `GameState` and `GlobalState.save()`.
- Upgrades change `res://resources/player_stats.tres`, and gameplay components read values at `_ready`; expect upgrades to apply on the next gameplay scene load.

## Node and Scene Conventions

- Use snake_case filenames and PascalCase node names.
- Group player behavior under component nodes: health, movement, cannon, mine, and camera.
- Prefer UID scene preloads, for example `const Bullet: PackedScene = preload("uid://...")`, consistent with existing scripts.
- Add dynamically spawned bullets and mines to `get_tree().current_scene` or the scene root, not as children of the shooter.
- Use signals for manager-to-manager and manager-to-HUD coupling.
- Physics layers are `1` World and Ground Enemy, `2` Player, `3` Air Enemy, and `4` Projectiles.
- Player and enemy nodes use the `player` and `enemy` groups where appropriate.

## Known Gotchas

- `game.tscn` can report an inherited-node recovery warning. Open and re-save `res://scenes/game/game.tscn` to clear it.
- HUD scripts cannot use `%GameTimer` across the instanced HUD boundary. Use an exported `NodePath` or `GameTimer` export assigned in `game.tscn`.
- `player_stats.tres` is both gameplay input and runtime Armory output; it is not immutable.
- `GameState.reset()` mutates existing fields directly. Add every resettable field to it and reset saved player stats as required.
- `@tool` scripts such as credits and window scripts run in the editor. Guard editor-only behavior with `Engine.is_editor_hint()`.
- The existing project has temporary `.tmp` scene backups; do not treat them as source scenes.

## Common Workflows

Open a PowerShell terminal at the repository root.

### Run and Export

```powershell
& "C:\Users\Admin\Desktop\Godot_v4.7.2-stable_win64.exe" --path . --editor
& "C:\Users\Admin\Desktop\Godot_v4.7.2-stable_win64.exe" --path .
& "C:\Users\Admin\Desktop\Godot_v4.7.2-stable_win64.exe" --path . res://scenes/game/game.tscn
& "C:\Users\Admin\Desktop\Godot_v4.7.2-stable_win64.exe" --headless --path . --export-release "Windows Desktop" "build\DoodleTank.exe"
```

### Verification

1. Open the changed scene in the editor and resolve any parser or node warnings.
2. Run the smallest relevant scene: opening, Armory, or `res://scenes/game/game.tscn`.
3. Test the actual mechanic, not only code inspection.
4. Inspect the Godot output panel for errors and gameplay prints such as `"WIN"`, `"LOSE"`, and `"Enemy destroyed!"`.
5. Run the Windows export command when export configuration or scene resources may be affected.

There is no lint or test runner command yet. Use the GDQuest editor formatter and Godot runtime verification.

## CI Configuration

`.github/workflows/build-and-publish.yml` requires these GitHub repository variables:

- `GODOT_VERSION`
- `EXPORT_NAME`
- `ITCH_USERNAME`
- `ITCH_GAME`

It requires this repository secret:

- `BUTLER_API_KEY`

The workflow exports `build/windows/<EXPORT_NAME>.exe`, archives it, uploads a GitHub artifact, and pushes Windows builds to itch.io on release or manual dispatch.

## Pre-Completion Checklist

1. GDScript and scenes parse with no new errors or warnings.
2. Formatting matches nearby GDScript and the GDQuest formatter.
3. Cross-instance references use exports and `NodePath`, not scene-local `%` lookup.
4. Persistent data uses `GameState` and `GlobalState.save()`.
5. Gameplay behavior is verified in the relevant Godot scene.
6. Export presets and resources remain valid.
7. No files under `res://addons/` or `project.godot` are modified unless explicitly required.