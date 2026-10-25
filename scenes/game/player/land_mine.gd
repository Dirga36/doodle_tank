extends Node

const Trap = preload("uid://dw2vx7rwmhiyw")
@onready var player: CharacterBody2D = $".."

var fire_cooldown: float = 2.0
var _cooldown_timer: float = 0.0

func _physics_process(delta: float) -> void:
	_update_cooldown(delta)
	if _can_fire():
		drop_bomb()


func _update_cooldown(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer = maxf(_cooldown_timer - delta, 0.0)


func _can_fire() -> bool:
	return Input.is_action_pressed("deploy_bomb") and _cooldown_timer == 0.0


func drop_bomb() -> void:
	var trap := Trap.instantiate() as Area2D
	
	if trap == null:
		return
	# Spawn at player's current global position
	trap.global_position = player.global_position
	# Add the bomb to the root main scene (not as a child of Player)
	get_tree().root.add_child(trap)
	_cooldown_timer = fire_cooldown
	print("DEPLOYED")
