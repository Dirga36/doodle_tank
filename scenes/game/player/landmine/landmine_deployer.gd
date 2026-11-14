extends Node
## Drops landmines at the player's position on input.

const Trap: PackedScene = preload("uid://dw2vx7rwmhiyw")

# TODO: Prefer having [Player] pass itself in rather than reaching up the tree.
@export var player: CharacterBody2D

@export var fire_cooldown: float = 2.0

var _cooldown_timer: float = 0.0


func _physics_process(delta: float) -> void:
	_update_cooldown(delta)
	if _can_fire():
		_drop_bomb()


func _update_cooldown(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer = maxf(_cooldown_timer - delta, 0.0)


func _can_fire() -> bool:
	return Input.is_action_pressed("set land mine") and _cooldown_timer == 0.0


func _drop_bomb() -> void:
	var trap: Area2D = Trap.instantiate() as Area2D
	if trap == null:
		return
	# Spawn at the player's current global position.
	trap.global_position = player.global_position
	# Add the bomb to the main scene (not as a child of the player).
	get_tree().current_scene.add_child(trap)
	_cooldown_timer = fire_cooldown
