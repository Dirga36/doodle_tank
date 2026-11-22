extends Node

@export var tile_map_layer: TileMapLayer
@export var player: Node2D
@export var enemy_pool: Array[EnemySpawnEntry] = []

@export_group("Spawn Area")
@export var min_spawn_radius: float = 650.0
@export var max_spawn_radius: float = 900.0

@export_group("Difficulty Scaling")
@export var initial_spawn_interval: float = 3.0
@export var min_spawn_interval: float = 0.5
@export var interval_decrease_per_minute: float = 0.6
@export var base_max_enemies: int = 15
@export var extra_enemies_per_minute: int = 5

var _spawn_timer: float = 0.0
var _elapsed_time: float = 0.0


func _process(delta: float) -> void:
	if (
		not is_instance_valid(player)
		or not is_instance_valid(tile_map_layer) or enemy_pool.is_empty()
	):
		return

	_elapsed_time += delta
	_spawn_timer += delta

	var minutes := _elapsed_time / 60.0
	var current_interval := maxf(
		min_spawn_interval,
		initial_spawn_interval - (minutes * interval_decrease_per_minute),
	)
	var current_max_enemies := base_max_enemies + int(minutes * extra_enemies_per_minute)

	if _spawn_timer >= current_interval:
		_spawn_timer = 0.0
		if get_tree().get_nodes_in_group("enemies").size() < current_max_enemies:
			try_spawn_enemy(minutes)


func try_spawn_enemy(minutes: float) -> void:
	var chosen_scene := _pick_weighted_enemy(minutes)
	if not chosen_scene:
		return

	for attempt in range(10):
		var angle := randf() * TAU
		var dist := randf_range(min_spawn_radius, max_spawn_radius)
		var candidate_pos := player.global_position + Vector2.from_angle(angle) * dist

		var cell := tile_map_layer.local_to_map(tile_map_layer.to_local(candidate_pos))
		if tile_map_layer.get_cell_atlas_coords(cell) == Vector2i(-1, -1):
			continue

		var enemy := chosen_scene.instantiate()
		enemy.global_position = candidate_pos
		enemy.add_to_group("enemies")
		get_parent().add_child(enemy)
		return


func _pick_weighted_enemy(minutes: float) -> PackedScene:
	var total_weight := 0.0
	var current_weights: Array[float] = []

	for entry in enemy_pool:
		if not entry or not entry.enemy_scene:
			current_weights.append(0.0)
			continue

		var w := maxf(
			entry.min_weight,
			entry.base_weight + (minutes * entry.weight_change_per_minute),
		)
		current_weights.append(w)
		total_weight += w

	if total_weight <= 0.0:
		return null

	var roll := randf() * total_weight
	var cumulative := 0.0

	for i in range(enemy_pool.size()):
		cumulative += current_weights[i]
		if roll <= cumulative:
			return enemy_pool[i].enemy_scene

	return null
