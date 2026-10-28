class_name EnemySpawner2D extends Marker2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 1.5
@export var spawn_radius: float = 150.0
@export var max_active_enemies: int = 15

var _active_count: int = 5
var _timer: Timer

func _ready() -> void:
	_timer = Timer.new()
	add_child(_timer)
	_timer.timeout.connect(_spawn_enemy)
	_timer.start(spawn_interval)

func _spawn_enemy() -> void:
	if _active_count >= max_active_enemies or not enemy_scene:
		return

	var enemy = enemy_scene.instantiate()

	# Add to the main scene root, not the spawner, so enemies don't move if the spawner moves
	get_tree().current_scene.add_child(enemy)

	# Uniform circular distribution using square root of the random distance
	var angle = randf() * TAU
	var distance = sqrt(randf()) * spawn_radius
	enemy.global_position = global_position + Vector2(cos(angle), sin(angle)) * distance

	# Decrement the active count when the enemy is freed/killed
	enemy.tree_exited.connect(_on_enemy_removed)
	
	_active_count += 1

func _on_enemy_removed() -> void:
	_active_count -= 1
