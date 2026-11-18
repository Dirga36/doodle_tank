# AGENTS.md — Operational Guidelines for AI Coding Agents

This file is the fast-load briefing for any AI agent working on **Doodle Tank**, a Godot 4.7.2 (GDScript) 2D survival/twin-stick tank game. Read this before touching code.

---

## 1. What this project is

**Doodle Tank** — the player controls a tank and must survive **10 minutes** while enemies try to stop them. Destroyed enemies award **bolts**, a currency persisted across sessions and spent in the **Armory** to permanently upgrade the tank's health, speed and damage.

- **Engine:** Godot `4.7.2-stable`, **GDScript** only (no C#).
- **Renderer:** `gl_compatibility` (Windows driver `d3d12`). Keep compatibility-renderer constraints in mind.
- **Stretch/UI:** `canvas_items` + `expand`.
- **Main scene:** `res://scenes/opening/opening.tscn`.
- **Built on [Maaack's Godot Game Template](https://github.com/Maaack/Godot-Game-Template)** suite. Much of the menu/save/scene-loading scaffolding lives in `res://addons/`.

---

## 2. Core principles & invariants (do not break)

1. **`addons/` is third-party — treat as read-only.** Seven editor plugins are enabled (see §3). Make game changes in `res://scenes/`, `res://scripts/`, and `res://resources/`, not in addons. Overriding addon behavior is done by **extending** its scripts (e.g. `res://scripts/level_and_state_manager.gd extends LevelManager`), which is the established pattern here.
3. Though there's codes that indicate to implement level system (e.g. stage, map, mission, or zone), this game is a single level only, meaning the game world is just only one. Level related codes will be removed in the future.
2. **Cross-node references use the established access rule** (this is a real source of silent failures — see §7):
   - Within the **same scene/owner**, use `%UniqueName` (`unique_name_in_owner`).
   - **Across an instanced-scene boundary**, `%` does **not** resolve — use an `@export` field assigned to a `NodePath` in the parent scene.
4. **Persistent data goes through `GameState`** (`res://scripts/game_state.gd`), a static API on top of the addon's `GlobalState` autoload. Always call `GlobalState.save()` after mutating (the existing methods do this for you).
5. **Tunable player numbers live in the `PlayerStats` resource** (`res://resources/player_stats.tres`), never hard-coded in player scripts. Runtime reads use `preload("res://resources/player_stats.tres")`.
6. **Type everything.** This project uses `class_name`, typed `@export` vars, typed function params/returns, and typed `@onready` vars throughout. Match that style.
7. **Do not call `ProjectSettings.save()` from a script** and do not hand-edit `project.godot`; use settings tools.

---

## 3. Tech stack & tooling

- **Autoloads (in order):** `Global` → `res://scenes/game/scripts/global.gd`; `SceneLoader`, `ProjectMusicController` (addons); `PhantomCameraManager` (addon); `BoltsManager` → `res://scenes/game/scripts/bolts_manager.gd`.
- **Enabled editor plugins:** `GDQuest_GDScript_formatter`, `maaacks_game_template`, `maaacks_music_controller`, `maaacks_scene_loader`, `phantom_camera`, `plugin_updater`, `spawner`.
- **Physics (2D) collision layers** (named in `project.godot`):
  - `1` World and Ground Enemy
  - `2` Player
  - `3` Air Enemy
  - `4` Projectiles
- **Groups:** `player`, `enemy` (enemies/damage checks use `is_in_group(...)`).
- **Input actions:** `move_forward`/`move_backward` (W/S, Up/Down), `turn_left`/`turn_right` (A/D, Left/Right), `shoot main cannon` (LMB), `deploy land mine` (RMB), `zoom in` (wheel down), `zoom out` (wheel up).
- **Template-configured scenes** (`[maaacks_game_template]`): main menu `res://scenes/menus/main_menu/main_menu.tscn`, game `res://scenes/game/game.tscn`, ending `res://scenes/end_credits/end_credits.tscn`.
- **No automated tests exist** in the project yet.

---

## 4. Architecture / file map

| Path | Responsibility | Modifiability |
| --- | --- | --- |
| `res://scenes/game/` | Core gameplay: player, enemies, HUD, map, tutorials, VFX | Safe to modify — primary work area |
| `res://scenes/game/game.tscn` | The gameplay scene; wires `WorldContainer/Player`, `GameTimer`, `GoalManager`, `WinLoseManager`, `Hud` | Edit with care (see §7 gotcha) |
| `res://scenes/game/scripts/` | Gameplay helpers: `global.gd`, `bolts_manager.gd`, `game_timer.gd`, `goal_manager.gd`, `tutorial_manager.gd`, `configurable_sub_viewport.gd`, `input_display_label.gd` | Safe |
| `res://scenes/game/player/` | `Player.tscn` + player, cannon/bullet, landmine, movement/health managers, camera | Safe |
| `res://scenes/game/enemy/` | `tank/`, `drone/`, `armoredcar/` each with their own `health_manager.gd` | Safe |
| `res://scripts/game_state.gd` | `GameState` persistence API (levels, play/total time, `total_bolts`) | **High caution** — schema change migrates user saves |
| `res://scripts/level_state.gd` | `LevelState` resource (per-level color + tutorial read flag) | Unused template |
| `res://scripts/level_and_state_manager.gd` | Bridges the addon `LevelManager` to `GameState` | Unused template |
| `res://resources/player_stats.gd` / `.tres` | `PlayerStats` resource: `max_health`, `speed`, `damage` + `*_level` fields | Tunable; the `.tres` is also written at runtime (armory) |
| `res://scenes/menus/` | Main menu, options menus, **armory** (upgrades) | Safe; extend, don't edit addon base menus |
| `res://scenes/windows/` | Pause menu, win/lose windows, result screen | Safe |
| `res://addons/` | Third-party plugins | **Read-only** unless extending |

---

## 5. Gameplay facts you must not get wrong

- **Win condition:** survive `WIN_TIME_SECONDS = 600.1` seconds of `play_time` (`res://scenes/game/scripts/goal_manager.gd`). Comment notes "Shorten to 5.1 for testing." Win awards `WIN_BONUS_BOLTS = 2000` and records bolts into `GameState.total_bolts`.
- **Lose condition:** `Player.player_died` → `WinLoseManager.game_lost()`; bolts are still recorded.
- **Bolts (`BoltsManager`):** enemies award points scaled by a multiplier. Tank = 15, Drone = 10, Armored Car = 10 base (before multiplier). Multiplier rises `+0.5` every **5 minutes**, max `3` increases → **x2.5**. Signal surface: `bolts_changed(new_bolts)`, `bolts_multiplier_changed(new_multiplier)`.
- **Upgrades (Armory, `res://scenes/menus/armory_menu/armory_menu.gd`):** cost = `BASE_COST(1000) + level*500`, `MAX_LEVEL = 3`. Health `+2`, speed `+20`, damage `+1` per level. It mutates `PlayerStats` and `ResourceSaver.save()`s `res://resources/player_stats.tres`. Reset via options → `GameState.reset()` restores defaults.
- **Time (`GameTimer`, `class_name GameTimer`):** `play_time` is pausable; `total_time` runs even while paused. On `_exit_tree` it adds to `GameState` and saves.
- **Player:** `player.gd` sets `Global.player = self` on ready; enemies/`configurable_sub_viewport.gd` read `Global.player`. Player components: `HealthComponent`, `MovementComponent`, `MainCannon`, `LandMineDeployer`, `CameraComponent`.
- **Enemies** (`tank`, `drone`, `armoredcar`) all read `Global.player` in `@onready` and use `BoltsManager.add_points(...)` on death. Ground enemies (tank, armoredcar) use `NavigationAgent2D` + `actor_setup.call_deferred()`.

---

## 6. Conventions & style

- **Scenes/scripts:** snake_case files, `PascalCase` nodes; player parts are grouped under component nodes.
- **Instantiating sub-scenes:** `const Bullet: PackedScene = preload("uid://...")` — the project preloads scenes by **UID** (e.g. `cannon.gd`, `landmine_deployer.gd`). Prefer UID preloads to path preloads when matching existing code.
- **Spawning:** bullets/mines are added to the current scene tree (`get_tree().current_scene` or `.root`), **not** as children of the shooter.
- **Signals** are the coupling mechanism between managers (e.g. `health_manager.gd` → `died` / `player_health_is_zero`; HUD listens to `BoltsManager`). Prefer connecting in `@onready`/`_ready` or via `[connection]` in the scene.
- **`preload` of `player_stats.tres`** happens in `movement_manager.gd`, `health_manager.gd`, `bullet.gd`, `landmine.gd` — values are read at `_ready`, so upgrades apply on the next scene load.

---

## 7. Known gotchas (read before editing game scenes)

- **`scenes/game` cross-node refs:** `goal_manager.gd` uses `%GameTimer` / `%WinLoseManager` (both `unique_name_in_owner` in `game.tscn`). `hud/time_played_label.gd` **cannot** use `%GameTimer` because it lives inside the instanced `Hud` scene — it takes `@export var game_timer: GameTimer`, assigned in `game.tscn` as `game_timer = NodePath("../../../../../../GameTimer")`. When adding refs across an instance boundary, follow that pattern.
- **`game.tscn` recovery warning:** Godot prints *"a node in the scene this one inherits from has been removed or moved, so a recovery process needs to take place"* on every instantiate. **Open and re-save `res://scenes/game/game.tscn`** to clear it.
- **`player_stats.tres` is dual-purpose:** read by gameplay scripts via `preload` **and** written by the Armory at runtime. Don't treat it as immutable at runtime.
- **`GameState.reset()` mutates fields directly** (doesn't re-create the resource) — if you add a new saved field, extend `reset()` too.
- **`@tool` scripts:** credits/window scripts run in the editor (`scrolling_credits.gd`, `end_credits.gd`, `pause_menu.gd`, win/lose windows). Mind `Engine.is_editor_hint()`.

---

## 8. Common workflows

- **Find a script/scene:** search `res://scenes` and `res://scripts`; ignore `res://addons` unless you're extending a plugin.
- **Verify a change:** open the scene and read its node tree; run the scene (`res://scenes/game/game.tscn`) to observe gameplay; check the Godot output/errors for parse and runtime issues. There is no test suite, so **run the game** to verify mechanics.
- **Load every script to catch parse errors** after broad refactors (project has no test runner).
- **Watch the console:** gameplay scripts `print()` (e.g. `"Enemy destroyed! Earned: ..."`, `"WIN"`/`"LOSE"`, `"Multiplier increased!"`) — useful signals when play-testing.

---

## 9. Pre-completion checklist for AI

1. GDScript parses with no errors/warnings (the `GDQuest_GDScript_formatter` plugin is installed — keep formatting consistent).
2. Cross-instance node refs follow the `%`-vs-`@export NodePath` rule (§2, §7).
3. Persistent changes are saved via `GameState` **and** `GlobalState.save()`.
4. Gameplay changes verified by **running the scene**, not just reading code.
5. `addons/` files were not modified.